set dotenv-load
set dotenv-required

default:
    @just --list

init:
    tofu init

plan: init
    tofu plan

apply: init
    tofu apply

validate: init
    tofu validate

format:
    tofu fmt

format-check:
    tofu fmt -check

check: format-check validate
