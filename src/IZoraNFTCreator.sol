// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import './IERC721Drop.sol';
import './IMetadataRenderer.sol';

/// @notice Interface for ZORA Drops contract
interface IZoraNFTCreator {
    function setupDropsContract(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        uint64 editionSize,
        uint16 royaltyBPS,
        address payable fundsRecipient,
        IERC721Drop.SalesConfiguration memory saleConfig,
        IMetadataRenderer metadataRenderer,
        bytes memory metadataInitializer
    ) external returns (address);
}
 
