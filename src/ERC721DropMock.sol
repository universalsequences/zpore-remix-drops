// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IMetadataRenderer} from "./IMetadataRenderer.sol";
import {IERC721Drop} from "./IERC721Drop.sol";

// @notice A mock implementation of IERC721Drop, used in testing.
contract ERC721DropMock is IERC721Drop {

    IMetadataRenderer metadataRenderer;

    constructor(IMetadataRenderer renderer, bytes memory data ) {
        metadataRenderer = renderer;
        metadataRenderer.initializeWithData(data);
    }

        /// @notice External purchase function (payable in eth)
        /// @param quantity to purchase
        /// @return first minted token ID
    function purchase(uint256 quantity) external payable returns (uint256) {
        return 0;
    }

    /// @notice Token URI Getter, proxies to metadataRenderer
    /// @param tokenId id of token to get URI for
    /// @return Token URI
    function tokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return metadataRenderer.tokenURI(tokenId);
    }

    /// @notice External purchase presale function (takes a merkle proof and matches to root) (payable in eth)
    /// @param quantity to purchase
    /// @param maxQuantity can purchase (verified by merkle root)
    /// @param pricePerToken price per token allowed (verified by merkle root)
    /// @param merkleProof input for merkle proof leaf verified by merkle root
    /// @return first minted token ID
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] memory merkleProof) external payable returns (uint256) {
        return 1;
    }

    /// @notice Function to return the global sales details for the given drop
    function saleDetails() external view returns (SaleDetails memory) {
        return SaleDetails({
            publicSaleActive: true,
            presaleActive: true,
            publicSalePrice: 1,
            publicSaleStart: 0,
            publicSaleEnd: 0,
            presaleStart: 1,
            presaleEnd: 1,
            presaleMerkleRoot: 0x0,
            maxSalePurchasePerAddress: 0,
            totalMinted: 0,
            maxSupply: 0
            });
    }
    
    /// @notice Function to return the specific sales details for a given address
    /// @param minter address for minter to return mint information for
    function mintedPerAddress(address minter)
        external
        view
    returns (AddressMintDetails memory) {
        return AddressMintDetails({
            totalMints: 1,
            presaleMints: 1,
            publicMints: 1
            });
    }

    /// @notice This is the opensea/public owner setting that can be set by the contract admin
    function owner() external view returns (address) {
        return address(0);
    }

    /// @notice Update the metadata renderer
    /// @param newRenderer new address for renderer
    /// @param setupRenderer data to call to bootstrap data for the new renderer (optional)
    function setMetadataRenderer(IMetadataRenderer newRenderer, bytes memory setupRenderer) external {
    }

    /// @notice This is an admin mint function to mint a quantity to a specific address
    /// @param to address to mint to
    /// @param quantity quantity to mint
    /// @return the id of the first minted NFT
    function adminMint(address to, uint256 quantity) external returns (uint256) {
        return 1;
    }

    /// @notice This is an admin mint function to mint a single nft each to a list of addresses
    /// @param to list of addresses to mint an NFT each to
    /// @return the id of the first minted NFT
    function adminMintAirdrop(address[] memory to) external returns (uint256) {
        return 0;
    }

    /// @dev Getter for admin role associated with the contract to handle metadata
    /// @return boolean if address is admin
    function isAdmin(address user) external view returns (bool) {
        return true;
    }

}
