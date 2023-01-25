# zpore-remix-drops

This set of contracts extends [Zora Drop Contracts](https://github.com/ourzora/zora-drops-contracts), to support minting 
remixes submitted by users, tied to a zorb.

The architecture is 1 contract per "original song", with common information about the song stored at that contract. The remixes that are minted
are directly linked to the original, by virtue of being on the same contract.

It uses a [custom metadata renderer](src/ZporeMetadataRenderer.sol) and [custom minter](src/ZporeMinter.sol) to do this. The custom minter calls "adminmint()" and sets the metadata for that 
newly minted tokenId, directly.

The main point of entry for users to mint is `ZporeMinter.purchase(dropContractAddress, ZporeMetadataRenderer.ZporeRemix)`.

Remixes are stored in a struct called `ZporeRemix`:
```
struct ZporeRemix {
  string contentURI; // pinata/arweave link to remix recording
  string coverArtURI; // pinata/arweave link to cover art
  string caption; // caption written by user
  uint256 zorbId; // the zorb used to remix
}
```

Metadata is stored on-chain, and rendered with `ZporeMetadataRenderer.tokenURI(uint256)`. 

Inspired by Jem's excellent [Metabolism presentation](https://www.youtube.com/watch?v=s0Ye2Z02MwA).

# Helper Contracts

[ZporeDropCreator](src/ZporeDropCreator.sol), lets you create a drop quickly with the song & artist name, 
and other song related information.

```
function newDrop(
      string memory name,
      string memory symbol,
      string memory songName,
      string memory artistName,
      string memory description,
      address fundsRecipient,
      address defaultAdmin,
      address metadataRenderer
      ) public payable { ... }
```

This calls IZoraNFTCreator.setupDropsContract(...) under the hood, but with all the relevant data piped in, and some constants set.

When calling this function from etherscan, check the logs generated to find the `CreatedDrop` log event. This event 
will contain the address of the newly created Drops contract-- i.e. where all the minted tokens will eventually live.

# Foundry Commands

##ZporeMetadataRenderer 
```
forge create --rpc-url $RPC_ENDPOINT --private-key $PRIVATE_KEY src/ZporeMetadataRenderer.sol:ZporeMetadataRenderer --etherscan-api-key $ETHERSCAN_KEY --verify
```
[etherscan](https://goerli.etherscan.io/address/0xcF8D2cEA944371CC31A69a6C7b8dE7724eE5C6a5)

##ZporeMinter
```
forge create --rpc-url $RPC_ENDPOINT --private-key $PRIVATE_KEY src/ZporeMinter.sol:ZporeMinter --constructor-args *ADDRESS_OF_METADATA_RENDERER*  --etherscan-api-key $ETHERSCAN_KEY --verify
```
[etherscan](https://goerli.etherscan.io/address/0x01F734f1183B60B40D2B35FB20C7c6Ea82E910a9)

##ZporeDropCreator
```
forge create --rpc-url $RPC_ENDPOINT --private-key $PRIVATE_KEY src/ZporeDropCreator.sol:ZporeDropCreator --constructor-args 0xEf440fbD719cC5c3dDCD33b6f9986Ab3702E97A5  --etherscan-api-key $ETHERSCAN_KEY --verify
```
*Note: 0xEf440fbD719cC5c3dDCD33b6f9986Ab3702E97A5 refers to the Goerli deployed zora creatorImpl contract*
[etherscan](https://goerli.etherscan.io/address/0x9630e9d71d9cd144bcbbe696812b8aba8ad0e7fb#writeContract)

# Todo

Token gate contract to only zorb holders.



