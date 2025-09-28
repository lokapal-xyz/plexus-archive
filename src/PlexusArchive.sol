// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title Plexus Archive
 * @author lokapal.eth
 * @notice This is a contract that stores metadata from the Plexus' shards. Only the Archivist is allowed to add a new entry.
 * @notice The full shard text is outside this contract.
 */

contract PlexusArchive {
    ////////////
    // Errors //
    ////////////
    error PlexusArchive__NotArchivist();
    error PlexusArchive__NotZeroAddress();
    error PlexusArchive__ShardDoesNotExist();
    error PlexusArchive__StartIndexOutOfBounds();


    ///////////
    // Types //
    ///////////
    struct Shard {
        string shardTag;
        string echoSource;
        string earthTime;
        string lankaTime;
        string archivistLog;
    }


    /////////////////////
    // State Variables //
    /////////////////////
    Shard[] public shards;
    address public archivist;


    ////////////
    // Events //
    ////////////
    event ShardArchived(
        uint256 indexed shardIndex,
        string shardTag,
        string echoSource,
        string earthTime,
        string lankaTime,
        string archivistLog
    );

    event ArchivistTransferred(address indexed previousArchivist, address indexed newArchivist);


    ///////////////
    // Modifiers //
    ///////////////
    modifier onlyArchivist() {
        if (msg.sender != archivist) {
            revert PlexusArchive__NotArchivist();
        }
        _;
    }


    ///////////////
    // Functions //
    ///////////////
    constructor() {
        archivist = msg.sender;
    }

    /**
     * @dev Adds a new shard to the Plexus Archive
     * @param _shardTag Shard title
     * @param _echoSource Exact location of the transmition
     * @param _earthTime Real-world reception timestamp
     * @param _lankaTime Lanka transmition timestamp
     * @param _archivistLog Observations from the Archivist
     */
    function archiveShard(
        string memory _shardTag,
        string memory _echoSource,
        string memory _earthTime,
        string memory _lankaTime,
        string memory _archivistLog
    ) public onlyArchivist {
        shards.push(Shard(
            _shardTag,
            _echoSource,
            _earthTime,
            _lankaTime,
            _archivistLog
        ));

        emit ShardArchived(
            shards.length - 1,
            _shardTag,
            _echoSource,
            _earthTime,
            _lankaTime,
            _archivistLog
        );
    }

    /**
     * @dev Retrieves a shard by its index in the archive
     * @param index The index of the shard (0-based)
     */
    function getShard(uint256 index) public view returns (Shard memory) {
        if (index >= shards.length) {
            revert PlexusArchive__ShardDoesNotExist();
        }
        return shards[index];
    }

    /**
     * @dev Returns the total number of shards archived
     */
    function getTotalShards() public view returns (uint256) {
        return shards.length;
    }

    /**
     * @dev Retrieves multiple shards at once (for pagination)
     */
    function getShardsBatch(uint256 startIndex, uint256 count) 
        public 
        view 
        returns (Shard[] memory) 
    {
        if (startIndex >= shards.length) {
            revert PlexusArchive__StartIndexOutOfBounds();
        }
        
        uint256 endIndex = startIndex + count;
        if (endIndex > shards.length) {
            endIndex = shards.length;
        }
        
        uint256 batchSize = endIndex - startIndex;
        Shard[] memory batch = new Shard[](batchSize);
        
        for (uint256 i = 0; i < batchSize; i++) {
            batch[i] = shards[startIndex + i];
        }
        
        return batch;
    }

    /**
     * @dev Finds shards by Echo Source (returns indices)
     */
    function getShardsByEchoSource(string memory echoSource) 
        public 
        view 
        returns (uint256[] memory) 
    {
        uint256[] memory tempIndices = new uint256[](shards.length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < shards.length; i++) {
            if (keccak256(abi.encodePacked(shards[i].echoSource)) == 
                keccak256(abi.encodePacked(echoSource))) {
                tempIndices[count] = i;
                count++;
            }
        }
        
        // Create array with exact size
        uint256[] memory indices = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            indices[i] = tempIndices[i];
        }
        
        return indices;
    }


    /**
     * @dev Transfers archivist role
     */
    function transferArchivist(address newArchivist) public onlyArchivist {
        if (newArchivist == address(0)) {
            revert PlexusArchive__NotZeroAddress();
        }
        address previousArchivist = archivist;
        archivist = newArchivist;
        emit ArchivistTransferred(previousArchivist, newArchivist);
    }

    /**
     * @dev Gets the latest archived shards (most recent first)
     */
    function getLatestShards(uint256 count) public view returns (Shard[] memory) {
        if (shards.length == 0) {
            return new Shard[](0);
        }
        
        uint256 actualCount = count > shards.length ? shards.length : count;
        Shard[] memory latestShards = new Shard[](actualCount);
        
        for (uint256 i = 0; i < actualCount; i++) {
            latestShards[i] = shards[shards.length - 1 - i];
        }
        
        return latestShards;
    }
}
