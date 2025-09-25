; ModuleID = '/tools/repos/cva6/core/cdf53_versions/hls_projects/cdf53_forward/HW_dwt53_forward/hls/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: argmemonly noinline willreturn
define void @apatb_HW_dwt53_forward_ir(i64 %op1, i64 %op2, i64* noalias nocapture nonnull %p_low_03, i64* noalias nocapture nonnull %p_low_47, i64* noalias nocapture nonnull %p_high_03, i64* noalias nocapture nonnull %p_high_47) local_unnamed_addr #0 {
entry:
  %p_low_03_copy = alloca i64, align 512
  %p_low_47_copy = alloca i64, align 512
  %p_high_03_copy = alloca i64, align 512
  %p_high_47_copy = alloca i64, align 512
  call fastcc void @copy_in(i64* nonnull %p_low_03, i64* nonnull align 512 %p_low_03_copy, i64* nonnull %p_low_47, i64* nonnull align 512 %p_low_47_copy, i64* nonnull %p_high_03, i64* nonnull align 512 %p_high_03_copy, i64* nonnull %p_high_47, i64* nonnull align 512 %p_high_47_copy)
  call void @apatb_HW_dwt53_forward_hw(i64 %op1, i64 %op2, i64* %p_low_03_copy, i64* %p_low_47_copy, i64* %p_high_03_copy, i64* %p_high_47_copy)
  call void @copy_back(i64* %p_low_03, i64* %p_low_03_copy, i64* %p_low_47, i64* %p_low_47_copy, i64* %p_high_03, i64* %p_high_03_copy, i64* %p_high_47, i64* %p_high_47_copy)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in(i64* noalias readonly, i64* noalias align 512, i64* noalias readonly, i64* noalias align 512, i64* noalias readonly, i64* noalias align 512, i64* noalias readonly, i64* noalias align 512) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0i64(i64* align 512 %1, i64* %0)
  call fastcc void @onebyonecpy_hls.p0i64(i64* align 512 %3, i64* %2)
  call fastcc void @onebyonecpy_hls.p0i64(i64* align 512 %5, i64* %4)
  call fastcc void @onebyonecpy_hls.p0i64(i64* align 512 %7, i64* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0i64(i64* noalias align 512 %dst, i64* noalias readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq i64* %dst, null
  %1 = icmp eq i64* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %3 = load i64, i64* %src, align 8
  store i64 %3, i64* %dst, align 512
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_out(i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512) unnamed_addr #3 {
entry:
  call fastcc void @onebyonecpy_hls.p0i64(i64* %0, i64* align 512 %1)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %2, i64* align 512 %3)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %4, i64* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %6, i64* align 512 %7)
  ret void
}

declare void @apatb_HW_dwt53_forward_hw(i64, i64, i64*, i64*, i64*, i64*)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back(i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512, i64* noalias, i64* noalias readonly align 512) unnamed_addr #3 {
entry:
  call fastcc void @onebyonecpy_hls.p0i64(i64* %0, i64* align 512 %1)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %2, i64* align 512 %3)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %4, i64* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0i64(i64* %6, i64* align 512 %7)
  ret void
}

declare void @HW_dwt53_forward_hw_stub(i64, i64, i64* noalias nocapture nonnull, i64* noalias nocapture nonnull, i64* noalias nocapture nonnull, i64* noalias nocapture nonnull)

define void @HW_dwt53_forward_hw_stub_wrapper(i64, i64, i64*, i64*, i64*, i64*) #4 {
entry:
  call void @copy_out(i64* null, i64* %2, i64* null, i64* %3, i64* null, i64* %4, i64* null, i64* %5)
  call void @HW_dwt53_forward_hw_stub(i64 %0, i64 %1, i64* %2, i64* %3, i64* %4, i64* %5)
  call void @copy_in(i64* null, i64* %2, i64* null, i64* %3, i64* null, i64* %4, i64* null, i64* %5)
  ret void
}

attributes #0 = { argmemonly noinline willreturn "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #4 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
