#!/bin/sh
pushd ~/NixOS

nix build .#homeManagerConfigurations.rowanm.activationPackage
./result/activate
rm -fr ./result
popd
