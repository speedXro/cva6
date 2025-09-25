# 2025-09-25T08:40:37.238065
import vitis

client = vitis.create_client()
client.set_workspace(path="hls_projects")

comp = client.get_component(name="cdf53_forward")
comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

comp = client.create_hls_component(name = "cdf53_inverse",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

comp = client.get_component(name="cdf53_inverse")
comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="CO_SIMULATION")

vitis.dispose()

