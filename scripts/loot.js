const main = async () => {
  const lootFactory = await hre.ethers.getContractFactory("LootNFT");
  const lootContract =  await lootFactory.deploy();
  await lootContract.deployed();

  console.log(`Contract deployed @ ${lootContract.address}`);

  let tx = await lootContract.mintLoot(0, "My favourite sword", "A brief description");

  await tx.wait();

  tx = await lootContract.mintLoot(1, "My favourite axe", "A brief description");

  await tx.wait();

  tx = await lootContract.mintLoot(2, "My favourite bow", "A brief description");

  await tx.wait();
};

const runMain = async () => {
  try{
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();