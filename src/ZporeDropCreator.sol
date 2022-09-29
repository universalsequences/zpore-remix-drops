// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; import './IZoraNFTCreator.sol';
import './IERC721Drop.sol';
import {console} from "forge-std/console.sol";

contract ZporeDropCreator {

    IZoraNFTCreator creator;
    IERC721Drop.SalesConfiguration salesConfig;
    bytes metadataInitializer;

    constructor(address creatorAddress) {
        creator = IZoraNFTCreator(creatorAddress);

        metadataInitializer = abi.encode(
           "Test/",
           "check",
           "YOOO",
           "SUP");
                                                      
        salesConfig = IERC721Drop.SalesConfiguration({
            publicSalePrice: 0,
            maxSalePurchasePerAddress: 10,
            publicSaleStart: 0,
            publicSaleEnd: 0,
            presaleStart: 0,
            presaleEnd: 0,
            presaleMerkleRoot: 0x0
            });
    }
  
    // upon minting a token, the custom minter will immediately call this function and pass
    // it the spores remix data to set that tokenId
    function newDrop(
      address defaultAdmin,
      address metadataRenderer
      ) public payable
    {

        creator.setupDropsContract(
          "TEST",
          "yo",
          defaultAdmin,
          100,
          500,
          payable(msg.sender),
          salesConfig,
          IMetadataRenderer(metadataRenderer),
          metadataInitializer);
    }
}
