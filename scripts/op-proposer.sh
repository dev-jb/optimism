#!/bin/bash

./op-proposer/bin/op-proposer \
  --poll-interval=12s \
  --rpc.port=8560 \
  --rollup-rpc=$ROLLUP_RPC_URL \
  --l2oo-address=$L2_OO_ADDRESS \
  --private-key=$GS_PROPOSER_PRIVATE_KEY \
  --l1-eth-rpc=$L1_RPC_URL