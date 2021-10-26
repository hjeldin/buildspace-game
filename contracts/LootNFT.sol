// contracts/LootNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {Base64} from "./libraries/Base64.sol";
import "hardhat/console.sol";

contract LootNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address private owner;

    enum ItemType {
        SWORD,
        AXE,
        BOW
    }

    struct ItemAttributes {
        string name;
        string description;
        string imageUri;
        ItemType itemType;
        uint256 dmg;
        uint256 level;
    }

    struct TokenAndItemAttributes {
        uint256 tokenId;
        ItemAttributes attribs;
    }

    mapping(uint256 => ItemAttributes) public itemAttributes;
    mapping(address => uint256[]) public ownedWeapons;

    event WeaponMinted(uint256 id);

    constructor() ERC721("LootNFT", "LooT") {
    }

    function mintLoot(ItemType itemType, string memory itemName, string memory itemDescription)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        string memory image = '';
        uint8 dmg = 0;
        if(itemType == ItemType.SWORD) {
            image = 'https://bafkreih2u25boco57kn4ydqnlfl7hyb3j4f3er7rnyuutrxxmlfyye5qum.ipfs.dweb.link/';
            dmg = uint8(random(
                (
                    string(
                        abi.encodePacked(block.timestamp, Strings.toString(newItemId))
                    )
                )
            )) % 40 + 80;
        }
        if(itemType == ItemType.AXE) {
            image = 'https://bafkreibs6hpzzrtsqwj73ja6c5uc3ppewqwxwznze4auo3ypgibhbv6cii.ipfs.dweb.link/';
            dmg = uint8(random(
                (
                    string(
                        abi.encodePacked(block.timestamp, Strings.toString(newItemId))
                    )
                )
            )) % 90 + 50;
        }
        if(itemType == ItemType.BOW) {
            image = 'https://bafkreiclfah454anm7fcslfpzlurxdnujsrc6grzk7uqhio7nebar4m3ca.ipfs.dweb.link';
            dmg = uint8(random(
                (
                    string(
                        abi.encodePacked(block.timestamp, Strings.toString(newItemId))
                    )
                )
            )) % 80 + 30;
        }

        itemAttributes[newItemId] = ItemAttributes({
            name: itemName,
            description: itemDescription,
            imageUri: image,
            itemType: itemType,
            dmg: dmg,
            level: 1
        });

        _mint(msg.sender, newItemId);
        ownedWeapons[msg.sender].push(newItemId);
        emit WeaponMinted(newItemId);
        return newItemId;
    }

    function getAvailableItems() public view returns (TokenAndItemAttributes[] memory) {
        TokenAndItemAttributes[] memory tokenArray = new TokenAndItemAttributes[](ownedWeapons[msg.sender].length);
        
        for(uint i = 0; i < ownedWeapons[msg.sender].length; i++) {
            tokenArray[i] = TokenAndItemAttributes({
                tokenId: ownedWeapons[msg.sender][i],
                attribs: itemAttributes[ownedWeapons[msg.sender][i]]
            });
        }

        return tokenArray;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
      ItemAttributes memory attribs = itemAttributes[_tokenId];
      string memory cid = '';
      string memory typeValue = '';
      if(attribs.itemType == ItemType.SWORD) {
        cid = '';
        typeValue = 'Sword';
      }
      if(attribs.itemType == ItemType.AXE) {
        cid = '';
        typeValue = 'Axe';
      }
      if(attribs.itemType == ItemType.BOW) {
        cid = '';
        typeValue = 'Bow';
      }
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        attribs.name,
                        '", "description": "',
                        attribs.description,
                        '", "image": "',
                        attribs.imageUri,
                        '",',
                        '"attributes": [{',
                        '"trait_type": "Damage",',
                        '"value": ', 
                        Strings.toString(attribs.dmg),
                        '},{',
                        '"trait_type": "Type",',
                        '"value": "',
                        typeValue,
                        '"}]',
                        '}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
}
