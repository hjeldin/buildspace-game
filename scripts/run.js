const main = async () => {
  const gameFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract =  await gameFactory.deploy(
    "0x5FbDB2315678afecb367f032d93F642f64180aa3",
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

  // console.log('Minting character template 2 with weapon 1');
  // let txn;
  // txn = await gameContract.mintCharacter(2, 1, {gasLimit: 3075820}); // mint character id 2 with weapon 1
  // await txn.wait();

  // const [me, randomPerson, anotherRandomPerson] = await hre.ethers.getSigners();
  // console.log('Minting character template 3 with weapon 3');
  // txn = await gameContract.connect(randomPerson).mintCharacter(3, 2, {gasLimit: 3075820}); // mint character id 3 with weapon 3
  // await txn.wait();

  // console.log('Minting character template 1 with weapon 2');
  // txn = await gameContract.connect(anotherRandomPerson).mintCharacter(1, 3, {gasLimit: 3075820}); // mint character id 1 with weapon 2
  // await txn.wait();


  // const arr = [4,5,6];
  // arr.forEach( async m=> {
  //   let item = (await gameContract.tokenURI(m)).toString();
  //   let itemBuff = Buffer.from(item, 'base64');
  //   console.log(itemBuff.toString('utf-8'));
  // })

  // currHp = (await gameContract.connect(me).getMyHP()).toNumber();
  // console.log(`Current HP: ${currHp}`)
  
  // attack = async () => {
  //   console.log("Attacking");
  //   txn = await gameContract.attackBoss();
  //   await txn.wait();
    
  //   currHp = (await gameContract.connect(me).getMyHP()).toNumber();

  //   console.log(`Current HP: ${currHp}`);
  //   if(currHp > 0) 
  //   {
  //     await attack();
  //   }
  // };

  // await attack();

  // txn = await gameContract.attackBoss();
  // await txn.wait();
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