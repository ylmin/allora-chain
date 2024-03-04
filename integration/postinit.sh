#!/usr/bin/env bash

set -e

GENESIS=$HOME/.allorad/config/genesis.json
# this script expects to be ran AFTER `scripts/init.sh`
if ! test -f $GENESIS; then
  echo "Must run scripts/init.sh first."
  exit 1
fi

ALLORAD_BIN=$(which allorad)

ALICE_ADDRESS=$($ALLORAD_BIN keys show alice | head -n 1 | cut -f 2 -d ":" | tr -d " ")
BOB_ADDRESS=$($ALLORAD_BIN keys show bob | head -n 1 | cut -f 2 -d ":" | tr -d " ")
echo "Got test keys pub address: $ALICE_ADDRESS and $BOB_ADDRESS"
echo

echo "Putting alice and bob in the whitelisted core team list"
GENESIS_TOTAL_LINES=$(wc -l $GENESIS | cut -f 1 -d " ")
CORE_TEAM_LINE_NUM=$(grep -n "core_team_addresses" $GENESIS | cut -f 1 -d ":")
cat $GENESIS | head -n $CORE_TEAM_LINE_NUM > $GENESIS.tmp
echo "        \"$ALICE_ADDRESS\"," >> $GENESIS.tmp
echo "        \"$BOB_ADDRESS\"," >> $GENESIS.tmp
CONTINUE_LINE_NUM=$(($GENESIS_TOTAL_LINES-$CORE_TEAM_LINE_NUM+1))
tail -n $CONTINUE_LINE_NUM $GENESIS >> $GENESIS.tmp
mv $GENESIS.tmp $GENESIS


echo "Starting allorad daemon and sleep for 3 seconds to let it start"
$ALLORAD_BIN start & disown;
sleep 3