# Homelab IaC

Requires Python 3, `just`, and Tailscale access to `homelab`.

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
just install
```

Validate and preview before applying:

```sh
just test
just check
just apply
```

`just apply` requires an explicit confirmation. Keep the local, untracked `ansible_vault_passphrase` file available for all Ansible commands.
