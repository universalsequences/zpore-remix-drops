// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IZporeDrop {
    struct Drop {
        string name;
        string symbol;
        string title;
        string artist;
        string description;
        address fundsRecipient; // who can withdraw from the drop address
        uint256 mintPricePerToken;
    }
}
 
