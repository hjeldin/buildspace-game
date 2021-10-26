const main = async () => {
  const lootFactory = await hre.ethers.getContractFactory("LootNFT");
  const lootContract =  await lootFactory.deploy();
  await lootContract.deployed();

  console.log(`Contract deployed @ ${lootContract.address}`);
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