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
  return {
    characterIndex: characterData.characterIndex.toNumber(),
    name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    equippedWeapon: characterData.equippedWeapon.toNumber(),
  };
};

export const transformBossData = (bossData) => {
  return {
    name: bossData.name,
    imageURI: bossData.imageURI,
    hp: bossData.hp.toNumber(),
    maxHp: bossData.maxHp.toNumber(),
    attackDamage: bossData.attackDamage.toNumber()
  }
}

export const transformWeaponData = (weaponData) => {
  return {
    id: weaponData.tokenId.toNumber(),
    name: weaponData.attribs.name,
    description: weaponData.attribs.description,
    damage: weaponData.attribs.dmg.toNumber(),
    level: weaponData.attribs.level.toNumber()
  }
};