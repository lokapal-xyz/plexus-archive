// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { PlexusArchive } from "../src/PlexusArchive.sol";

contract DeployPlexusArchive is Script {
    error DeployPlexusArchive__NotArchivist();
    
    function run() public returns (PlexusArchive) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        PlexusArchive plexusArchive = new PlexusArchive();
        
        vm.stopBroadcast();
        
        // Log deployment information
        console.log("=== PLEXUS ARCHIVE DEPLOYMENT ===");
        console.log("Contract deployed to:", address(plexusArchive));
        console.log("Deployed by (Archivist):", msg.sender);
        console.log("Block number:", block.number);
        console.log("Chain ID:", block.chainid);
        console.log("Deployment timestamp:", block.timestamp);
        
        // Verify the archivist is set correctly
        address archivist = plexusArchive.archivist();
        if (archivist != msg.sender) {
            revert DeployPlexusArchive__NotArchivist();
        }
        
        console.log("=== DEPLOYMENT COMPLETE ===");
        
        return plexusArchive;
    }
}