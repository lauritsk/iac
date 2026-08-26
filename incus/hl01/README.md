# hl01

incus init images:debian/13/cloud hl01 < incus/hl01/config.yaml
incus start hl01
incus exec hl01 -- cloud-init status --wait
incus list hl01
