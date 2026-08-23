# Incus workloads

## Provision the hv01 Beszel agent

Export the credentials without writing them to the repository:

```bash
export BESZEL_HV01_AGENT_KEY='<key>'
export BESZEL_HV01_AGENT_TOKEN='<token>'
```

Add Docker Hub as an OCI remote:

```bash
incus remote add oci-docker https://docker.io --protocol=oci
```

Create the persistent data volume:

```bash
incus storage volume create local beszel-agent-data
```

Create the OCI application container without starting it:

```bash
incus init \
  oci-docker:henrygd/beszel-agent:alpine \
  beszel-agent \
  < incus/beszel-agent/config.yml
```

Write the key and token into the mounted data volume:

```bash
printf '%s' "$BESZEL_HV01_AGENT_KEY" |
  incus storage volume file push - local beszel-agent-data/key \
    --uid 0 --gid 0 --mode 0400

printf '%s' "$BESZEL_HV01_AGENT_TOKEN" |
  incus storage volume file push - local beszel-agent-data/token \
    --uid 0 --gid 0 --mode 0400
```

Start the agent:

```bash
incus start beszel-agent
```

Check its state and logs:

```bash
incus list beszel-agent
incus console beszel-agent --show-log
```

Check SMART access:

```bash
incus exec beszel-agent -- smartctl -a /dev/nvme0
incus exec beszel-agent -- smartctl -a -d sntasmedia /dev/sda
incus exec beszel-agent -- smartctl -a -d sat /dev/sdb
```
