playbook := "site.yml"
collections_path := ".ansible/collections"

default:
    @just --list

# Install the pinned Ansible collections locally in this project.
install:
    ansible-galaxy collection install \
        --requirements-file requirements.yml \
        --collections-path {{collections_path}}

# Validate syntax and ensure Ansible can resolve every task and role.
validate:
    python3 -m json.tool files/serve.json >/dev/null
    ansible-playbook --syntax-check {{playbook}}
    ansible-playbook --list-tasks {{playbook}} >/dev/null

# Lint project-owned Ansible files.
lint:
    ansible-lint {{playbook}}

# Run all local, non-disruptive checks.
test: validate lint

# Preview changes against the homelab through Tailscale SSH.
check:
    ansible-playbook --check --diff {{playbook}}

# Apply the playbook to the homelab after an explicit confirmation.
apply:
    @read -p "Type apply to configure homelab: " reply; test "$reply" = apply
    ansible-playbook {{playbook}}
