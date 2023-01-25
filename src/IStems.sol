// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './IZporeDrop.sol';

interface IStems {
    
    enum StemType {
        VOCALS,
        INSTRUMENTS,
        DRUMS,
        BASS,
        GUITAR // "acoustify"
    }

    struct Song {
        string name;
        string artist;
        int16 bpm;
        int16 bpmDecimal;
        string key; // A Major, B Minor etc
    }

    struct Stem {
        string uri; // location of sample
        uint16 duration; // duration in ms
        bool isLoop; // is it a loop or not-- if not, its a full-length stem
    }

    struct SongData {
        string title;
        string artist;
        int16 bpm;
        int16 bpmDecimal;
        string key;
        bytes32[] attributeTypes;
        bytes32[] attributeValues;
    }

    struct StemData {
        string uri;
        StemType[] stemTypes;
        bool isLoop;
        uint16 duration;
        bytes32[] attributeTypes;
        bytes32[] attributeValues;
    }

    event SongCreator(uint256 indexed songId, address indexed creator);
    event NewSong(uint256 songId, string name, string artist, int16 bpm, int16 bpmDecimal, string key);
    event NewStem(uint256 songId, uint256 stemId, string uri, uint16 duration, bool isLoop);
    event NewStemType(uint256 stemId, StemType stemType);
    event NewDefaultSongConfiguration(uint256 songId, uint256 configId);
    event SongConfigurationStem(uint256 configId, uint256 stemId);
    event StemDeleted(uint256 indexed stemId);
    event SongDeleted(uint256 indexed songId);
    event StemAttribute(uint256 indexed stemId, bytes32 indexed attributeType, bytes32 indexed attributeValue);
    event SongAttribute(uint256 indexed songId, bytes32 indexed attributeType, bytes32 indexed attributeValue);
    event NewDropCreated(uint256 songId, address dropAddress);

    function newSong(
        SongData memory songData,
        StemData [] memory stemsData,
        IZporeDrop.Drop memory drop,
        address defaultAdmin)  external;
    
}
 
