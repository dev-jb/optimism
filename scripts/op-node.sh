#!/bin/bash

./op-node/bin/op-node \
  --l2=$L2_RPC_WS_URL \
  --l2.jwt-secret=./op-node/jwt.txt \
  --sequencer.enabled \
  --sequencer.l1-confs=5 \
  --verifier.l1-confs=4 \
  --rollup.config=./op-node/rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=8547 \
  --p2p.disable \
  --rpc.enable-admin \
  --p2p.sequencer.key=$GS_SEQUENCER_PRIVATE_KEY \
  --l1=$L1_RPC_URL \
  --l1.beacon=$L1_BEACON_URL \
  --l1.rpckind=$L1_RPC_KIND