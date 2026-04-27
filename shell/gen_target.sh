#!/bin/bash
set -e

# We go to the root dir
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

SRC_DIR=pact
TARGET_DIR=pact_target
NAMESPACE=n_e595727b657fbbb3b8e362a05a7bb8d12865c1ff
KIA_NAMESPACE=n_40c883decc192e1e3214898f04656b2e9ea7b74e

## Update the namespace in target_dir

find $SRC_DIR -type f -name "*.pact" | while read f; do
  out="$TARGET_DIR/${f#$SRC_DIR/}"
  mkdir -p "$(dirname "$out")"
  m4 -DNAMESPACE=$NAMESPACE -DKIA_NAMESPACE=$KIA_NAMESPACE <(echo 'changequote([[, ]])') "$f" > "$out"
done