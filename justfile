set dotenv-load

default:
    @just --list

init:
    tofu init

plan: init
    tofu plan

apply: init
    tofu apply

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
