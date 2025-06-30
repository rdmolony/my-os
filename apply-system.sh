#!/bin/sh
pushd ~/NixOS

# HACK: nix flakes only recognise staged files
# https://github.com/NixOS/nix/issues/7107
git add -N .
sudo nixos-rebuild switch --install-bootloader --flake .#

popd
