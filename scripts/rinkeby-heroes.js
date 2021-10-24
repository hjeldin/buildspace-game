require('dotenv').config();
const main = async () => {
  const gameFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract =  await gameFactory.deploy(
    process.env.DEPLOYED_LOOT,
    ["Sastriid", "Uthaad", "Cehd", "Oyeud"],
    [
      "https://www.fantasy-faces.com/static/images/1/seed4543.png",
      "https://www.fantasy-faces.com/static/images/1/seed4562.png", 
      "https://www.fantasy-faces.com/static/images/1/seed3193.png",
      "https://www.fantasy-faces.com/static/images/1/seed3393.png"
    ],
    [1,1,1,1].map(m => Math.round(Math.random()*150 + 75)),
    "BigBoss",
    "https://www.fantasy-faces.com/static/images/8/seed1422.png",
    5000,
    20
  );
  await gameContract.deployed();

  console.log(`Contract deployed @ ${gameContract.address}`);

  console.log('Minting character template 3 with weapon 2');
  let txn;
  txn = await gameContract.mintCharacter(3, 2, {gasLimit: 307604}); // mint character id 2 with weapon 1
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  currHp = (await gameContract.getMyHP()).toNumber();
  console.log(`Current HP: ${currHp}`)
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