// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/SporesMetadataRenderer.sol";
import "../src/SporesRemixMinter.sol";
import "../src/ERC721DropMock.sol";
import "../src/Base64.sol";

contract SporesMinterTest is Test {
    SporesMetadataRenderer public renderer;
    SporesRemixMinter public minter;
    ERC721DropMock public drop;

    function setUp() public {

        renderer = new SporesMetadataRenderer();
        minter = new SporesRemixMinter(address(renderer));

        console.log(string(abi.encode
             (
              "Psilocybin",
              "Keyon Christ",
              "This is a song",
              "contractTest")));
                    
        drop = new ERC721DropMock
            (
             renderer,
             abi.encode
             (
              "Psilocybin",
              "Keyon Christ",
              "This is a song",
              "contractTest"));
                                                    
    }

    function testMint() public {
        SporesMetadataRenderer.SporesRemix memory remix = SporesMetadataRenderer.SporesRemix({
            contentURI: "content",
            coverArtURI: "image",
            caption: "caption"
            });

        minter.purchase(payable(address(drop)), remix);

        string memory _name = "Zpore Remix";
        string memory _description = "This is a song";
        string memory _caption = "caption";
        string memory _coverArtURI = "image";
        string memory _contentURI = "content";
        string memory packed = string(abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(
                    abi.encodePacked(
                        "{\"name\": \"", _name, "\", \"description\": \"", _description, "\",",
                        "\"caption\": \"", _caption, "\", ",
                        "\"image\": \"", _coverArtURI, "\", ",
                        "\"image_url\": \"", _coverArtURI, "\", ",
                        "\"animation_url\": \"", _contentURI, "\""
                        "}")))));

        assertEq(drop.tokenURI(1), packed);
    }
}
