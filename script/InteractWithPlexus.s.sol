// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { PlexusArchive } from "../src/PlexusArchive.sol";

/**
 * @title PlexusArchive Interaction Script
 * @author lokapal.eth
 * @notice Script for interacting with deployed PlexusArchive contracts
 * @dev Use environment variables to specify the action and parameters
 */
contract InteractWithPlexus is Script {
    ////////////
    // Errors //
    ////////////
    error InteractWithPlexus__InvalidAction();
    error InteractWithPlexus__MissingParameter();
    error InteractWithPlexus__ContractNotFound();
    error InteractWithPlexus__InvalidIndex();

    ///////////////
    // Constants //
    ///////////////
    string constant ACTION_ARCHIVE = "archive";
    string constant ACTION_GET_SHARD = "get-shard";
    string constant ACTION_GET_TOTAL = "get-total";
    string constant ACTION_GET_LATEST = "get-latest";
    string constant ACTION_GET_BATCH = "get-batch";
    string constant ACTION_GET_BY_SOURCE = "get-by-source";
    string constant ACTION_STATUS = "status";

    function run() public {
        // Get the action to perform
        string memory action = vm.envString("ACTION");
        
        // Load contract address from deployment file or environment
        address contractAddress = _getContractAddress();
        PlexusArchive plexus = PlexusArchive(contractAddress);

        // Route to appropriate action
        if (_compareStrings(action, ACTION_ARCHIVE)) {
            _archiveShard(plexus);
        } else if (_compareStrings(action, ACTION_GET_SHARD)) {
            _getShard(plexus);
        } else if (_compareStrings(action, ACTION_GET_TOTAL)) {
            _getTotalShards(plexus);
        } else if (_compareStrings(action, ACTION_GET_LATEST)) {
            _getLatestShards(plexus);
        } else if (_compareStrings(action, ACTION_GET_BATCH)) {
            _getShardsBatch(plexus);
        } else if (_compareStrings(action, ACTION_GET_BY_SOURCE)) {
            _getShardsByEchoSource(plexus);
        } else if (_compareStrings(action, ACTION_STATUS)) {
            _getStatus(plexus);
        } else {
            revert InteractWithPlexus__InvalidAction();
        }
    }

    /**
     * @dev Archives a new shard (requires archivist permissions)
     */
    function _archiveShard(PlexusArchive plexus) internal {
        string memory shardTag = vm.envString("SHARD_TAG");
        string memory echoSource = vm.envString("ECHO_SOURCE");
        string memory earthTime = vm.envString("EARTH_TIME");
        string memory lankaTime = vm.envString("LANKA_TIME");
        string memory archivistLog = vm.envString("ARCHIVIST_LOG");

        console.log("=== ARCHIVING SHARD ===");
        console.log("Shard Tag:", shardTag);
        console.log("Echo Source:", echoSource);
        console.log("Earth Time:", earthTime);
        console.log("Lanka Time:", lankaTime);
        console.log("Archivist Log:", archivistLog);

        vm.startBroadcast();
        plexus.archiveShard(shardTag, echoSource, earthTime, lankaTime, archivistLog);
        vm.stopBroadcast();

        console.log("Shard archived successfully!");
        console.log("Total shards now:", plexus.getTotalShards());
    }

    /**
     * @dev Retrieves a specific shard by index
     */
    function _getShard(PlexusArchive plexus) internal view {
        uint256 index = vm.envUint("SHARD_INDEX");
        
        console.log("=== RETRIEVING SHARD ===");

        PlexusArchive.Shard memory shard = plexus.getShard(index);
        _displayShard(shard, index);
    }

    /**
     * @dev Gets the total number of archived shards
     */
    function _getTotalShards(PlexusArchive plexus) internal view {
        uint256 total = plexus.getTotalShards();
        console.log("=== TOTAL SHARDS ===");
        console.log("Total archived shards:", total);
    }

    /**
     * @dev Retrieves the latest shards
     */
    function _getLatestShards(PlexusArchive plexus) internal view {
        uint256 count = vm.envOr("COUNT", uint256(5)); // Default to 5
        
        console.log("=== LATEST SHARDS ===");
        console.log("Requesting count:", count);

        PlexusArchive.Shard[] memory shards = plexus.getLatestShards(count);
        console.log("Retrieved:", shards.length, "shards");
        
        for (uint256 i = 0; i < shards.length; i++) {
            console.log("Shard", i + 1, "of", shards.length);
            _displayShardBasic(shards[i]);
        }
    }

    /**
     * @dev Retrieves a batch of shards
     */
    function _getShardsBatch(PlexusArchive plexus) internal view {
        uint256 startIndex = vm.envUint("START_INDEX");
        uint256 count = vm.envUint("COUNT");
        
        console.log("=== SHARD BATCH ===");
        console.log("Start Index:", startIndex);
        console.log("Count:", count);

        PlexusArchive.Shard[] memory shards = plexus.getShardsBatch(startIndex, count);
        console.log("Retrieved:", shards.length, "shards");
        
        for (uint256 i = 0; i < shards.length; i++) {
            console.log("\n--- Shard at index", startIndex + i, "---");
            _displayShardBasic(shards[i]);
        }
    }

    /**
     * @dev Finds shards by echo source
     */
    function _getShardsByEchoSource(PlexusArchive plexus) internal view {
        string memory echoSource = vm.envString("ECHO_SOURCE");
        
        console.log("=== SHARDS BY ECHO SOURCE ===");
        console.log("Echo Source:", echoSource);

        uint256[] memory indices = plexus.getShardsByEchoSource(echoSource);
        console.log("Found", indices.length, "matching shards");
        
        if (indices.length > 0) {
            console.log("Shard indices:");
            for (uint256 i = 0; i < indices.length; i++) {
                console.log("- Index:", indices[i]);
            }
        }
    }

    /**
     * @dev Gets contract status and information
     */
    function _getStatus(PlexusArchive plexus) internal view {
        console.log("=== PLEXUS ARCHIVE STATUS ===");
        console.log("Contract Address:", address(plexus));
        console.log("Archivist:", plexus.archivist());
        console.log("Total Shards:", plexus.getTotalShards());
        console.log("Current Block:", block.number);
        console.log("Chain ID:", block.chainid);
        
        // Display network name
        if (block.chainid == 8453) {
            console.log("Network: Base Mainnet");
        } else if (block.chainid == 84532) {
            console.log("Network: Base Sepolia");
        } else {
            console.log("Network: Unknown");
        }
    }

    /**
     * @dev Displays complete shard information
     */
    function _displayShard(PlexusArchive.Shard memory shard, uint256 index) internal pure {
        console.log("Index:", index);
        console.log("Shard Tag:", shard.shardTag);
        console.log("Echo Source:", shard.echoSource);
        console.log("Earth Time:", shard.earthTime);
        console.log("Lanka Time:", shard.lankaTime);
        console.log("Archivist Log:", shard.archivistLog);
    }

    /**
     * @dev Displays basic shard information (for batch operations)
     */
    function _displayShardBasic(PlexusArchive.Shard memory shard) internal pure {
        console.log("Tag:", shard.shardTag);
        console.log("Source:", shard.echoSource);
    }

    /**
     * @dev Gets contract address from deployment files or environment
     */
    function _getContractAddress() internal view returns (address) {
        // Try to get from environment variable first
        try vm.envAddress("CONTRACT_ADDRESS") returns (address addr) {
            if (addr != address(0)) {
                return addr;
            }
        } catch {}

        // Try to load from deployment file based on chain ID
        string memory networkName;
        if (block.chainid == 8453) {
            networkName = "base";
        } else if (block.chainid == 84532) {
            networkName = "base-sepolia";
        } else {
            networkName = vm.toString(block.chainid);
        }

        string memory filePath = string.concat("deployments/", networkName, ".json");
        
        try vm.readFile(filePath) returns (string memory file) {
            // Parse JSON to get contract address
            return vm.parseJsonAddress(file, ".contractAddress");
        } catch {
            revert InteractWithPlexus__ContractNotFound();
        }
    }

    /**
     * @dev Utility function to compare strings
     */
    function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}