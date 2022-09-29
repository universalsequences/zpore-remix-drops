// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IMetadataRenderer.sol';
import './Base64.sol';
import {MetadataRenderAdminCheck} from './MetadataRenderAdminCheck.sol';

contract SporesMetadataRenderer is IMetadataRenderer, MetadataRenderAdminCheck {

    struct SporesRemix {
        string contentURI;
        string coverArtURI;
        string caption;
    }

    mapping (address => mapping(uint256 => SporesRemix)) tokenRemixes;

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
    function updateTokenURI(address target, uint256 tokenId, SporesRemix calldata data) 
        external requireSenderAdmin(target){
        tokenRemixes[target][tokenId] = data;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        // basically this contract will always be called by the actual Drop Contract
        // so msg.sender will always be that address hence we that is the "target"
        
        address target = msg.sender;

        // description -> "This is a remix of Psilocybin by Keyon Christ"
        // caption -> custom field we insert
        // can include othe rshit like traits
        // name is contract level -> if we reuse this we can use it elsewhere
        SporesRemix memory data = tokenRemixes[target][tokenId];
        string memory _description = metadataBaseByContract[msg.sender].description;
        string memory _name = "Zpore Remix";

        return string(abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(
                    abi.encodePacked(
                        "{\"name\": \"", _name, "\", \"description\": \"", _description, "\",",
                        "\"caption\": \"", data.caption, "\", ",
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
