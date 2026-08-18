# TODO

1. Work out how external HDD and SSD will work
  - HDD will store all media at /mnt/slow
  - SSD will store all configs and databases at /mnt/fast
  - Internal SSD will store OS's including VMs
2. Ensure fedora linux system role for podman conversion to containers.podman is correct and optimal
3. Setup opentofu to deploy flatcar on incusos declaratively and automatically activate ansible playbook after provisioning
4. Configure incus to enable secure boot and tpm for the vm
5. Configure flatcar to encrypt root etc using tpm and verify full bootchain
6. Figure out how to share incus-managed external ssd/hdd storage to flatcar vm
  - Instead, Incus passes the decrypted, mounted ZFS dataset directly from the host into your Flatcar VM using VirtioFS. VirtioFS provides native filesystem performance and full POSIX compatibility, allowing Flatcar to read and write directly to your host's ZFS dataset.
