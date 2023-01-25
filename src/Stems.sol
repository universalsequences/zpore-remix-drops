// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import './ZporeDropCreator.sol';
import './IStems.sol';
import './IZporeDrop.sol';

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Stems is IStems {

    /**
     * TODO: 
     * Allow updating metadatarenderer/dropcreator by owner
     * Change to Ownable
     */

    uint256 private songIdCounter=0;
    uint256 private configIdCounter=0;
    uint256 private stemIdCounter=0;

    address public zporeDropCreator; // updatable
    address public zporeMetadataRenderer; // updatable

    constructor(address _zporeDropCreator, address _zporeMetadataRenderer) {
        zporeDropCreator = _zporeDropCreator;
        zporeMetadataRenderer = _zporeMetadataRenderer;
    }

    mapping (uint256 => Song) songs; // by id
    mapping (uint256 => Stem) stems; // by id 
    mapping (uint256 => uint256[]) songConfigurations; // by id

    // mappings from entityId -> entity(/ies)
    mapping (uint256 => uint256[]) songToStems; // song -> all stemIds
    mapping (uint256 => StemType[]) stemToTypes; // stem -> types
    mapping (uint256 => uint256) defaultSongConfigurations; // songId -> configId
    mapping (uint256 => uint256) stemToSong; // stemId => songId
    mapping (uint256 => address) songToCreator;

       
    function newSong(
        SongData memory songData,
        StemData [] memory stemsData,
        IZporeDrop.Drop memory drop,
        address defaultAdmin
        )  public {
                     
        uint256 songId = songIdCounter++;
        emit SongCreator(songId, msg.sender);
        songToCreator[songId] = msg.sender;
        updateSong(songId, songData);
        newStems(songId, stemsData);

        uint256 configId = configIdCounter++;
        defaultSongConfigurations[songId] = configId;
        emit NewDefaultSongConfiguration(songId, configId);

        for (uint i=0; i < stemsData.length; i++) {
            uint256 stemId = songToStems[songId][i];
            emit SongConfigurationStem(configId, stemId);
            songConfigurations[configId].push(stemId);
        }    

        // finally create the zora-enabled drop
        address dropAddress = ZporeDropCreator(zporeDropCreator).newDrop(
            drop,
            defaultAdmin,
            zporeMetadataRenderer,
            1000);

        emit NewDropCreated(songId, dropAddress);
   }

    /**
    * Bulk upload new stems to a song. Does not set the configuration, 
    * simply adds to the pool of stems around a song
    */
    function newStems(
        uint256 songId, 
        StemData [] memory stemsData) 
    public {
        for (uint i=0; i < stemsData.length; i++) {
            uint256 stemId = stemIdCounter++;
            stems[stemId] = Stem(
                stemsData[i].uri,
                stemsData[i].duration,
                stemsData[i].isLoop
            );

            stemToSong[stemId] = songId;
            stemToTypes[stemId] = stemsData[i].stemTypes;
            songToStems[songId].push(stemId);

            emit NewStem(songId, stemId, stemsData[i].uri, stemsData[i].duration, stemsData[i].isLoop);
            for (uint j=0; j < stemsData[i].stemTypes.length; j++) {
                emit NewStemType(stemId, stemsData[i].stemTypes[j]);
            }
            for (uint j=0; j < stemsData[i].attributeTypes.length; j++) {
                // each stem can have an attribute, thus allowing us to dynamically add attributes
                // to the system
                emit StemAttribute(
                    stemId,
                    stemsData[i].attributeTypes[j],
                    stemsData[i].attributeValues[j]);
            }
        }
    }

    function updateAttributesForStems(
        uint256 stemId,
        bytes32 [] memory attributeTypes,
        bytes32 [] memory attributeValues) public {
        for (uint i=0; i < attributeTypes.length; i++) {
            emit StemAttribute(stemId, attributeTypes[i], attributeValues[i]);
        }
    }

    /**
    * Creates a new default configuration of stems for a song
    */
    function updateSongConfiguration(
        uint256 songId, 
        uint256 [] memory stemIds) 
    public {
        uint256 configId = configIdCounter++;
        defaultSongConfigurations[songId] = configId;

        for (uint i=0; i < stemIds.length; i++) {
            uint256 stemId = stemIds[i];
            songConfigurations[configId].push(stemId);
            emit SongConfigurationStem(configId, stemId);
        }

        emit NewDefaultSongConfiguration(songId, configId);
    }

    function deleteStems(uint256[] memory stemIds) public {
        for (uint i=0; i < stemIds.length; i++) {
            uint256 songId = stemToSong[stemIds[i]];
            require(songToCreator[songId] == msg.sender);
            emit StemDeleted(stemIds[i]);
        }
    }

    function deleteSong(uint256 songId) public {
        require(songToCreator[songId] == msg.sender);
        emit SongDeleted(songId);
    }

    function updateSong(
        uint256 songId,
        SongData memory songData) public {
        require(songToCreator[songId] == msg.sender);
        songs[songId] = Song(
            songData.title,
            songData.artist,
            songData.bpm,
            songData.bpmDecimal,
            songData.key
        );

        emit NewSong(
            songId,
            songData.title,
            songData.artist,
            songData.bpm,
            songData.bpmDecimal,
            songData.key);

        // emit the song attributes
        for (uint i=0; i < songData.attributeTypes.length; i++) {
            emit SongAttribute(
                songId,
                songData.attributeTypes[i],
                songData.attributeValues[i]);
        }
    }

    function updateStem(
        uint256 stemId,
        StemData memory stemData) public {
        require(
            songToCreator[stemToSong[stemId]] == msg.sender,
            "Only song creator can update stem metadata");

        stems[stemId].uri = stemData.uri;
        stems[stemId].duration = stemData.duration;
        stems[stemId].isLoop = stemData.isLoop;

        emit NewStem(stemId, stemId, stemData.uri, stemData.duration, stemData.isLoop);

        for (uint i=0; i < stemData.attributeTypes.length; i++) {
            emit StemAttribute(stemId, stemData.attributeTypes[i], stemData.attributeValues[i]);
        }
    }

    function getSong(uint256 songId) public view returns (Song memory) {
        return songs[songId];
    }

    /*
    * Returns configId
    */
    function getDefaultSongConfiguration(uint256 songId) public view returns (uint256 ) {
        return defaultSongConfigurations[songId];
    }

    /*
    * Returns list of stemIds in a song configuration
    */
    function getSongConfiguration(uint256 configId) public view returns (uint256 [] memory) {
        return songConfigurations[configId];
    }

    /*
    * Returns stem
    */
    function getStem(uint256 stemId) public view returns (Stem memory) {
        return stems[stemId];
    }

    function getStemTypes(uint256 stemId) public view returns (StemType[] memory) {
        return stemToTypes[stemId];
    }

}
