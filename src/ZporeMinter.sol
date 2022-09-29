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
  
    // upon minting a token, the custom minter will immediately call this function and pass
    // it the spores remix data to set that tokenId
    function purchase(
      address payable target,
      ZporeMetadataRenderer.ZporeRemix memory data
      ) public payable
    {
        address to = msg.sender;
        uint256 tokenId = IERC721Drop(target).adminMint(to, 1);
        // how do we get the 

        _metadataRenderer.updateTokenURI(target, tokenId, data); 
    }
}
