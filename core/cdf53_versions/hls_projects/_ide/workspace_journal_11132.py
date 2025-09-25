# 2025-09-25T08:35:55.965046
import vitis

client = vitis.create_client()
client.set_workspace(path="hls_projects")

comp = client.create_hls_component(name = "cdf53_forward",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

comp = client.get_component(name="cdf53_forward")
comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

vitis.dispose()

