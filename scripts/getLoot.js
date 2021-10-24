const main = async () => {
  const MyContract = await ethers.getContractFactory("LootNFT");
  const contract = await MyContract.attach(
    "0x5FbDB2315678afecb367f032d93F642f64180aa3"
  )
  const arr = [1,2,3];
  arr.forEach( async m=> {
    let item = (await contract.tokenURI(m)).toString();
    let itemBuff = Buffer.from(item, 'base64');
    console.log(itemBuff.toString('utf-8'));
  })
}

main();