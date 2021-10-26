export const getEthereum = () => {
  const { ethereum } = window;

  if (!ethereum) {
    alert("Make sure you have metamask!");
    return;
  } else {
    console.log("We have the ethereum object", ethereum);
  }

  return ethereum;
}


export const transformCharacterData = (characterData) => {
  console.log(characterData)
  return {
    characterIndex: characterData.characterIndex.toNumber(),
    name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    equippedWeapon: characterData.equippedWeapon.toNumber(),
    missPercent: characterData.missPercent,
    dodgePercent: characterData.dodgePercent
  };
};

export const transformBossData = (bossData) => {
  return {
    owner: bossData.owner,
    name: bossData.name,
    imageURI: bossData.imageURI,
    hp: bossData.hp.toNumber(),
    maxHp: bossData.maxHp.toNumber(),
    attackDamage: bossData.attackDamage.toNumber(),
    missPercent: bossData.missPercent,
    dodgePercent: bossData.dodgePercent
  }
}

export const transformWeaponData = (weaponData) => {
  console.log(weaponData.attribs);
  return {
    id: weaponData.tokenId.toNumber(),
    name: weaponData.attribs.name,
    description: weaponData.attribs.description,
    imageUri: weaponData.attribs.imageUri,
    damage: weaponData.attribs.dmg.toNumber(),
    level: weaponData.attribs.level.toNumber()
  }
};