// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/ZporeMetadataRenderer.sol";
import "../src/ERC721DropMock.sol";
import "../src/Base64.sol";

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
        ZporeMetadataRenderer.ZporeRemix memory remix = ZporeMetadataRenderer.ZporeRemix({
            contentURI: "content",
            coverArtURI: "image",
            caption: "caption",
            zorbId: 1000
            });

        renderer.updateTokenURI(address(drop), 1, remix);
 
        string memory _caption = "caption";
        string memory _coverArtURI = "image";
        string memory _contentURI = "content";
        string memory _artist = "Keyon Christ";
        string memory packed = string(abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(
                    abi.encodePacked(
                        "{\"name\": \"Psilocybin (Remix #1)\", ",
                        "\"description\": \"Description\", ",
                        "\"artist\": \"Keyon Christ\", ",
                        "\"caption\": \"", _caption, "\", ",
                        "\"zorbId\": 1000, ",
                        "\"image\": \"", _coverArtURI, "\", ",
                        "\"image_url\": \"", _coverArtURI, "\", ",
                        "\"animation_url\": \"", _contentURI, "\""
                        "}")))));

        assertEq(drop.tokenURI(1), packed);
    }
}
