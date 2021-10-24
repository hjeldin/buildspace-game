// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";
import "./LootNFT.sol";

contract MyEpicGame is ERC721 {
    LootNFT lootContract;

    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 equippedWeapon; // Check out LootNFT contract
    }

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    uint256 characterBaseDamage;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    mapping(address => uint256) public nftHolders;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);
    event WeaponEquipped(uint256 equippedWeapon);

    constructor(
        address lootContractAddress,
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("HeroNFT", "HNT") {
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        lootContract = LootNFT(lootContractAddress);
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    equippedWeapon: 0 // no equipped weapon
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
            _tokenIds.increment();
        }
    }

    function mintCharacter(uint256 _characterIndex, uint256 equippedWeapon)
        external
    {
        uint256 newItemId = _tokenIds.current();

        require(msg.sender == lootContract.ownerOf(equippedWeapon));

        _safeMint(msg.sender, newItemId);

        CharacterAttributes memory defaultCharacter = defaultCharacters[
            _characterIndex
        ];
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacter.name,
            imageURI: defaultCharacter.imageURI,
            hp: defaultCharacter.hp,
            maxHp: defaultCharacter.maxHp,
            equippedWeapon: equippedWeapon
        });

        console.log("Minted character for %s: %d", msg.sender, newItemId);

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function mintCharacterWithoutWeapon(uint256 _characterIndex)
        external
    {
        uint256 newItemId = _tokenIds.current();

        _safeMint(msg.sender, newItemId);

        CharacterAttributes memory defaultCharacter = defaultCharacters[
            _characterIndex
        ];
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacter.name,
            imageURI: defaultCharacter.imageURI,
            hp: defaultCharacter.hp,
            maxHp: defaultCharacter.maxHp,
            equippedWeapon: 0
        });

        console.log("Minted character for %s: %d", msg.sender, newItemId);

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function equipWeapon(uint256 weaponTokenId) public {
        require(msg.sender == lootContract.ownerOf(weaponTokenId));
        uint256 token = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[token];
        player.equippedWeapon = weaponTokenId;
        emit WeaponEquipped(weaponTokenId);
    }

    function getMyHP() public view returns (uint) {
        uint256 token = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[token];
        return player.hp;
    }

    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        uint256 token = nftHolders[msg.sender];
        if(token > 0) {
            return nftHolderAttributes[token];
        } else {
            CharacterAttributes memory empty;
            return empty;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        (
            string memory itemName,
            string memory itemDescr,
            string memory itemImageUri,
            LootNFT.ItemType itemType,
            uint256 itemDmg,
            uint256 itemLevel
        ) = lootContract.itemAttributes(charAttributes.equippedWeapon);

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(itemDmg);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "It`s like magic", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss() public {
        uint256 token = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[token];

        (
            string memory itemName,
            string memory itemDescr,
            string memory itemImageUri,
            LootNFT.ItemType itemType,
            uint256 itemDmg,
            uint256 itemLevel
        ) = lootContract.itemAttributes(player.equippedWeapon);

        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            itemDmg
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );
        // Make sure the player has more than 0 HP.
        require(player.hp > 0, "Error: character must have HP to attack boss.");

        // Make sure the boss has more than 0 HP.
        require(bigBoss.hp > 0, "Error: boss must have HP to attack boss.");

        if (bigBoss.hp < itemDmg) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - itemDmg;
        }

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        emit AttackComplete(bigBoss.hp, player.hp);
    }
}
