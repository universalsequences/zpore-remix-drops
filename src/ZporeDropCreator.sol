// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; import './IZoraNFTCreator.sol';
import './IERC721Drop.sol';
import {console} from "forge-std/console.sol";
import './IZporeDrop.sol';
import './ZporeMinter.sol';
import {ERC721Drop} from "zora-drops-contracts/ERC721Drop.sol";

contract ZporeDropCreator {

    IZoraNFTCreator creator;
    IERC721Drop.SalesConfiguration salesConfig;
    address zporeMinterAddress;

    bytes32 public immutable DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public immutable MINTER_ROLE = keccak256("MINTER");

    // creatorAddress is the address of the zora-deployed "drop creator" 
    constructor(address creatorAddress, address _zporeMinterAddress) {
        creator = IZoraNFTCreator(creatorAddress);
        zporeMinterAddress = _zporeMinterAddress;

        salesConfig = IERC721Drop.SalesConfiguration({
            publicSalePrice: 0,
            maxSalePurchasePerAddress: 1000,
            publicSaleStart: 0,
            publicSaleEnd: 5000000000000,
            presaleStart: 0,
            presaleEnd: 0,
            presaleMerkleRoot: 0x0
            });
    }
  
    // A reusable function for creating new drops using Zoras Drop contracts
    // with the initial media set 
    function newDrop(
      IZporeDrop.Drop memory drop,
      address defaultAdmin,
      address metadataRenderer,
      uint64 maxEditionSize
      ) public payable returns (address)
    {
        // need to register shit with ZporeMinter at "defaultAdmin"

        bytes memory metadataInitializer = abi.encode(
            drop.title,
            drop.artist,
            drop.description,
            "contractURI" // is this relevant? // wtf is this??
        );

        // defaultAdmin will be the "ZporeMinter"
        address newDropAddress = creator.setupDropsContract(
          drop.name,
          drop.symbol,
          defaultAdmin,
          maxEditionSize, // editionSize
          500, // bps (not relevant). question: how do we handle bps in general if we're not taking advantage of zora
          payable(drop.fundsRecipient),
          salesConfig,
          IMetadataRenderer(metadataRenderer),
          metadataInitializer
       );

        // give tokenURIMinter minter role on zora drop
        ERC721Drop(payable(newDropAddress)).grantRole(MINTER_ROLE, zporeMinterAddress);

        // while this contract is still admin, set the mint price (we will then
        // immediately revoke admin and set it to the passed defaultAdmin address)
        ZporeMinter(newDropAddress).setMintPrice(newDropAddress, drop.mintPricePerToken);

        // grant admin role to desired admin address
        ERC721Drop(payable(newDropAddress)).grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);

        // revoke admin role from address(this) as it differed from desired admin address
        ERC721Drop(payable(newDropAddress)).revokeRole(DEFAULT_ADMIN_ROLE, address(this));

        // return the new drop address so that Stems contract can tie the "song" to the
        // remixes address
        return newDropAddress;
    }
}
