// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IERC721Drop.sol';
import {console} from "forge-std/console.sol";
import './ZporeMetadataRenderer.sol';

contract ZporeMinter  {

    ZporeMetadataRenderer _metadataRenderer;

    constructor(address renderer) {
        _metadataRenderer = ZporeMetadataRenderer(renderer);
    }
  
    /**
     * This is the point of entry to minting a remix.
     * Can be used by multiple drop contracts (for example, for different songs)
     */ 
    function purchase(
      address payable dropsContractAddress,
      ZporeMetadataRenderer.ZporeRemix memory data
      ) public payable
    {
        // First mint a blank token
        address to = msg.sender;
        uint256 tokenId = IERC721Drop(dropsContractAddress)
            .adminMint(to, 1);

        // Then pass the metadata to the custom metadata renderer
        _metadataRenderer.updateTokenURI(
            dropsContractAddress, tokenId, data); 
    }
}
