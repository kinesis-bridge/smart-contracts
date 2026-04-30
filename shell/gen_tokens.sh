#!/bin/bash
set -e

# We go to the root dir
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

SRC_DIR=pact

gen_syn() {
   echo "Generate Synthetic token: $1"
   m4 -DSYMBOL=$1 -DPRECISION=$2 -D_SUPPORTED_CHAINS_=$3 <(echo 'changequote([[, ]])dnl')  "$SRC_DIR/syn-template.pact" >  $SRC_DIR/hyp-erc20/$1.pact
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
  jq -r '.mainnet[] | "\(.symbol) \(.decimals) \(.chains)"' typescript/scripts/utils/tokenObjectsEVM.json
} | while read symbol decimals chains; do gen_syn kb-$symbol $decimals $chains; done
# The ETH token (not ERC-20)
gen_syn kb-ETH 18 '["2","4"]'
#And the test file
gen_syn hyp-erc20 18 "[]"


## And then the collaterals
{
  jq -r '.mainnet[] | "\(.symbol) \(.decimals) \(.chains)"' typescript/scripts/utils/tokenObjectsKDA.json
} | while read symbol decimals chains; do gen_col kb-$symbol $symbol $decimals $chains; done
#And the test file
gen_col hyp-erc20-collateral hyp-erc20-collateral 18 "[]"
