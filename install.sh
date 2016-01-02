#!/bin/bash
if [ -n `ocamlfind query ppx_json_types` ]; then
  echo 'Removing previously installed versions of `modular-selectors`'
  ocamlfind remove modular-selectors
fi
ocamlfind install modular-selectors META
ocamlfind install modular-selectors -add ppx_modular_selectors.native
ocamlfind install modular-selectors -add _build/src/lib/*
