#!/bin/bash
set -e

# We go to the root dir
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

SRC_DIR=pact

pact $SRC_DIR/utils/eth-address-utils.repl

pact $SRC_DIR/faucet/faucet.repl

pact $SRC_DIR/gas-oracle/gas-oracle.repl

pact $SRC_DIR/gas-oracle/gas-oracle-eth-kia.repl

pact $SRC_DIR/hyp-erc20/hyp-erc20.repl
pact $SRC_DIR/hyp-erc20-collateral/hyp-erc20-collateral.repl

pact $SRC_DIR/igp/igp.repl

pact $SRC_DIR/ism/domain-routing-ism.repl
pact $SRC_DIR/ism/merkle-tree-ism.repl
pact $SRC_DIR/ism/message-id-ism.repl

pact $SRC_DIR/mailbox/mailbox.repl

pact $SRC_DIR/merkle/merkle-tree-hook.repl

pact $SRC_DIR/validator-announce/validator-announce.repl

pact $SRC_DIR/flow/flow-col.repl
pact $SRC_DIR/flow/flow-syn.repl