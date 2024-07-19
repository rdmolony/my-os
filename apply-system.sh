#!/bin/sh
pushd ~/.nixos

# HACK: nix flakes only recognise staged files
# https://github.com/NixOS/nix/issues/7107
git add -N .
sudo nixos-rebuild switch --flake .#

popd
