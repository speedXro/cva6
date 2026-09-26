
import os
import queue
import threading
import time
import tkinter as tk
from tkinter import ttk, messagebox

import numpy as np

import serial
from serial.tools import list_ports

import matplotlib
matplotlib.use("TkAgg")
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.patches import Rectangle


CMD_START = 0x97
CMD_STOP = 0x98
HDR = 0x96

FDCT_BITS = 13                 
FDCT_MIN = -(1 << (FDCT_BITS - 1))     
FDCT_MAX = (1 << (FDCT_BITS - 1)) - 1    

QF_MIN, QF_MAX = 1, 100
QF_BYTE_OFFSET = 49            
QF_SEND_DELAY_MS = 150         

DEFAULT_BAUD = "921600"

WSEL_BYTES = (("RECT", 0x2C), ("HANN", 0x2D))
WSEL_DEFAULT = "RECT"


PXF_BYTES = (("12 dB", 0x31),
             ("24 dB", 0x2F),
             ("48 dB", 0x2E),
             ("96 dB", 0x30))
PXF_DEFAULT = "48 dB"

PKT_LEN = 9
PAYLOAD = 8                    

N_SAMPLES_U64 = 528
N_STFT_U64 = 256
N_FDCT_U64 = 512
N_IDCT_U64 = 256
N_DAC_U64 = 16


N_PACKETS = (N_SAMPLES_U64 + N_STFT_U64 + N_FDCT_U64
             + N_IDCT_U64 + N_DAC_U64)

FS = 625000.0                   
FS_DAC = 500000.0               
ADC_VREF = 3.3
ADC_FULL = 4095.0


N_SAMPLES_U16 = N_SAMPLES_U64 * 4      # 2112
N_STFT_U8 = N_STFT_U64 * 8             # 2048  -> 32 blocks of 8x8
N_FDCT_U16 = N_FDCT_U64 * 4            # 2048  -> 32 blocks of 8x8
N_IDCT_U8 = N_IDCT_U64 * 8             # 2048  -> 32 blocks of 8x8
N_DAC_U16 = N_DAC_U64 * 4              # 64

STFT_BLOCKS = N_STFT_U8 // 64          # 32
FDCT_BLOCKS = N_FDCT_U16 // 64         # 32
IDCT_BLOCKS = N_IDCT_U8 // 64          # 32
N_BLOCKS_STRIP = STFT_BLOCKS            # blocks per strip in the column maps


FDCT2_ROWS, FDCT2_COLS = 8, 4

FDCT2_ORDER = "row"


FDCT_VIEWS = ("Columns", "Blocks", "Both")
FDCT_VIEW_DEFAULT = "Columns"


MIRROR_COLUMN_MAPS = True


OFF_SAMPLES = 0
OFF_STFT = OFF_SAMPLES + N_SAMPLES_U64 * 8
OFF_FDCT = OFF_STFT + N_STFT_U64 * 8
OFF_IDCT = OFF_FDCT + N_FDCT_U64 * 8
OFF_DAC = OFF_IDCT + N_IDCT_U64 * 8
OFF_END = OFF_DAC + N_DAC_U64 * 8      # 12544


WIN_W_DEFAULT = 1640
WIN_H_DEFAULT = 1000
WIN_W_MIN = 700
PLOTS_W_FIXED = 1600            # plot width when "Fit width" is off

BUILD = "TUI-ACC - STFT+F/I DCT CVA6 Linux Demo - ISOLDE"
WIN_H_MIN = 550


COLOR_RAMPS = (
    ("DarkBlue",     ["#000033", "#0d2a8c", "#2f7ad6", "#9fd0f0", "#ffffff"]),
    ("DarkRed",      ["#330000", "#8c0d0d", "#d62f2f", "#f0a09f", "#ffffff"]),
    ("DarkOrange",   ["#331800", "#8c4409", "#d6822f", "#f0c89b", "#ffffff"]),
    ("DarkGreen",    ["#002b00", "#0d5c1a", "#2fa348", "#a6dfb3", "#ffffff"]),
    # phosphor green, like the text of a Linux terminal
    ("IntenseGreen", ["#001000", "#00400c", "#00a81f", "#00ff41", "#ccffd6"]),
)
COLOR_DEFAULT = COLOR_RAMPS[0][0]



LINE_SHADE_SAMPLES = 0.30
LINE_SHADE_DAC = 0.55


def ramp_color(cmap, f):
    r, g, b = cmap(float(f))[:3]
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def build_cmap(name):
    stops = dict(COLOR_RAMPS).get(name) or dict(COLOR_RAMPS)[COLOR_DEFAULT]
    return LinearSegmentedColormap.from_list(str(name).lower(), stops)



def decode_payload(payload: bytes) -> dict:

    buf = np.frombuffer(payload, dtype=np.uint8)

    samples_u16 = np.frombuffer(
        buf[OFF_SAMPLES:OFF_STFT].tobytes(), dtype=">u2").astype(np.uint16)
    samples_volts = np.clip(samples_u16, 0, 4095).astype(np.float64) \
        * (ADC_VREF / ADC_FULL)

    # ---- 2) STFT -> uint8 -> 8x8 blocks -------------------------------
    stft_u8 = buf[OFF_STFT:OFF_FDCT].copy()
    stft_img = blocks_to_columns(stft_u8, STFT_BLOCKS)

    fdct_u16 = np.frombuffer(
        buf[OFF_FDCT:OFF_IDCT].tobytes(), dtype=">u2")\
        .reshape(-1, 4)[:, ::-1].ravel().astype(np.int32)

    raw = fdct_u16 & ((1 << FDCT_BITS) - 1)
    sign = 1 << (FDCT_BITS - 1)
    fdct_i13 = np.where(raw & sign, raw - (1 << FDCT_BITS), raw)

    fdct_u8 = ((fdct_i13 - FDCT_MIN) >> (FDCT_BITS - 8)).astype(np.uint8)
    fdct_img = blocks_to_columns(fdct_u8, FDCT_BLOCKS)
    fdct_i13_img = blocks_to_columns(fdct_i13, FDCT_BLOCKS)   # for labels
    fdct2_img = columns_to_block_matrix(fdct_img)   # same data, block matrix

    idct_u8 = buf[OFF_IDCT:OFF_DAC].copy()
    idct_img = blocks_to_columns(idct_u8, IDCT_BLOCKS)

    dac_u16 = np.frombuffer(
        buf[OFF_DAC:OFF_END].tobytes(), dtype=">u2").astype(np.uint16)
    dac_volts = np.clip(dac_u16, 0, 4095).astype(np.float64) \
        * (ADC_VREF / ADC_FULL)

    return {
        "samples_volts": samples_volts,
        "stft_img": stft_img,
        "fdct_img": fdct_img,
        "fdct_i13_img": fdct_i13_img,
        "fdct2_img": fdct2_img,
        "idct_img": idct_img,
        "dac_volts": dac_volts,
    }


def columns_to_block_matrix(col_img):
    out = np.zeros((8 * FDCT2_ROWS, 8 * FDCT2_COLS), dtype=col_img.dtype)
    for k in range(min(col_img.shape[1], FDCT2_ROWS * FDCT2_COLS)):
        if FDCT2_ORDER == "row":
            r, c = divmod(k, FDCT2_COLS)
        else:
            c, r = divmod(k, FDCT2_ROWS)
        top = (FDCT2_ROWS - 1 - r) * 8          # block row 0 at the bottom
        blk = col_img[:, k].reshape(8, 8)[::-1]  # element 0 -> lower left
        out[top:top + 8, c * 8:c * 8 + 8] = blk
    return out


def blocks_to_columns(flat, n_blocks):
    return flat[:n_blocks * 64].reshape(n_blocks, 64).T

class AcqWorker(threading.Thread):
    FRAME_TIMEOUT = 5.0         # seconds of silence before giving up on a frame

    def __init__(self, port, baud, out_q, stop_evt):
        super().__init__(daemon=True)
        self.port = port
        self.baud = baud
        self.q = out_q
        self.stop = stop_evt
        self.tx_q = queue.Queue()   # extra bytes to send (e.g. QF)

    # ---------------------------------------------------------------
    def run(self):
        try:
            ser = serial.Serial(self.port, self.baud, timeout=0.05)
        except Exception as exc:
            self.q.put(("error", "Cannot open %s: %s" % (self.port, exc)))
            self.q.put(("stopped", None))
            return

        cycle = 0
        try:
            time.sleep(0.2)                     # let the port settle
            while not self.stop.is_set():
                self.send_pending(ser)          # QF etc. between frames
                ser.reset_input_buffer()
                ser.write(bytes([CMD_START]))
                ser.flush()
                self.q.put(("status",
                            "waiting for %d packets ..." % N_PACKETS))

                payload, resync = self.read_frame(ser)
                if self.stop.is_set():
                    break
                if payload is None:
                    self.q.put(("error",
                                "timeout: only %d/%d packets received"
                                % (resync, N_PACKETS)))
                    continue
                cycle += 1
                self.q.put(("frame", (payload, resync, cycle)))
        except Exception as exc:
            self.q.put(("error", "serial error: %s" % exc))
        finally:
            try:
                self.send_pending(ser)          # don't lose a queued QF
                ser.write(bytes([CMD_STOP]))
                ser.flush()
                time.sleep(0.05)
            except Exception:
                pass
            try:
                ser.close()
            except Exception:
                pass
            self.q.put(("stopped", None))

    # ---------------------------------------------------------------
    def send_pending(self, ser):
        pending = {}                        # key -> (byte, label), newest wins
        while True:
            try:
                key, b, label = self.tx_q.get_nowait()
            except queue.Empty:
                break
            pending.pop(key, None)          # keep insertion order fresh
            pending[key] = (b, label)
        for b, label in pending.values():
            ser.write(bytes([b]))
            ser.flush()
            self.q.put(("status", "%s sent (byte %d = 0x%02X)"
                        % (label, b, b)))

    # ---------------------------------------------------------------
    def read_frame(self, ser):
        buf = bytearray()
        out = bytearray()
        got = 0
        resync = 0
        deadline = time.monotonic() + self.FRAME_TIMEOUT

        while got < N_PACKETS and not self.stop.is_set():
            n = ser.in_waiting
            chunk = ser.read(n if n else 1)
            if chunk:
                buf += chunk
                deadline = time.monotonic() + self.FRAME_TIMEOUT
            elif time.monotonic() > deadline:
                return None, got

            i = 0
            while len(buf) - i >= PKT_LEN and got < N_PACKETS:
                if buf[i] != HDR:               # lost alignment -> resync
                    i += 1
                    resync += 1
                    continue
                out += buf[i + 1:i + PKT_LEN]
                i += PKT_LEN
                got += 1
            del buf[:i]

        if got < N_PACKETS:
            return None, got
        return bytes(out), resync


def block_views(d, block):
    if d is None:
        z = np.zeros((8, 8), dtype=np.uint8)
        return (z, z, z), (z, z, z)
    cut = lambda key: d[key][:, block].reshape(8, 8)
    stft, fdct, idct = cut("stft_img"), cut("fdct_img"), cut("idct_img")
    fdct_i13 = cut("fdct_i13_img").astype(np.int16)         # -4096..4095
    colour = (stft, fdct[::-1], idct)
    labels = (stft, fdct_i13[::-1], idct)
    return colour, labels

class BlockViewer(tk.Toplevel):
    TITLES = ("StftOutputsU8",
              "Fdct2dOutputs - block matrix\nelement 0 lower left",
              "Idct2dOutputsU8")
    SIGNED = (False, True, False)           # which panels print a sign
    FDCT_PANEL = 1                          # index of the Fdct2d panel

    def __init__(self, app, snapshot=None, block=0, cycle=None):
        super().__init__(app)
        self.app = app
        self.frozen = snapshot is not None
        self.snap = snapshot
        self.snap_block = block
        self.snap_cycle = cycle
        self.title("Block viewer")
        sw, sh = self.winfo_screenwidth(), self.winfo_screenheight()
        self.geometry("%dx%d" % (min(1500, sw - 60), min(620, sh - 100)))
        self.minsize(700, 300)

        bar = ttk.Frame(self, padding=(8, 6))
        bar.pack(side="top", fill="x")
        ttk.Button(bar, text="<  Prev", command=lambda: self.step(-1))\
            .pack(side="left")
        ttk.Button(bar, text="Next  >", command=lambda: self.step(+1))\
            .pack(side="left", padx=(6, 12))
        self.lbl = tk.StringVar(value="")
        ttk.Label(bar, textvariable=self.lbl).pack(side="left")
        if self.frozen:
            tk.Label(bar, text="  SNAPSHOT - frozen  ", bg="#c03030",
                     fg="#ffffff", font=("TkDefaultFont", 10, "bold"))\
                .pack(side="right")
        else:
            tk.Label(bar, text="  LIVE  ", bg="#2f8a3a", fg="#ffffff",
                     font=("TkDefaultFont", 10, "bold")).pack(side="right")

        self.fig = Figure(figsize=(15, 5.6), dpi=100, constrained_layout=True)
        self.ims, self.txts, self.axes4 = [], [], []
        for k, title in enumerate(self.TITLES):
            ax = self.fig.add_subplot(1, len(self.TITLES), k + 1)
            im = ax.imshow(np.zeros((8, 8), dtype=np.uint8), cmap=app.cmap,
                           vmin=0, vmax=255, interpolation="nearest")
            ax.set_title(title, fontsize=11)
            ax.set_xticks(range(8))
            ax.set_yticks(range(8))
            ax.set_xticks(np.arange(-0.5, 8, 1), minor=True)
            ax.set_yticks(np.arange(-0.5, 8, 1), minor=True)
            ax.grid(which="minor", color="#ffffff", lw=0.6, alpha=0.6)
            ax.tick_params(which="minor", length=0)
            cells = [[ax.text(c, r, "", ha="center", va="center", fontsize=9)
                      for c in range(8)] for r in range(8)]
            self.ims.append(im)
            self.txts.append(cells)
            self.axes4.append(ax)

        self.canvas = FigureCanvasTkAgg(self.fig, master=self)
        w = self.canvas.get_tk_widget()
        w.configure(highlightthickness=0)
        w.pack(side="top", fill="both", expand=True)

        self.bind("<Left>", lambda e: self.step(-1))
        self.bind("<Right>", lambda e: self.step(+1))
        self.protocol("WM_DELETE_WINDOW", self.close)
        app.viewers.append(self)

        if self.frozen:
            self.render_snapshot()

    def step(self, delta):
        if self.frozen:                     # browse inside the frozen frame
            self.snap_block = (self.snap_block + delta) % N_BLOCKS_STRIP
            self.render_snapshot()
        elif self.app.sel_block is not None:
            self.app.select_block((self.app.sel_block + delta) % N_BLOCKS_STRIP)

    def render_snapshot(self):
        colour, labels = block_views(self.snap, self.snap_block)
        self.show(self.snap_block, colour, labels, self.snap_cycle)

    def show(self, block, colour_imgs, label_imgs, cycle):
        for k, (im, cells, col, lab) in enumerate(
                zip(self.ims, self.txts, colour_imgs, label_imgs)):
            im.set_data(col)
            signed = self.SIGNED[k]         # FDCT panels: int16_t with sign
            for r in range(8):
                for c in range(8):
                    t = cells[r][c]
                    v = int(lab[r, c])
                    t.set_text(("%+d" % v if v else "0") if signed else str(v))
                    t.set_color("#000000" if col[r, c] >= 150 else "#ffffff")
        row, col = App.block_to_cell(block)
        self.axes4[self.FDCT_PANEL].set_title(
            "%s\ncell (row %d, col %d)"
            % (self.TITLES[self.FDCT_PANEL], row, col), fontsize=11)
        self.lbl.set("block %d / %d   (frame %s)"
                     % (block, N_BLOCKS_STRIP - 1, cycle))
        if self.frozen:
            self.title("Snapshot - frame %s - block %d" % (cycle, block))
        else:
            self.title("Block viewer (live) - block %d" % block)
        self.canvas.draw_idle()

    def apply_cmap(self, cmap):
        for im in self.ims:
            im.set_cmap(cmap)
        self.canvas.draw_idle()

    def close(self):
        if self in self.app.viewers:
            self.app.viewers.remove(self)
        if not self.frozen:
            self.app.detail_closed()
        self.destroy()

class App(tk.Tk):

    def __init__(self):
        super().__init__()
        self.title("UART DSP viewer - %s" % BUILD)

        sw, sh = self.winfo_screenwidth(), self.winfo_screenheight()
        w = min(WIN_W_DEFAULT, sw - 40)
        h = min(WIN_H_DEFAULT, sh - 80)
        self.geometry("%dx%d" % (w, h))
        self.minsize(WIN_W_MIN, WIN_H_MIN)
        self.resizable(True, True)

        self.q = queue.Queue()
        self.stop_evt = None
        self.worker = None

        self.last = None            # last decoded frame
        self.last_cycle = None
        self.sel_block = None       # block shown in the block viewer
        self.detail = None          # BlockViewer window or None
        self.sel_rects = []         # highlight rectangles on plots 2..4
        self.cmap = build_cmap(COLOR_DEFAULT)
        self.viewers = []           # open BlockViewer windows, to recolour
        self._fit_job = None        # pending "Fit width" relayout

        self._build_toolbar()
        self._build_side_panel()
        self._build_figure(w, h)

        self.protocol("WM_DELETE_WINDOW", self.on_close)
        self.after(50, self.poll_queue)
        self.after(400, self.self_check)

    def self_check(self):
        print("=" * 62)
        print("UART DSP viewer  BUILD %s" % BUILD)
        print("  file        : %s" % os.path.abspath(__file__))
        print("  baud default: %s" % self.baud_cb.get())
        print("  WSEL        : %s  values %s  -> %s"
              % (self.wsel_cb.get(), list(self.wsel_cb["values"]),
                 ["0x%02X" % b for _, b in WSEL_BYTES]))
        print("  PXF         : %s  values %s  -> %s"
              % (self.pxf_cb.get(), list(self.pxf_cb["values"]),
                 ["0x%02X" % b for _, b in PXF_BYTES]))
        print("  WSEL visible: %s   PXF visible: %s   Fit width: %s"
              % (bool(self.wsel_cb.winfo_ismapped()),
                 bool(self.pxf_cb.winfo_ismapped()),
                 self.fit_var.get()))
        print("  window      : %dx%d" % (self.winfo_width(), self.winfo_height()))
        print("=" * 62)

    def _build_toolbar(self):
        bar = ttk.Frame(self, padding=(8, 6, 8, 2))
        bar.pack(side="top", fill="x")

        ttk.Label(bar, text="Port:").pack(side="left")
        self.port_cb = ttk.Combobox(bar, width=22, state="normal")
        self.port_cb.pack(side="left", padx=(4, 4))

        ttk.Button(bar, text="Refresh", command=self.refresh_ports)\
            .pack(side="left", padx=(0, 12))

        ttk.Label(bar, text="Baud:").pack(side="left")
        self.baud_cb = ttk.Combobox(
            bar, width=10, state="normal",
            values=("9600", "19200", "38400", "57600", "115200",
                    "230400", "460800", "921600", "1000000", "2000000"))
        self.baud_cb.set(DEFAULT_BAUD)
        self.baud_cb.pack(side="left", padx=(4, 12))

        self.start_btn = ttk.Button(bar, text="Start", command=self.on_start)
        self.start_btn.pack(side="left")
        self.stop_btn = ttk.Button(bar, text="Stop", command=self.on_stop,
                                   state="disabled")
        self.stop_btn.pack(side="left", padx=(6, 12))

        self.status = tk.StringVar(value="idle")
        ttk.Label(bar, textvariable=self.status).pack(side="right")

        row2 = ttk.Labelframe(self, text=" DSP settings ", padding=(8, 4))
        row2.pack(side="top", fill="x", padx=8, pady=(0, 6))

        self.fit_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(row2, text="Fit width", variable=self.fit_var,
                        command=self.on_fit_width).pack(side="left",
                                                        padx=(0, 16))

        ttk.Label(row2, text="FDCT view:").pack(side="left")
        self.fdct_view = FDCT_VIEW_DEFAULT
        self.fdct_cb = ttk.Combobox(
            row2, state="readonly", values=FDCT_VIEWS,
            width=max(len(v) for v in FDCT_VIEWS) + 1)
        self.fdct_cb.set(FDCT_VIEW_DEFAULT)
        self.fdct_cb.pack(side="left", padx=(4, 16))
        self.fdct_cb.bind("<<ComboboxSelected>>", self.on_fdct_view_changed)

        ttk.Label(row2, text="Color:").pack(side="left")
        color_values = tuple(n for n, _ in COLOR_RAMPS)
        self.color_cb = ttk.Combobox(
            row2, state="readonly", values=color_values,
            width=max(len(n) for n in color_values) + 1)
        self.color_cb.set(COLOR_DEFAULT)
        self.color_cb.pack(side="left", padx=(4, 16))
        self.color_cb.bind("<<ComboboxSelected>>", self.on_color_changed)

        ttk.Label(row2, text="WSEL:").pack(side="left")
        wsel_values = tuple(v for v, _ in WSEL_BYTES)
        self.wsel_cb = ttk.Combobox(
            row2, state="readonly", values=wsel_values,
            width=max(len(v) for v in wsel_values) + 1)   # fit the content
        self.wsel_cb.set(WSEL_DEFAULT)
        self.wsel_cb.pack(side="left", padx=(4, 16))
        self.wsel_cb.bind("<<ComboboxSelected>>", self.on_wsel_changed)

        ttk.Label(row2, text="PXF:").pack(side="left")
        pxf_values = tuple(v for v, _ in PXF_BYTES)
        self.pxf_cb = ttk.Combobox(
            row2, state="readonly", values=pxf_values,
            width=max(len(v) for v in pxf_values) + 1)    # fit the content
        self.pxf_cb.set(PXF_DEFAULT)
        self.pxf_cb.pack(side="left", padx=(4, 16))
        self.pxf_cb.bind("<<ComboboxSelected>>", self.on_pxf_changed)

        self.refresh_ports()

    def _build_side_panel(self):
        side = ttk.Frame(self, padding=(6, 8, 10, 8))
        side.pack(side="right", fill="y")

        ttk.Label(side, text="QF", font=("TkDefaultFont", 11, "bold"))\
            .pack(side="top", pady=(0, 4))

        self.qf_var = tk.IntVar(value=50)
        self._qf_job = None
        self._qf_ready = False          # ignore callbacks fired during startup
        self.after(300, lambda: setattr(self, "_qf_ready", True))
        self.qf_scale = tk.Scale(
            side, variable=self.qf_var, orient="vertical",
            command=self.on_qf_changed,
            from_=100, to=1,            # top = 100, bottom = 1
            resolution=1, showvalue=True, tickinterval=10,
            length=300, width=18, sliderlength=28)
        self.qf_scale.pack(side="top", fill="y", expand=True)

    def on_fdct_view_changed(self, _evt=None):
        view = self.fdct_cb.get()
        if view == self.fdct_view:
            return
        self.fdct_view = view
        self._layout_figure()
        self.canvas.draw_idle()
        self.on_fit_width()
        self.focus_set()

    def on_color_changed(self, _evt=None):
        self.cmap = build_cmap(self.color_cb.get())
        for im in (self.im_stft, self.im_fdct, self.im_fdct2, self.im_idct):
            if im is not None:
                im.set_cmap(self.cmap)
        self.ln_samples.set_color(ramp_color(self.cmap, LINE_SHADE_SAMPLES))
        self.ln_dac.set_color(ramp_color(self.cmap, LINE_SHADE_DAC))
        self.ln_dac.set_markerfacecolor(ramp_color(self.cmap, LINE_SHADE_DAC))
        self.ln_dac.set_markeredgecolor(ramp_color(self.cmap, LINE_SHADE_DAC))
        self.canvas.draw_idle()
        for v in list(self.viewers):
            v.apply_cmap(self.cmap)
        self.focus_set()

    def on_wsel_changed(self, _evt=None):
        value = self.wsel_cb.get()
        table = dict(WSEL_BYTES)
        if value in table:
            self.send_setting("wsel", table[value], "WSEL %s" % value)
        self.focus_set()                    # drop the combobox highlight

    def on_pxf_changed(self, _evt=None):
        value = self.pxf_cb.get()
        table = dict(PXF_BYTES)
        if value in table:
            self.send_setting("pxf", table[value], "PXF %s" % value)
        self.focus_set()

    def on_qf_changed(self, _value=None):
        if not self._qf_ready:
            return
        if self._qf_job is not None:
            self.after_cancel(self._qf_job)
        self._qf_job = self.after(QF_SEND_DELAY_MS, self._send_qf)

    def _send_qf(self):
        self._qf_job = None
        qf = min(max(int(self.qf_var.get()), QF_MIN), QF_MAX)
        self.send_setting("qf", qf + QF_BYTE_OFFSET, "QF %d" % qf)

    def send_setting(self, key, b, label):
        if self.worker is not None and self.worker.is_alive():
            self.worker.tx_q.put((key, b, label))
            self.status.set("%s (byte %d = 0x%02X) queued ..." % (label, b, b))
            return

        port = self.port_cb.get().strip()
        if not port:
            self.status.set("%s not sent: select a serial port first" % label)
            return
        try:
            baud = int(self.baud_cb.get())
        except ValueError:
            self.status.set("%s not sent: bad baud rate" % label)
            return
        try:
            with serial.Serial(port, baud, timeout=0.5) as ser:
                ser.write(bytes([b]))
                ser.flush()
        except Exception as exc:
            self.status.set("%s not sent: %s" % (label, exc))
            return
        self.status.set("%s sent (byte %d = 0x%02X)" % (label, b, b))

    def refresh_ports(self):
        ports = [p.device for p in list_ports.comports()]
        self.port_cb["values"] = ports
        if ports and not self.port_cb.get():
            self.port_cb.set(ports[0])

    def _build_figure(self, win_w, win_h):
        dpi = 100
        self.fig = Figure(figsize=(win_w / dpi, (win_h - 50) / dpi), dpi=dpi,
                          constrained_layout=True)
        self._layout_figure()
        self._build_canvas_holder()

    def _layout_figure(self):
        self.fig.clear()
        self.sel_rects = []
        self.im_fdct = self.im_fdct2 = self.ax_fdct2 = None

        view = getattr(self, "fdct_view", FDCT_VIEW_DEFAULT)
        show_cols = view in ("Columns", "Both")
        show_blks = view in ("Blocks", "Both")
        n_maps = 2 + show_cols + show_blks       # STFT + Fdct2d view(s) + IDCT

        gs = self.fig.add_gridspec(2, 2 * n_maps, height_ratios=[2.4, 1.0])
        nxt = [0]

        def slot():
            i = nxt[0]
            nxt[0] += 1
            return self.fig.add_subplot(gs[0, 2 * i:2 * i + 2])

        num = [0]

        def n():
            num[0] += 1
            return num[0]

        ax_stft = slot()
        ax_fdct = slot() if show_cols else None
        ax_fdct2 = slot() if show_blks else None
        ax_idct = slot()
        half = n_maps                            # half of 2*n_maps columns
        ax_samples = self.fig.add_subplot(gs[1, 0:half])
        ax_dac = self.fig.add_subplot(gs[1, half:2 * n_maps])

        ax = [ax_samples, ax_stft, ax_fdct, ax_idct, ax_dac]
        self.ax = ax
        self.ax_fdct2 = ax_fdct2

        self.t_samples = np.arange(N_SAMPLES_U16) / FS * 1e3       # ms
        (self.ln_samples,) = ax[0].plot(self.t_samples,
                                        np.zeros(N_SAMPLES_U16),
                                        lw=0.8,
                                        color=ramp_color(self.cmap,
                                                         LINE_SHADE_SAMPLES))
        ax[0].set_title("%d) SamplesVolts - %d ADC samples @ %.0f kHz"
                        % (n(), N_SAMPLES_U16, FS / 1e3), fontsize=11)
        ax[0].set_xlabel("time [ms]")
        ax[0].set_ylabel("voltage [V]")
        ax[0].set_xlim(0, self.t_samples[-1])
        ax[0].set_ylim(0, ADC_VREF)
        ax[0].grid(alpha=0.3)

        self.im_stft = self._make_image(
            ax[1], STFT_BLOCKS,
            "%d) StftOutputsU8 - %d x 64\n"
            "left click: live, right click: snapshot" % (n(), STFT_BLOCKS),
            flip=MIRROR_COLUMN_MAPS)
        if ax_fdct is not None:
            self.im_fdct = self._make_image(
                ax_fdct, FDCT_BLOCKS,
                "%d) Fdct2dOutputs - %d x 64 columns\n"
                "13-bit signed -4096..4095 -> 0..255" % (n(), FDCT_BLOCKS),
                flip=MIRROR_COLUMN_MAPS)
        if ax_fdct2 is not None:
            self.im_fdct2 = self._make_matrix_image(
                ax_fdct2,
                "%d) Fdct2dOutputs - %d x %d blocks of 8x8\n"
                "blocks and pixels both start at the lower left"
                % (n(), FDCT2_ROWS, FDCT2_COLS))
        self.im_idct = self._make_image(
            ax[3], IDCT_BLOCKS,
            "%d) Idct2dOutputsU8 - %d x 64\n(0..255)" % (n(), IDCT_BLOCKS),
            flip=MIRROR_COLUMN_MAPS)

        self.t_dac = np.arange(N_DAC_U16) / FS_DAC * 1e6           # us
        (self.ln_dac,) = ax[4].plot(self.t_dac, np.zeros(N_DAC_U16),
                                    lw=1.2, marker="o", ms=3,
                                    color=ramp_color(self.cmap,
                                                     LINE_SHADE_DAC))
        ax[4].set_title("%d) DacVolts - %d DAC samples @ %.0f kHz"
                        % (n(), N_DAC_U16, FS_DAC / 1e3), fontsize=11)
        ax[4].set_xlabel("time [us]")
        ax[4].set_ylabel("voltage [V]")
        ax[4].set_xlim(0, self.t_dac[-1])
        ax[4].set_ylim(0, ADC_VREF)
        ax[4].grid(alpha=0.3)

        if getattr(self, "last", None) is not None:
            self.draw_frame(self.last)
        if getattr(self, "sel_block", None) is not None:
            self.mark_block(self.sel_block)

    def _build_canvas_holder(self):
        wrap = ttk.Frame(self)
        wrap.pack(side="top", fill="both", expand=True)
        self.holder = tk.Canvas(wrap, highlightthickness=0, background="#ffffff")
        self.hsb = ttk.Scrollbar(wrap, orient="horizontal",
                                 command=self.holder.xview)
        self.holder.configure(xscrollcommand=self.hsb.set)
        self.holder.pack(side="top", fill="both", expand=True)

        self.canvas = FigureCanvasTkAgg(self.fig, master=self.holder)
        self.mpl_widget = self.canvas.get_tk_widget()
        self.mpl_widget.configure(highlightthickness=0)
        self.plot_item = self.holder.create_window(
            (0, 0), window=self.mpl_widget, anchor="nw")
        self.holder.bind("<Configure>", self._schedule_fit)

        self.canvas.mpl_connect("button_press_event", self.on_click)
        self.canvas.mpl_connect("motion_notify_event", self.on_motion)
        self.on_fit_width()
        self.canvas.draw()

    def _schedule_fit(self, _evt=None):
        if self._fit_job is not None:
            self.after_cancel(self._fit_job)
        self._fit_job = self.after(60, self.on_fit_width)

    def on_fit_width(self):
        self._fit_job = None
        vw = max(self.holder.winfo_width(), 1)
        vh = max(self.holder.winfo_height(), 1)
        w = vw if self.fit_var.get() else PLOTS_W_FIXED
        self.holder.itemconfigure(self.plot_item, width=w, height=vh)
        self.holder.configure(scrollregion=(0, 0, w, vh))
        if w > vw:
            if not self.hsb.winfo_ismapped():
                # before= keeps the holder from swallowing the scrollbar's row
                self.hsb.pack(side="bottom", fill="x", before=self.holder)
        elif self.hsb.winfo_ismapped():
            self.hsb.pack_forget()

    def _make_image(self, ax, n_blocks, title, flip=False):
        extent = (0, n_blocks, 0, 64) if flip else (0, n_blocks, 64, 0)
        im = ax.imshow(np.zeros((64, n_blocks), dtype=np.uint8),
                       cmap=self.cmap, vmin=0, vmax=255,
                       aspect="equal", interpolation="nearest",
                       extent=extent)
        ax.set_title(title, fontsize=10)
        ax.set_xlabel("block index")
        ax.set_ylabel("element", fontsize=9)
        ax.set_yticks(np.arange(0, 65, 16))
        ax.set_yticks(np.arange(0, 65, 8), minor=True)
        ax.set_xticks(np.arange(0, n_blocks + 1, 4))
        ax.set_xticks(np.arange(0, n_blocks + 1, 1), minor=True)
        ax.tick_params(labelsize=8)
        ax.grid(which="minor", color="#ffffff", lw=0.4, alpha=0.5)
        rect = Rectangle((0, 0), 1, 64, fill=False, edgecolor="#ff3030",
                         lw=2.0, visible=False, zorder=5)   # full column
        ax.add_patch(rect)
        self.sel_rects.append(rect)
        return im

    def _make_matrix_image(self, ax, title):
        im = ax.imshow(
            np.zeros((8 * FDCT2_ROWS, 8 * FDCT2_COLS), dtype=np.uint8),
            cmap=self.cmap, vmin=0, vmax=255, aspect="equal",
            interpolation="nearest",
            extent=(0, FDCT2_COLS, 0, FDCT2_ROWS))   # y grows upwards
        ax.set_title(title, fontsize=10)
        ax.set_xlabel("block column")
        ax.set_ylabel("block row", fontsize=9)
        ax.set_xticks(np.arange(FDCT2_COLS) + 0.5)
        ax.set_xticklabels(range(FDCT2_COLS))
        ax.set_yticks(np.arange(FDCT2_ROWS) + 0.5)
        ax.set_yticklabels(range(FDCT2_ROWS))
        ax.set_xticks(np.arange(0, FDCT2_COLS + 1), minor=True)
        ax.set_yticks(np.arange(0, FDCT2_ROWS + 1), minor=True)
        ax.tick_params(labelsize=8)
        ax.tick_params(which="minor", length=0)
        ax.grid(which="minor", color="#ffffff", lw=0.6, alpha=0.7)
        self.rect_fdct2 = Rectangle((0, 0), 1, 1, fill=False,
                                    edgecolor="#ff3030", lw=2.0,
                                    visible=False, zorder=5)
        ax.add_patch(self.rect_fdct2)
        return im

    @staticmethod
    def block_to_cell(block):
        if FDCT2_ORDER == "row":
            return divmod(block, FDCT2_COLS)
        c, r = divmod(block, FDCT2_ROWS)
        return r, c

    @staticmethod
    def cell_to_block(r, c):
        if FDCT2_ORDER == "row":
            return r * FDCT2_COLS + c
        return c * FDCT2_ROWS + r

    def on_start(self):
        port = self.port_cb.get().strip()
        if not port:
            messagebox.showwarning("No port", "Select a serial port first.")
            return
        try:
            baud = int(self.baud_cb.get())
        except ValueError:
            messagebox.showwarning("Bad baud rate", "Baud rate must be a number.")
            return

        self.stop_evt = threading.Event()
        self.worker = AcqWorker(port, baud, self.q, self.stop_evt)
        self.worker.start()

        self.start_btn.configure(state="disabled")
        self.stop_btn.configure(state="normal")
        self.status.set("running ...")

    def on_stop(self):
        if self.stop_evt is not None:
            self.stop_evt.set()             # worker sends 0x98 and exits
        self.stop_btn.configure(state="disabled")
        self.status.set("stopping ...")

    def on_close(self):
        if self.stop_evt is not None:
            self.stop_evt.set()
        if self.worker is not None and self.worker.is_alive():
            self.worker.join(timeout=2.0)
        self.destroy()

    def poll_queue(self):
        try:
            while True:
                kind, data = self.q.get_nowait()
                if kind == "frame":
                    payload, resync, cycle = data
                    self.update_plots(payload, cycle)
                    msg = "cycle %d OK" % cycle
                    if resync:
                        msg += "  (%d bytes dropped while re-syncing)" % resync
                    self.status.set(msg)
                elif kind == "status":
                    self.status.set(data)
                elif kind == "error":
                    self.status.set(data)
                elif kind == "stopped":
                    self.start_btn.configure(state="normal")
                    self.stop_btn.configure(state="disabled")
                    self.status.set("stopped (0x98 sent)")
                    self.worker = None
                    self.stop_evt = None
        except queue.Empty:
            pass
        self.after(50, self.poll_queue)

    def update_plots(self, payload, cycle=None):
        d = decode_payload(payload)
        self.last = d
        self.last_cycle = cycle
        self.draw_frame(d)
        self.canvas.draw_idle()
        if self.detail is not None:
            self.refresh_detail()

    def draw_frame(self, d):
        self.ln_samples.set_ydata(d["samples_volts"])
        self.ln_dac.set_ydata(d["dac_volts"])
        flip = MIRROR_COLUMN_MAPS          # the three column maps only
        for im, key, mirror in ((self.im_stft, "stft_img", flip),
                                (self.im_fdct, "fdct_img", flip),
                                (self.im_fdct2, "fdct2_img", False),
                                (self.im_idct, "idct_img", flip)):
            if im is not None:
                im.set_data(d[key][::-1] if mirror else d[key])

    # -------------------------------------------------------- block viewer
    def _strip_axes(self):
        return tuple(a for a in (self.ax[1], self.ax[2], self.ax[3])
                     if a is not None)

    def on_motion(self, event):
        over = (event.inaxes in self._strip_axes()
                or (self.ax_fdct2 is not None
                    and event.inaxes is self.ax_fdct2))
        want = "hand2" if over else ""
        if self.mpl_widget.cget("cursor") != want:
            self.mpl_widget.configure(cursor=want)

    def on_click(self, event):
        if event.button not in (1, 3) or event.xdata is None \
                or event.ydata is None:
            return
        if event.inaxes in self._strip_axes():
            block = min(max(int(event.xdata), 0), N_BLOCKS_STRIP - 1)
        elif self.ax_fdct2 is not None and event.inaxes is self.ax_fdct2:
            c = min(max(int(event.xdata), 0), FDCT2_COLS - 1)
            r = min(max(int(event.ydata), 0), FDCT2_ROWS - 1)
            block = self.cell_to_block(r, c)
        else:
            return
        if event.button == 3:
            self.open_snapshot(block)
        else:
            self.select_block(block)

    def open_snapshot(self, block):
        snap = None
        if self.last is not None:
            snap = {k: self.last[k].copy()
                    for k in ("stft_img", "fdct_img", "fdct_i13_img", "idct_img")}
        BlockViewer(self, snapshot=snap, block=block,
                    cycle=self.last_cycle if snap is not None else "-")

    def mark_block(self, block):
        for rect in self.sel_rects:
            rect.set_x(block)
            rect.set_visible(True)
        if self.ax_fdct2 is not None:
            r, c = self.block_to_cell(block)
            self.rect_fdct2.set_xy((c, r))
            self.rect_fdct2.set_visible(True)

    def select_block(self, block):
        self.sel_block = block
        self.mark_block(block)
        self.canvas.draw_idle()

        if self.detail is None:
            self.detail = BlockViewer(self)
        else:
            self.detail.lift()
        self.refresh_detail()

    def refresh_detail(self):
        if self.detail is None or self.sel_block is None:
            return
        colour, labels = block_views(self.last, self.sel_block)
        self.detail.show(self.sel_block, colour, labels,
                         self.last_cycle if self.last is not None else "-")

    def detail_closed(self):
        self.detail = None
        self.sel_block = None
        for rect in self.sel_rects:
            rect.set_visible(False)
        if self.ax_fdct2 is not None:
            self.rect_fdct2.set_visible(False)
        self.canvas.draw_idle()


# --------------------------------------------------------------------------
if __name__ == "__main__":
    App().mainloop()
