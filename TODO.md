# TODO

## IncusOS VM provisioning

- Add OpenTofu configuration to provision the Flatcar VM declaratively.
- Configure UEFI Secure Boot and a persistent vTPM in the VM definition.
- Automate delivery of `config.ign` on first boot.
- Run the Ansible playbook only after Ignition has completed and SSH is ready.

## Shared storage

- Document the Incus disk devices used to expose `/mnt/fast` and `/mnt/slow` through VirtioFS.
- Confirm whether Flatcar can mount the VirtioFS tags directly at boot or whether the Incus agent is required.
