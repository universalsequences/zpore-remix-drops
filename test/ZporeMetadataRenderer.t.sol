// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/ZporeMetadataRenderer.sol";
import "../src/ERC721DropMock.sol";
import "../src/Base64.sol";
import "../src/AddressUtils.sol";

contract ZporeMetadataRendererTest is Test {
    ZporeMetadataRenderer public renderer;
    ERC721DropMock public drop;

    function setUp() public {

        renderer = new ZporeMetadataRenderer();

        drop = new ERC721DropMock
            (
             renderer,
             abi.encode
             (
              "Psilocybin",
              "Keyon Christ",
              "Description",
              "contractURI"));
    }

    function testTokenURIUpdate() public {
        address address1 = address(0x11119604aE811E29B8fa22b12F67F79eb67d17BA);
        address address2 = address(0x22229104AE811e29b8Fa22b12F67f79EB67d17ba);

        ZporeMetadataRenderer.ZporeRemix memory remix = ZporeMetadataRenderer.ZporeRemix({
            contentURI: "content",
            coverArtURI: "image",
            zorbId: 1000,
            stemPercentages: new uint8[](2),
            bpm: "100.2",
            detune: "-2000",
            contractAddresses: new address[](2),
            ids: new uint256[](2)
            });

        remix.stemPercentages[0] = 80;
        remix.stemPercentages[1] = 20;

        remix.contractAddresses[0] = address1;
        remix.contractAddresses[1] = address2;
        uint256 tokenId1 = 10;
        uint256 tokenId2 = 20;
        remix.ids[0] = tokenId1;
        remix.ids[1] = tokenId2;

        string memory hash1 = string(abi.encodePacked(AddressUtils.toAsciiString(address1), " #", tokenId1));
        string memory hash2 = string(abi.encodePacked(AddressUtils.toAsciiString(address2), " #", tokenId2));

        renderer.updateTokenURI(address(drop), 1, remix);
 
        string memory _coverArtURI = "image";
        string memory _contentURI = "content";
        string memory _artist = "Keyon Christ";
        string memory packed = string(abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(
                    abi.encodePacked(
                        "{\"name\": \"Psilocybin (Remix #1)\", ",
                        "\"description\": \"Description\", ",
                        "\"artist\": \"Keyon Christ\", ",
                        "\"image\": \"image\", ",
                        "\"image_url\": \"image\", ",
                        "\"animation_url\": \"content\", ",
                        "\"remix_dna\": [",
                        "{\"contract_address\": \"0x11119604ae811e29b8fa22b12f67f79eb67d17ba\",\"token_id\": \"10\"}, ",
                        "{\"contract_address\": \"0x22229104ae811e29b8fa22b12f67f79eb67d17ba\",\"token_id\": \"20\"}",
                        "], "
                        "\"attributes\": [",
                        "{\"trait_type\": \"zorb\",\"value\": \"1000\"}, ",
                        "{\"trait_type\": \"detune\",\"value\": \"-2000\"}, ",
                        "{\"trait_type\": \"bpm\",\"value\": \"100.2\"}, ",
                        "{\"trait_type\": \"Stem 0x11119604ae811e29b8fa22b12f67f79eb67d17ba #10\",\"value\": \"80%\"}, ",
                        "{\"trait_type\": \"Stem 0x22229104ae811e29b8fa22b12f67f79eb67d17ba #20\",\"value\": \"20%\"}]",
                        "}")))));

        assertEq(drop.tokenURI(1), packed);
    }
}
