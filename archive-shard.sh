#!/bin/bash

# Archive Shard Script for Plexus Archive
# Usage: ./archive-shard.sh <network> <shard_tag> <echo_source> <earth_time> <lanka_time> <archivist_log>

set -e

source .env

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Archive Shard Script for Plexus Archive${NC}"
    echo ""
    echo "Usage: $0 <network> <shard_tag> <echo_source> <earth_time> <lanka_time> <archivist_log>"
    echo ""
    echo "Arguments:"
    echo "  network        : base-sepolia or base"
    echo "  shard_tag      : Shard title"
    echo "  echo_source    : Exact location of the transmition"
    echo "  earth_time     : Real-world reception timestamp"
    echo "  lanka_time     : Lanka transmition timestamp"
    echo "  archivist_log  : Observations from the Archivist"
    echo ""
    echo "Examples:"
    echo "  $0 base-sepolia \"Lighting a Cigar\" \"Lobha Exchange Train Network\" \"2025-09-27 00:51:53 UTC\" \"Varsam 7E9, Dinam 10E, Kala 040\" \"Honor is not fitting in a fool\""
    echo "  $0 base \"Test Shard\" \"Test Location\" \"Test Time 1\" \"Test Time 2\" \"Test observation\""
    echo ""
    exit 1
}

# Check arguments
if [ $# -ne 6 ]; then
    echo -e "${RED}Error: Incorrect number of arguments${NC}"
    show_usage
fi

NETWORK=$1
SHARD_TAG=$2
ECHO_SOURCE=$3
EARTH_TIME=$4
LANKA_TIME=$5
ARCHIVIST_LOG=$6

# Validate network
case $NETWORK in
    "base-sepolia"|"base")
        ;;
    *)
        echo -e "${RED}Error: Invalid network '$NETWORK'${NC}"
        echo "Supported networks: base-sepolia, base"
        exit 1
        ;;
esac

# Set RPC URL based on network
case $NETWORK in
    "base-sepolia")
        RPC_URL="base-sepolia"
        EXPLORER_URL="https://sepolia.basescan.org"
        ;;
    "base")
        RPC_URL="base"
        EXPLORER_URL="https://basescan.org"
        ;;
esac

echo -e "${BLUE}=== ARCHIVING SHARD TO PLEXUS ===${NC}"
echo -e "${YELLOW}Network:${NC} $NETWORK"
echo -e "${YELLOW}Shard Tag:${NC} $SHARD_TAG"
echo -e "${YELLOW}Echo Source:${NC} $ECHO_SOURCE"
echo -e "${YELLOW}Earth Time:${NC} $EARTH_TIME"
echo -e "${YELLOW}Lanka Time:${NC} $LANKA_TIME"
echo -e "${YELLOW}Archivist Log:${NC} $ARCHIVIST_LOG"
echo ""

# Confirmation prompt
read -p "Continue with archiving? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Archiving cancelled${NC}"
    exit 0
fi

# Set environment variables
export ACTION="archive"
export SHARD_TAG="$SHARD_TAG"
export ECHO_SOURCE="$ECHO_SOURCE"
export EARTH_TIME="$EARTH_TIME"
export LANKA_TIME="$LANKA_TIME"
export ARCHIVIST_LOG="$ARCHIVIST_LOG"

# Execute the forge script
echo -e "${BLUE}Executing archive transaction...${NC}"

forge script script/InteractWithPlexus.s.sol:InteractWithPlexus \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --broadcast

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Shard archived successfully!${NC}"
    echo ""
    echo -e "${BLUE}You can verify the transaction on: ${EXPLORER_URL}${NC}"
else
    echo -e "${RED}❌ Archive operation failed${NC}"
    exit 1
fi