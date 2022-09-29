
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/ZporeMetadataRenderer.sol";
import "../src/ZporeMinter.sol";
import "../src/ERC721DropMock.sol";
import "../src/Base64.sol";

contract ZporeMinterTest is Test {
    ZporeMetadataRenderer public renderer;
    ZporeMinter public minter;
    ERC721DropMock public drop;

    function setUp() public {

        renderer = new ZporeMetadataRenderer();
        minter = new ZporeMinter(address(renderer));

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
        ZporeMetadataRenderer.ZporeRemix memory remix = ZporeMetadataRenderer.ZporeRemix({
            contentURI: "content",
            coverArtURI: "image",
            caption: "caption",
            zorbId: 1000
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
                        "\"zorbId\": 1000, ",
                        "\"image\": \"", _coverArtURI, "\", ",
                        "\"image_url\": \"", _coverArtURI, "\", ",
                        "\"animation_url\": \"", _contentURI, "\""
                        "}")))));

        assertEq(drop.tokenURI(1), packed);
    }
}
