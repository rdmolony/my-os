#!/bin/sh
pushd ~/.nixos
nix build .#homeManagerConfigurations.rowanm.activationPackage
./result/activate
popd
