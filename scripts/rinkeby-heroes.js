require('dotenv').config();
const main = async () => {
  const gameFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract =  await gameFactory.deploy(
    "0x06e673dC9c638609fa5B23Be3BAd3225c68c57a1",
    ["Sastriid", "Uthaad", "Cehd", "Oyeud"],
    [
      "https://bafybeidj3pgxpqnqggtx3qgkyqqnjpz32i5xalp3pkvxbfr7dbishdz52m.ipfs.dweb.link/",
      "https://bafkreid7lgvudgvjjrbgorq7dyxoynys3rgur6leluq3trjqsgsprnxvxi.ipfs.dweb.link", 
      "https://bafybeif7amvydbf2tdfmugvpyewtednxdgbdtkdxh4457yy2lfsanrhvie.ipfs.dweb.link/",
      "https://bafybeid7uhd23pw2clj3zoi4lfhdpkqnyx46icw5do6liuf2retdwb2day.ipfs.dweb.link/"
    ],
    [1,1,1,1].map(m => Math.round(Math.random()*150 + 75)),
    [1,1,1,1].map(m => Math.round(Math.random()*3 + 1)),
    [1,1,1,1].map(m => Math.round(Math.random()*5 + 1)),
    "BigBoss",
    "https://bafkreidtndj7prgtbnupt3n4mhs3i44tv3jq3lucqzgfo3v5u4bvbph4x4.ipfs.dweb.link/",
    200,
    20,
    [3, 5]
  );
  await gameContract.deployed();
  console.log(`Contract deployed @ ${gameContract.address}`);
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