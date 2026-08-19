# TODO

- Setup opentofu to deploy flatcar on incusos declaratively and automatically activate ansible playbook after provisioning
- Configure incus to enable secure boot and tpm for the vm
- Configure flatcar to encrypt root etc using tpm and verify full bootchain
- Document how incus will share /mnt/slow and /mnt/fast with flatcar (incus-agent or manual mount)
