alias c := check
alias ct := check-trace
alias f := fmt
alias u := update

default:
    @just --list

# Auto-format the source tree
fmt:
    git add .
    treefmt

check:
    @just fmt
    git add .
    statix check
    nix flake check

check-trace:
    @just fmt
    git add .
    statix check
    nix flake check --show-trace

update:
    nix flake update

cmt message:
    git commit -m "{{ message }}"
    git push
