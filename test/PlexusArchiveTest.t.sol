// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { PlexusArchive } from "../src/PlexusArchive.sol";

contract PlexusArchiveTest is Test {
    PlexusArchive public plexusArchive;
    address public archivist;
    address public unauthorized;

    // Test shard data
    string constant TEST_SHARD_TAG = "Lighting a Cigar";
    string constant TEST_ECHO_SOURCE = "Lobha Exchange Train Network";
    string constant TEST_EARTH_TIME = "2025-09-27 00:51:53 UTC";
    string constant TEST_LANKA_TIME = "Varsam 7E9, Dinam 10E, Kala 040";
    string constant TEST_ARCHIVIST_LOG = "Honor is not fitting in a fool";

    function setUp() public {
        archivist = makeAddr("archivist");
        unauthorized = makeAddr("unauthorized");
        
        vm.prank(archivist);
        plexusArchive = new PlexusArchive();
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT TESTS
    //////////////////////////////////////////////////////////////*/

    function test_InitialState() public view {
        assertEq(plexusArchive.archivist(), archivist);
        assertEq(plexusArchive.getTotalShards(), 0);
    }

    /*//////////////////////////////////////////////////////////////
                          SHARD ARCHIVING TESTS
    //////////////////////////////////////////////////////////////*/

    function test_ArchiveShard_Success() public {
        vm.prank(archivist);
        plexusArchive.archiveShard(
            TEST_SHARD_TAG,
            TEST_ECHO_SOURCE,
            TEST_EARTH_TIME,
            TEST_LANKA_TIME,
            TEST_ARCHIVIST_LOG
        );

        assertEq(plexusArchive.getTotalShards(), 1);
        
        PlexusArchive.Shard memory shard = plexusArchive.getShard(0);
        assertEq(shard.shardTag, TEST_SHARD_TAG);
        assertEq(shard.echoSource, TEST_ECHO_SOURCE);
        assertEq(shard.earthTime, TEST_EARTH_TIME);
        assertEq(shard.lankaTime, TEST_LANKA_TIME);
        assertEq(shard.archivistLog, TEST_ARCHIVIST_LOG);
    }

    function test_ArchiveShard_RevertWhen_NotArchivist() public {
        vm.prank(unauthorized);
        vm.expectRevert(PlexusArchive.PlexusArchive__NotArchivist.selector);
        
        plexusArchive.archiveShard(
            TEST_SHARD_TAG,
            TEST_ECHO_SOURCE,
            TEST_EARTH_TIME,
            TEST_LANKA_TIME,
            TEST_ARCHIVIST_LOG
        );
    }

    function test_ArchiveShard_EmitsEvent() public {
        vm.prank(archivist);
        
        vm.expectEmit(true, true, false, true);
        emit PlexusArchive.ShardArchived(
            0,
            TEST_SHARD_TAG,
            TEST_ECHO_SOURCE,
            TEST_EARTH_TIME,
            TEST_LANKA_TIME,
            TEST_ARCHIVIST_LOG
        );
        
        plexusArchive.archiveShard(
            TEST_SHARD_TAG,
            TEST_ECHO_SOURCE,
            TEST_EARTH_TIME,
            TEST_LANKA_TIME,
            TEST_ARCHIVIST_LOG
        );
    }

    /*//////////////////////////////////////////////////////////////
                            RETRIEVAL TESTS
    //////////////////////////////////////////////////////////////*/

    function test_GetShard_RevertWhen_InvalidIndex() public {
        vm.expectRevert(PlexusArchive.PlexusArchive__ShardDoesNotExist.selector);
        plexusArchive.getShard(0);
    }

    function test_GetShardsBatch_Success() public {
        // Archive multiple shards
        _archiveTestShards(3);

        PlexusArchive.Shard[] memory batch = plexusArchive.getShardsBatch(0, 2);
        assertEq(batch.length, 2);
        assertEq(batch[0].shardTag, "Shard 0");
        assertEq(batch[1].shardTag, "Shard 1");
    }

    function test_GetShardsBatch_RevertWhen_StartIndexOutOfBounds() public {
        vm.expectRevert(PlexusArchive.PlexusArchive__StartIndexOutOfBounds.selector);
        plexusArchive.getShardsBatch(0, 1);
    }

    function test_GetLatestShards() public {
        _archiveTestShards(5);

        PlexusArchive.Shard[] memory latest = plexusArchive.getLatestShards(3);
        assertEq(latest.length, 3);
        // Should return most recent first
        assertEq(latest[0].shardTag, "Shard 4");
        assertEq(latest[1].shardTag, "Shard 3");
        assertEq(latest[2].shardTag, "Shard 2");
    }

    function test_GetShardsByEchoSource() public {
        // Archive shards with different echo sources
        vm.startPrank(archivist);
        
        plexusArchive.archiveShard("Shard A", "Lobha District", "T1", "T4", "Log A");
        plexusArchive.archiveShard("Shard B", "Ahamkara District", "T2", "T5", "Log B");
        plexusArchive.archiveShard("Shard C", "Lobha District", "T3", "T6", "Log C");
        
        vm.stopPrank();

        uint256[] memory indices = plexusArchive.getShardsByEchoSource("Lobha District");
        assertEq(indices.length, 2);
        assertEq(indices[0], 0);
        assertEq(indices[1], 2);
    }

    /*//////////////////////////////////////////////////////////////
                         ARCHIVIST MANAGEMENT TESTS
    //////////////////////////////////////////////////////////////*/

    function test_TransferArchivist_Success() public {
        address newArchivist = makeAddr("newArchivist");
        
        vm.prank(archivist);
        vm.expectEmit(true, true, false, false);
        emit PlexusArchive.ArchivistTransferred(archivist, newArchivist);
        
        plexusArchive.transferArchivist(newArchivist);
        
        assertEq(plexusArchive.archivist(), newArchivist);
    }

    function test_TransferArchivist_RevertWhen_ZeroAddress() public {
        vm.prank(archivist);
        vm.expectRevert(PlexusArchive.PlexusArchive__NotZeroAddress.selector);
        
        plexusArchive.transferArchivist(address(0));
    }

    function test_TransferArchivist_RevertWhen_NotArchivist() public {
        vm.prank(unauthorized);
        vm.expectRevert(PlexusArchive.PlexusArchive__NotArchivist.selector);
        
        plexusArchive.transferArchivist(unauthorized);
    }

    /*//////////////////////////////////////////////////////////////
                              FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    function testFuzz_ArchiveShard(
        string memory _shardTag,
        string memory _echoSource,
        string memory _earthTime,
        string memory _lankaTime,
        string memory _archivistLog
    ) public {
        vm.assume(bytes(_shardTag).length > 0);
        vm.assume(bytes(_echoSource).length > 0);
        vm.assume(bytes(_lankaTime).length > 0);
        vm.assume(bytes(_archivistLog).length > 0);

        vm.prank(archivist);
        plexusArchive.archiveShard(_shardTag, _echoSource, _earthTime, _lankaTime, _archivistLog);

        assertEq(plexusArchive.getTotalShards(), 1);
        PlexusArchive.Shard memory shard = plexusArchive.getShard(0);
        assertEq(shard.shardTag, _shardTag);
        assertEq(shard.echoSource, _echoSource);
        assertEq(shard.earthTime, _earthTime);
        assertEq(shard.lankaTime, _lankaTime);
        assertEq(shard.archivistLog, _archivistLog);
    }

    /*//////////////////////////////////////////////////////////////
                              HELPERS
    //////////////////////////////////////////////////////////////*/

    function _archiveTestShards(uint256 count) internal {
        vm.startPrank(archivist);
        for (uint256 i = 0; i < count; i++) {
            plexusArchive.archiveShard(
                string(abi.encodePacked("Shard ", vm.toString(i))),
                "Test Location",
                string(abi.encodePacked("Earth Time ", vm.toString(i))),
                string(abi.encodePacked("Lanka Time ", vm.toString(i))),
                "Test log"
            );
        }
        vm.stopPrank();
    }
}