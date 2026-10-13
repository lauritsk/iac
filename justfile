set dotenv-load

default:
    @just --list

init:
    tofu init

plan: init blog-build
    tofu plan

apply: init blog-build
    tofu apply

blog-build:
    mkdir -p blog/public
    docker run --rm --user "$(id -u):$(id -g)" -v "{{ justfile_directory() }}/blog:/data" registry.access.redhat.com/hi/hugo:latest@sha256:396e58615dbb2323a0da641606bd5ae5d291132db52e2c08131e4070291eaafd --minify --cleanDestinationDir --cacheDir /tmp/hugo-cache

format:
    tofu fmt
    just --fmt
    hujsonfmt -w policy.hujson

check: init
    tofu fmt -check
    just --fmt --check
    hujsonfmt -d policy.hujson
    test -z "$(hujsonfmt -l policy.hujson)"
    tofu validate
