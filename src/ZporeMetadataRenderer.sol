// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IMetadataRenderer.sol';
import './Base64.sol';
import './Conversion.sol';
import {MetadataRenderAdminCheck} from './MetadataRenderAdminCheck.sol';
import './AddressUtils.sol';

contract ZporeMetadataRenderer is IMetadataRenderer, MetadataRenderAdminCheck {

    struct ZporeRemix {
        string contentURI;
        string coverArtURI;
        uint256 zorbId;

        // stemIds, if stemId=0 then that stem is actually another
        // remix and we use the contractAddresses+tokenIds arrays values

        // remix DNA, tells us what stems are 
        uint8 []stemPercentages;

        // using these fields, we can calculate the pitch offset we
        // need to load a remix as a stem and have it be in key
        string bpm; // in case, we're pitched down (and thus slowed down)
        string detune; // again, in case we're pitched down

        // list of contract address+tokenid pairs used in the remix
        // some of which maybe stems from the stems contract, but could be
        address [] contractAddresses;
        uint256 [] ids;
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
        return string(abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(bytes(
            abi.encodePacked(
              "{",
              "\"name\": \"", tokenName(msg.sender, tokenId), "\", ", 
              originalSongMetadata(msg.sender),
              remixMetadata(msg.sender, tokenId),
              "}"
            )))));
    }

    function tokenName(address from, uint256 tokenId) internal view returns (string memory) {
        return string( 
          abi.encodePacked(
            metadataBaseByContract[msg.sender].song,
            " (Remix #", Conversion.uint2str(tokenId), ")"
            ));
    }

    function originalSongMetadata(address from) internal view returns (string memory) {
        MetadataURIInfo memory data = metadataBaseByContract[msg.sender];
        return string( 
          abi.encodePacked(
              "\"description\": \"", data.description, "\", ",
              "\"artist\": \"", data.artist, "\", "
                           ));
    }

    function remixMetadata(address from, uint256 tokenId) internal view returns (string memory) {
        ZporeRemix memory data = tokenRemixes[msg.sender][tokenId];
        uint256 zorbId = tokenRemixes[msg.sender][tokenId].zorbId;
        return string( 
          abi.encodePacked(
            "\"image\": \"", data.coverArtURI, "\", ",
            "\"image_url\": \"", data.coverArtURI, "\", ",
            "\"animation_url\": \"", data.contentURI, "\", ",
            remixDNA(data), ", ",
            traitsMetadata(data, zorbId)
                           ));
    }

    function remixDNA(ZporeRemix memory remix) internal view returns (string memory) {
        string memory traits = "\"remix_dna\": [";
                
        for (uint256 i=0; i < remix.contractAddresses.length; i++) {
            traits = string(
                abi.encodePacked(
                    traits,
                    "{",
                    "\"contract_address\": \"", AddressUtils.toAsciiString(remix.contractAddresses[i]), "\",",
                    "\"token_id\": \"", Conversion.uint2str(remix.ids[i]), "\"",
                    "}"));
            if (i < remix.ids.length - 1) {
                traits = string(
                    abi.encodePacked(
                        traits,
                        ", "));

            }
        }
        return string(abi.encodePacked(traits, "]"));
    }

    function traitsMetadata(ZporeRemix memory remix, uint256 zorbId) internal view returns (string memory) {
        string memory traits = string(
            abi.encodePacked(
                "\"attributes\": [",
                "{\"trait_type\": \"zorb\",\"value\": \"", Conversion.uint2str(zorbId), "\"}, "
                "{\"trait_type\": \"detune\",\"value\": \"", remix.detune, "\"}, "
                "{\"trait_type\": \"bpm\",\"value\": \"", remix.bpm, "\"}"
            ));

        if (remix.contractAddresses.length > 0) {
            traits = string(abi.encodePacked(traits, ", "));
        }
        
        for (uint256 i=0; i < remix.contractAddresses.length; i++) {
            traits = string(
                abi.encodePacked(
                    traits,
                    "{",
                    "\"trait_type\": \"Stem ", abi.encodePacked(AddressUtils.toAsciiString(remix.contractAddresses[i]), " #", Conversion.uint2str(remix.ids[i])), "\",",
                    "\"value\": \"", Conversion.uint2str(remix.stemPercentages[i]), "%\"",
                    "}"));
            if (i < remix.ids.length - 1) {
                traits = string(
                    abi.encodePacked(
                        traits,
                        ", "));

            }
        }
        return string(abi.encodePacked(traits, "]"));
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
