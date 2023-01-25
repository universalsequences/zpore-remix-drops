// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IERC721Drop.sol';
import {console} from "forge-std/console.sol";
import './ZporeMetadataRenderer.sol';
import './ERC721DropMinterInterface.sol';

/**
   mostly taken from public assembly's TokenUriMint.sol
 */
contract ZporeMinter  {

    ZporeMetadataRenderer _metadataRenderer;

    mapping (address=>uint256) mintPricePerToken;

    /// @notice Action is unable to complete because msg.value is incorrect
    error WrongPrice();

    /// @notice Action is unable to complete because minter contract has not recieved minting role
    error MinterNotAuthorized();

    /// @notice Funds transfer not successful to drops contract
    error TransferNotSuccessful();

    /// @notice Caller is not an admin on target zora drop
    error Access_OnlyAdmin();

    // ||||||||||||||||||||||||||||||||
    // ||| EVENTS |||||||||||||||||||||
    // ||||||||||||||||||||||||||||||||

    /// @notice mint notice
    event Mint(address minter, address mintRecipient, uint256 tokenId, string tokenURI);
    
    /// @notice mintPrice updated notice
    event MintPriceUpdated(address sender, address targetZoraDrop, uint256 newMintPrice);

    /// @notice metadataRenderer updated notice
    event MetadataRendererUpdated(address sender, address newRenderer);    

    constructor(address renderer) {
        _metadataRenderer = ZporeMetadataRenderer(renderer);
    }
  
    function setMintPrice(address zoraDrop, uint256 newMintPricePerToken) public {
        // only let ZporeDropCreator do this once
         if (!ERC721DropMinterInterface(zoraDrop).isAdmin(msg.sender)) {
            revert Access_OnlyAdmin();
        }

        mintPricePerToken[zoraDrop] = newMintPricePerToken;

        emit MintPriceUpdated(msg.sender, zoraDrop, newMintPricePerToken);
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
        // note: the dropsContractAddress is the "Zpores Drop" created for a specific song

        // First mint a blank token
        address to = msg.sender;
        uint256 tokenId = IERC721Drop(dropsContractAddress)
            .adminMint(to, 1);

        // Then pass the metadata to the custom metadata renderer
        _metadataRenderer.updateTokenURI(
            dropsContractAddress, tokenId, data); 
    }

}
