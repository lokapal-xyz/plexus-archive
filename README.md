# Plexus Archive

A Solidity smart contract for archiving metadata of micro-stories and narrative fragments on Base blockchain networks. Only designated Archivists can add new entries, making it perfect for curated storytelling projects, digital literature archives, or any content that requires immutable timestamping and provenance.

---

## Features

- **Archivist-Only Access**: Only the designated archivist can archive new shards
- **Immutable Metadata Storage**: Each shard contains title, source, timestamps, and observations
- **Fast Timestamping**: Python script to calculate UTC and Lanka time timestamps
- **Multi-Network Support**: Deploy to Base Sepolia (testnet) and Base Mainnet
- **Contract Verification**: Automatic source code verification on BaseScan
- **Query Functions**: Retrieve shards by index, batch, latest, or by echo source

---

## Project Structure

```
├── src/
│   └── PlexusArchive.sol           # Main contract
├── script/
│   ├── DeployPlexusArchive.s.sol   # Deployment script
│   └── InteractWithPlexus.s.sol    # Interaction script for queries/archiving
├── test/
│   └── PlexusArchiveTest.t.sol     # Comprehensive test suite
├── deployments/                    # Network-specific deployment info
├── .env.example                    # Environment variables framework
├── deploy-archive.sh               # Multi-network deployment script
├── archive-shard.sh                # Archive new shards
├── query-plexus.sh                 # Query existing shards
├── foundry.toml                    # Foundry settings
└── shard-time.sh                   # Calculate UTC and Lanka time
```

---

## Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Base Sepolia ETH ([faucet](https://faucet.quicknode.com/base))
- BaseScan API key ([sign up](https://etherscan.io/apis?id=8453))

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/lokapal-xyz/plexus-archive
cd plexus-archive
```

2. **Install Foundry dependencies:**
```bash
forge install
```

3. **Create environment file:**
```bash
cp .env.example .env
# Edit .env with your private key and API key
```

4. **Make scripts executable:**
```bash
chmod +x deploy-archive.sh archive-shard.sh query-plexus.sh
```

5. **Run tests:**
```bash
forge test
```

### Environment Configuration

Complete the `.env` file with the following content:

```bash
# Private Key (create a dedicated wallet for this project)
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# API Keys
BASESCAN_API_KEY=your_basescan_api_key_here

# RPC URLs (optional - uses public endpoints by default)
BASE_SEPOLIA_RPC_URL=https://base-sepolia.g.alchemy.com/v2/YOUR_KEY
BASE_RPC_URL=https://base-mainnet.g.alchemy.com/v2/YOUR_KEY

# Contract Addresses (auto-populated after deployment)
CONTRACT_ADDRESS_BASE_SEPOLIA=
CONTRACT_ADDRESS_BASE=

## Active Contract Address (auto-populated after deployment)
CONTRACT_ADDRESS=

```

### Deployment

Deploy to Base Sepolia (testnet) first:

```bash
./deploy-archive.sh base-sepolia
```

For mainnet deployment (uses real ETH):

```bash
./deploy-archive.sh base
```

The script will:
- Deploy and verify the contract
- Create deployment JSON files
- Update your `.env` with contract addresses
- Provide BaseScan links

---

## Usage

### Archive New Shard

Calculate UTC and Lanka Time:

```bash
python3 shard-time.py
```

Template command (edit values before running):

```bash
./archive-shard.sh base-sepolia "SHARD_TITLE" "ECHO_SOURCE" "UTC_TIME" "LANKA_TIME" "ARCHIVIST_LOG"
```

Example:
```bash
./archive-shard.sh base-sepolia "Lighting a Cigar" "Lobha Exchange Train Network" "2025-09-27 00:51:53 UTC" "Varsam 7E9, Dinam 10E, Kala 040" "Honor is not fitting in a fool"
```

### Query Shards

Get contract status:
```bash
./query-plexus.sh base-sepolia status
```

Get latest shards:
```bash
./query-plexus.sh base-sepolia get-latest 5
```

Get specific shard by index:
```bash
./query-plexus.sh base-sepolia get-shard 0
```

Get shards by echo source:
```bash
./query-plexus.sh base-sepolia get-by-source "Lobha Exchange Train Network"
```

All available query commands:
- `status` - Contract information and stats
- `get-total` - Total number of archived shards
- `get-shard <index>` - Specific shard by index
- `get-latest [count]` - Latest shards (default: 5)
- `get-batch <start> <count>` - Batch of shards
- `get-by-source "<source>"` - Find shards by echo source

---

## Contract API

### Shard Structure

```solidity
struct Shard {
    string shardTag;        // Shard title
    string echoSource;      // Exact location of the transmition
    uint256 earthTime;      // Real-world reception timestamp
    string lankaTime;       // Lanka transmition timestamp
    string archivistLog;    // Observations from the Archivist
}
```

### Main Functions

- `archiveShard()` - Add new shard (archivist only)
- `getShard(uint256 index)` - Get shard by index
- `getTotalShards()` - Get total number of shards
- `getLatestShards(uint256 count)` - Get latest shards
- `getShardsBatch(uint256 start, uint256 count)` - Get batch of shards
- `getShardsByEchoSource(string source)` - Find shards by source
- `transferArchivist(address newArchivist)` - Transfer archivist role

---

## Integration with Frontend Applications

### The Graph Integration

For production applications, integrate with The Graph for efficient querying:

1. Create a subgraph indexing the `ShardArchived` events
2. Use GraphQL queries for complex filtering and pagination
3. Implement real-time updates with subscriptions

- To view the full Subgraph implementation, [**click here**](subgraph-deployment-guide.md)

### Next.js Integration

Keep contracts and frontend in separate repositories:

```
my-website/           # Next.js app
├── lib/
│   └── contracts/    # Copy deployment JSONs here
└── components/

plexus-contracts/     # This repository
```

Copy deployment files when needed:
```bash
cp deployments/base.json ../my-website/lib/contracts/
```

---

## Network Information

### Base Sepolia (Testnet)
- Chain ID: 84532
- RPC: https://sepolia.base.org
- Explorer: https://sepolia.basescan.org
- Faucet: https://faucet.quicknode.com/base

### Base Mainnet
- Chain ID: 8453
- RPC: https://mainnet.base.org
- Explorer: https://basescan.org

---

## Security Considerations

- **Archivist Role**: Only the archivist can add shards. Transfer this role carefully
- **Private Key**: Use a dedicated wallet for contract operations
- **Testnet First**: Always test on Base Sepolia before mainnet deployment
- **Gas Optimization**: Contract uses efficient storage patterns and batch operations

---

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test testArchiveShard

# Run with verbose output
forge test -vvv
```

Tests cover:
- Contract deployment and initialization
- Shard archiving with various inputs
- Access control (archivist-only functions)
- Retrieval functions and edge cases
- Batch operations and pagination
- Event emission
- Fuzz testing for edge cases

---

## Misc

### Gas Costs

Typical gas usage:
- Contract deployment: ~1.25M gas
- Archive shard: ~100K gas
- Query functions: <50K gas (read-only)

---

### Use Cases

This contract pattern is suitable for:
- Digital literature and storytelling projects
- Content archiving with provenance
- Timestamped metadata storage
- Curated digital art projects
- Academic research with immutable records
- Creative writing communities
- Interactive fiction projects

### License

MIT License - see LICENSE file for details

### Support

- Create an issue for bugs or feature requests
- Check existing issues before creating new ones
- Provide detailed information including network, transaction hashes, and error messages

---

Built with Foundry by lokapal.eth