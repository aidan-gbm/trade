#!/usr/bin/bash

# Get environment variable(s)
[[ -f .env ]] && source .env

# Global variables
SAND=true
API_REAL="https://cloud.iexapis.com/stable"
API_SAND="https://sandbox.iexapis.com/stable"
END_QUOTE="/stock/TICK/quote"

# Get quote
function quote {
    TICK=$1
    OUT=$(date +"%m/%d/%y")
    $SAND \
        && REQUEST=$(echo "$API_SAND$END_QUOTE?token=$TOKEN_SAND" | sed "s/TICK/$TICK/") \
        || REQUEST=$(echo "$API_REAL$END_QUOTE?token=$TOKEN_REAL" | sed "s/TICK/$TICK/")
    info=$(curl -sk $REQUEST | jq '.symbol, .iexOpen, .iexClose, .peRatio')
    for item in $info; do
        OUT="$OUT,$item"
    done
    echo $OUT
}

# Create and Append to CSV
[[ ! -f symbols.txt ]] && echo "[!] Missing symbols.txt" && exit
[[ ! -f log.csv ]] && echo "Date,Symbol,Open,Close,PE" > log.csv
for symbol in $(cat symbols.txt); do
    quote $symbol >> log.csv
done