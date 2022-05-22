const hre = require("hardhat");

async function main() {
  // Get example accounts
  const [owner, people, people2, people3] = await hre.ethers.getSigners();

  // Get the contract to deploy & deploy
  const ChainBattles = await hre.ethers.getContractFactory("ChainBattles");
  const chainBattles = await ChainBattles.deploy();
  await chainBattles.deployed;
  console.log("chainBattles deployed to ", chainBattles.address);

  // mint

  await chainBattles.connect(owner).mint();

  const tokenURI = await chainBattles.connect(owner).generateCharacter(1);
  console.log(tokenURI);
  await chainBattles.connect(owner).mint();
  await chainBattles.connect(owner).mint();
  await chainBattles.connect(owner).train(1);
  await chainBattles.connect(owner).train(1);
  const tokenURI1 = await chainBattles.connect(owner).generateCharacter(1);
  console.log(tokenURI1);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
