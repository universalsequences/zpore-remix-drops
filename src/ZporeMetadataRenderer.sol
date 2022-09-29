// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IMetadataRenderer.sol';
import './Base64.sol';
import './Conversion.sol';
import {MetadataRenderAdminCheck} from './MetadataRenderAdminCheck.sol';

contract ZporeMetadataRenderer is IMetadataRenderer, MetadataRenderAdminCheck {

    struct ZporeRemix {
        string contentURI;
        string coverArtURI;
        string caption;
        uint256 zorbId;
    }

    mapping (address => mapping(uint256 => ZporeRemix)) tokenRemixes;

    struct MetadataURIInfo {
        string song;
        string artist;
        string description;
        string contractURI;
    }

    /// @notice NFT metadata by contract
    mapping(address => MetadataURIInfo) public metadataBaseByContract;

    // upon minting a token, the custom minter will immediately call this function and pass
    // it the spores remix data to set that tokenId
    function updateTokenURI(address target, uint256 tokenId, ZporeRemix calldata data) 
        external requireSenderAdmin(target){
        tokenRemixes[target][tokenId] = data;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        ZporeRemix memory data = tokenRemixes[msg.sender][tokenId];
        uint256 zorbId = tokenRemixes[msg.sender][tokenId].zorbId;
        return string(abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(
                    abi.encodePacked(
                        "{\"name\": \"Zpore Remix\", ",
                        "\"description\": \"", metadataBaseByContract[msg.sender].description, "\",",
                        "\"caption\": \"", tokenRemixes[msg.sender][tokenId].caption, "\", ",
                        "\"zorbId\": ", Conversion.uint2str(zorbId), ", ",
                        "\"image\": \"", data.coverArtURI, "\", ",
                        "\"image_url\": \"", data.coverArtURI, "\", ",
                        "\"animation_url\": \"", data.contentURI, "\""
                        "}")))));
    }

    function contractURI() external view returns (string memory) {
        string memory uri = metadataBaseByContract[msg.sender].contractURI;
        if (bytes(uri).length == 0) revert();
        return uri;
    }

    function initializeWithData(bytes memory data) external {
        // data format: string baseURI, string newContractURI
        (string memory song, string memory artist, string memory description, string memory initialContractURI) = abi
            .decode(data, (string, string, string, string));

        metadataBaseByContract[msg.sender] = MetadataURIInfo({
            song: song,
            artist: artist,
            description: description,
            contractURI: initialContractURI}
        );
        
    }

}
