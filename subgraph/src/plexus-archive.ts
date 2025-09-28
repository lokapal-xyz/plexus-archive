import { BigInt } from "@graphprotocol/graph-ts"
import {
  ShardArchived as ShardArchivedEvent,
  ArchivistTransferred as ArchivistTransferredEvent
} from "../generated/PlexusArchive/PlexusArchive"
import { 
  Shard, 
  ArchivistTransfer, 
  Archive 
} from "../generated/schema"

export function handleShardArchived(event: ShardArchivedEvent): void {
  // Create unique ID using transaction hash and log index
  let shard = new Shard(
    event.transaction.hash.toHexString() + "-" + event.logIndex.toString()
  )
  
  // Map event parameters to entity fields
  shard.shardIndex = event.params.shardIndex
  shard.shardTag = event.params.shardTag
  shard.echoSource = event.params.echoSource
  shard.earthTime = event.params.earthTime
  shard.lankaTime = event.params.lankaTime
  shard.archivistLog = event.params.archivistLog
  
  // Add blockchain metadata
  shard.blockNumber = event.block.number
  shard.blockTimestamp = event.block.timestamp
  shard.transactionHash = event.transaction.hash
  
  // Save the shard entity
  shard.save()
  
  // Update or create global archive statistics
  let archive = Archive.load("1")
  if (archive == null) {
    archive = new Archive("1")
    archive.totalShards = BigInt.fromI32(0)
    archive.currentArchivist = event.transaction.from
  }
  
  // Increment total shards counter
  archive.totalShards = archive.totalShards.plus(BigInt.fromI32(1))
  archive.lastUpdated = event.block.timestamp
  archive.save()
}

export function handleArchivistTransferred(event: ArchivistTransferredEvent): void {
  // Create unique ID for the transfer event
  let transfer = new ArchivistTransfer(
    event.transaction.hash.toHexString() + "-" + event.logIndex.toString()
  )
  
  // Map event parameters
  transfer.previousArchivist = event.params.previousArchivist
  transfer.newArchivist = event.params.newArchivist
  transfer.blockNumber = event.block.number
  transfer.blockTimestamp = event.block.timestamp
  transfer.transactionHash = event.transaction.hash
  
  // Save the transfer record
  transfer.save()
  
  // Update global archive stats with new archivist
  let archive = Archive.load("1")
  if (archive != null) {
    archive.currentArchivist = event.params.newArchivist
    archive.lastUpdated = event.block.timestamp
    archive.save()
  }
}