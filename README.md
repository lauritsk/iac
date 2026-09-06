# Homelab IaC

```bash
cp secrets.auto.tfvars.example secrets.auto.tfvars
chmod 0600 secrets.auto.tfvars
mise install
mise run init
mise run plan
mise run apply
```
