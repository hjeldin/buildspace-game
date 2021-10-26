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
        uint8 missPercent;
        uint8 dodgePercent;
    }

    struct BigBoss {
        address owner;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        uint8 missPercent;
        uint8 dodgePercent;
    }

    BigBoss public bigBoss;

    uint256 characterBaseDamage;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    mapping(address => uint256) public nftHolders;

    mapping(address => uint256) public attackCounter;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);
    event WeaponEquipped(uint256 equippedWeapon);
    event CharacterHealed(uint256 tokenId);
    event NewBigBoss();
    event PlayerAttackMissed(address target);
    event PlayerAttackDodged(address target);
    event BossAttackMissed(address target);
    event BossAttackDodged(address target);

    constructor(
        address lootContractAddress,
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint8[] memory missPercents,
        uint8[] memory dodgePercents,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage,
        uint8[] memory bossMissDodge
        // uint8 bossDodgePercent
    ) ERC721("HeroNFT", "HNT") {
        bigBoss = BigBoss({
            owner: msg.sender,
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage,
            missPercent: bossMissDodge[0],
            dodgePercent: bossMissDodge[1]
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
                    equippedWeapon: 0, // no equipped weapon
                    missPercent: missPercents[i],
                    dodgePercent: dodgePercents[i]
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
            equippedWeapon: equippedWeapon,
            missPercent: defaultCharacter.missPercent,
            dodgePercent: defaultCharacter.dodgePercent
        });

        console.log("Minted character for %s: %d", msg.sender, newItemId);

        nftHolders[msg.sender] = newItemId;

        _tokenIds.increment();

        attackCounter[msg.sender] = 0;

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function mintCharacterWithoutWeapon(uint256 _characterIndex) external {
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
            equippedWeapon: 0,
            missPercent: defaultCharacter.missPercent,
            dodgePercent: defaultCharacter.dodgePercent
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

    function getMyHP() public view returns (uint256) {
        uint256 token = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[token];
        return player.hp;
    }

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        uint256 token = nftHolders[msg.sender];
        if (token > 0) {
            return nftHolderAttributes[token];
        } else {
            CharacterAttributes memory empty;
            return empty;
        }
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
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
            ,,,,uint256 itemDmg,
        ) = lootContract.itemAttributes(charAttributes.equippedWeapon);

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(itemDmg);
        string memory strMissPercent = Strings.toString(
            charAttributes.missPercent
        );
        string memory strDodgePercent = Strings.toString(
            charAttributes.dodgePercent
        );
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
                        '}, { "trait_type": "Miss. %", "value": ',
                        strMissPercent,
                        '}, { "trait_type": "Dodge %", "value": ',
                        strDodgePercent,
                        '}]}'
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
            ,,,,
            uint256 itemDmg,
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

        uint8 missRV = uint8(
            random(string(abi.encodePacked(block.timestamp % block.number))) %
                100
        );
        // uint8 dodgeRV = uint8(
        //     random(string(abi.encodePacked(block.number % block.timestamp))) %
        //         100
        // );

        if (missRV < player.missPercent) {
            emit PlayerAttackMissed(msg.sender);
        } else {
            if (missRV < bigBoss.dodgePercent) {
                emit PlayerAttackDodged(msg.sender);
            } else {
                if (bigBoss.hp < itemDmg) {
                    bigBoss.hp = 0;
                    becomeBoss();
                    emit AttackComplete(bigBoss.hp, player.hp);
                    emit NewBigBoss();
                    return;
                } else {
                    bigBoss.hp = bigBoss.hp - itemDmg;
                }
            }
        }

        // Allow boss to attack player.
        if (missRV < bigBoss.missPercent) {
            emit BossAttackMissed(msg.sender);
        } else {
            if (missRV < player.dodgePercent) {
                emit BossAttackDodged(msg.sender);
            } else {
                if (player.hp < bigBoss.attackDamage) {
                    player.hp = 0;
                } else {
                    player.hp = player.hp - bigBoss.attackDamage;
                }
            }
        }

        attackCounter[msg.sender] = attackCounter[msg.sender] + 1;

        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function healCharacter() public {
        require(attackCounter[msg.sender] > 2);
        attackCounter[msg.sender] = 0;
        uint256 token = nftHolders[msg.sender];
        if (token > 0) {
            nftHolderAttributes[token].hp = nftHolderAttributes[token].maxHp;
        }
        emit CharacterHealed(token);
    }

    function becomeBoss() public {
        require(bigBoss.hp == 0);
        console.log("Trying to become the big boss");
        uint256 token = nftHolders[msg.sender];
        if (token > 0) {
            bigBoss.imageURI = nftHolderAttributes[token].imageURI;
            (
                ,,,,
                uint256 itemDmg,
            ) = lootContract.itemAttributes(
                    nftHolderAttributes[token].equippedWeapon
                );
            bigBoss.attackDamage = itemDmg;
            bigBoss.name = nftHolderAttributes[token].name;
            bigBoss.hp = nftHolderAttributes[token].maxHp * 10;
            bigBoss.maxHp = nftHolderAttributes[token].maxHp * 10;
            bigBoss.owner = msg.sender;
            bigBoss.missPercent = nftHolderAttributes[token].missPercent;
            bigBoss.dodgePercent = nftHolderAttributes[token].dodgePercent;
        }
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
}
