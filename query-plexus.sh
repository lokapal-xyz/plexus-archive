#!/bin/bash

# Query Plexus Script for retrieving shard data
# Usage: ./query-plexus.sh <network> <action> [parameters...]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}Query Plexus Script for Retrieving Shard Data${NC}"
    echo ""
    echo "Usage: $0 <network> <action> [parameters...]"
    echo ""
    echo "Networks: base-sepolia, base"
    echo ""
    echo "Actions:"
    echo "  status                           - Show contract status and info"
    echo "  get-total                        - Get total number of shards"
    echo "  get-shard <index>                - Get specific shard by index"
    echo "  get-latest [count]               - Get latest shards (default: 5)"
    echo "  get-batch <start_index> <count>  - Get batch of shards"
    echo "  get-by-source <echo_source>      - Find shards by echo source"
    echo ""
    echo "Examples:"
    echo "  $0 base-sepolia status"
    echo "  $0 base-sepolia get-shard 0"
    echo "  $0 base-sepolia get-latest 10"
    echo "  $0 base-sepolia get-batch 0 5"
    echo "  $0 base-sepolia get-by-source \"Lobha Exchange Train Network\""
    echo ""
    exit 1
}

# Check minimum arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Insufficient arguments${NC}"
    show_usage
fi

NETWORK=$1
ACTION=$2

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
        ;;
    "base")
        RPC_URL="base"
        ;;
esac

# Validate action and set environment variables
case $ACTION in
    "status")
        export ACTION="status"
        ;;
    "get-total")
        export ACTION="get-total"
        ;;
    "get-shard")
        if [ $# -ne 3 ]; then
            echo -e "${RED}Error: get-shard requires index parameter${NC}"
            echo "Usage: $0 $NETWORK get-shard <index>"
            exit 1
        fi
        export ACTION="get-shard"
        export SHARD_INDEX="$3"
        ;;
    "get-latest")
        export ACTION="get-latest"
        if [ $# -ge 3 ]; then
            export COUNT="$3"
        fi
        ;;
    "get-batch")
        if [ $# -ne 4 ]; then
            echo -e "${RED}Error: get-batch requires start_index and count parameters${NC}"
            echo "Usage: $0 $NETWORK get-batch <start_index> <count>"
            exit 1
        fi
        export ACTION="get-batch"
        export START_INDEX="$3"
        export COUNT="$4"
        ;;
    "get-by-source")
        if [ $# -ne 3 ]; then
            echo -e "${RED}Error: get-by-source requires echo_source parameter${NC}"
            echo "Usage: $0 $NETWORK get-by-source \"<echo_source>\""
            exit 1
        fi
        export ACTION="get-by-source"
        export ECHO_SOURCE="$3"
        ;;
    *)
        echo -e "${RED}Error: Invalid action '$ACTION'${NC}"
        show_usage
        ;;
esac

echo -e "${BLUE}=== QUERYING PLEXUS ARCHIVE ===${NC}"
echo -e "${YELLOW}Network:${NC} $NETWORK"
echo -e "${YELLOW}Action:${NC} $ACTION"

# Show additional parameters if applicable
case $ACTION in
    "get-shard")
        echo -e "${YELLOW}Index:${NC} $SHARD_INDEX"
        ;;
    "get-latest")
        if [ -n "$COUNT" ]; then
            echo -e "${YELLOW}Count:${NC} $COUNT"
        else
            echo -e "${YELLOW}Count:${NC} 5 (default)"
        fi
        ;;
    "get-batch")
        echo -e "${YELLOW}Start Index:${NC} $START_INDEX"
        echo -e "${YELLOW}Count:${NC} $COUNT"
        ;;
    "get-by-source")
        echo -e "${YELLOW}Echo Source:${NC} $ECHO_SOURCE"
        ;;
esac

echo ""

# Execute the forge script (read-only, no broadcasting needed)
echo -e "${BLUE}Querying data...${NC}"

forge script script/InteractWithPlexus.s.sol:InteractWithPlexus \
    --rpc-url "$RPC_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Query completed successfully!${NC}"
else
    echo -e "${RED}❌ Query failed${NC}"
    exit 1
fi