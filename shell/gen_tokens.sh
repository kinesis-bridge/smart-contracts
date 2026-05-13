#!/bin/bash
set -e

# We go to the root dir
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

SRC_DIR=pact

# Argument 1 = Filename
# Argument 2 = Symbol Name
# Argument 3 = Precision
# Argument 4 = Chains
# Argument 5 = Freezable
gen_syn() {
   echo "Generate Synthetic token: $1"
   [[ "$5" == "true" ]] && to_freeze="-D_FREEZABLE_" || to_freeze=""
   m4 -DSYMBOL=$2 -DPRECISION=$3 -D_SUPPORTED_CHAINS_=$4 $to_freeze <(echo 'changequote([[, ]])dnl')  "$SRC_DIR/syn-template.pact" >  $SRC_DIR/hyp-erc20/$1.pact
}

# Argument 1 = Filename
# Argument 2 = Symbol Name
# Argument 3 = Precision
# Argument 4 = Chains
gen_col() {
   echo "Generate Collateral token: $1"
   m4 -DSYMBOL=$2 -DPRECISION=$3 -D_SUPPORTED_CHAINS_=$4 <(echo 'changequote([[, ]])dnl')  "$SRC_DIR/col-template.pact" >  $SRC_DIR/hyp-erc20-collateral/$1.pact
}

## Build the synthetics first
{
  jq -r '.mainnet[] | "\(.symbol) \(.decimals) \(.chains) \(.freezable)"' typescript/scripts/utils/tokenObjectsEVM.json
} | while read symbol decimals chains freezable; do gen_syn kb-$symbol kb-$symbol $decimals $chains $freezable; done
# The ETH token (not ERC-20)
gen_syn kb-ETH kb-ETH 18 '["2","4"]' false
#And the test file
gen_syn hyp-erc20 hyp-erc20 18 "[]" false
gen_syn hyp-erc20-freezable hyp-erc20 18 "[]" true



## And then the collaterals
{
  jq -r '.mainnet[] | "\(.symbol) \(.precision) \(.chains)"' typescript/scripts/utils/tokenObjectsKDA.json
} | while read symbol decimals chains; do gen_col kb-$symbol $symbol $decimals $chains; done
#And the test file
gen_col hyp-erc20-collateral hyp-erc20-collateral 18 "[]"
