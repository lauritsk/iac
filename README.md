# Homelab IaC

Requires [`mise`](https://mise.jdx.dev/) and Tailscale access to `homelab`.

Install the tools and Ansible collections:

```sh
mise install
mise run install
```

Generate the Ignition configuration:

```sh
mise run ignition:generate
```

Validate, preview, and deploy:

```sh
mise run validate
mise run deploy:check
mise run deploy
```

`mise run deploy` requires confirmation. Keep the local, untracked `ansible_vault_passphrase` file available for Ansible commands.
