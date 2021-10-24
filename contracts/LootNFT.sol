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
        ItemType itemType;
        uint256 dmg;
        uint256 level;
    }

    mapping(uint256 => ItemAttributes) public itemAttributes;

    constructor() ERC721("LootNFT", "LooT") {
    }

    function mintLoot(ItemType itemType, string memory itemName, string memory itemDescription)
        public
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        uint256 dmg = random(
            (
                string(
                    abi.encodePacked(block.timestamp, Strings.toString(newItemId))
                )
            )
        ) % 100 + 50;

        itemAttributes[newItemId] = ItemAttributes({
            name: itemName,
            description: itemDescription,
            itemType: itemType,
            dmg: dmg,
            level: 1
        });

        _mint(msg.sender, newItemId);
        return newItemId;
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
        return Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        attribs.name,
                        '", "description": "',
                        attribs.description,
                        '", "image": "",',
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
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
}
