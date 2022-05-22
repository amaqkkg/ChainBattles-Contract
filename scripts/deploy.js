const main = async () => {
  try {
    const nftContractFactory = await hre.ethers.getContractFactory(
      "ChainBattles"
    );
    const nftContract = await nftContractFactory.deploy();

    console.log("Contract deployed to: ", nftContract.address);
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

main();
// deployed to 0xcC67Fc3d763fE95A9F056444c7fbFF5C04E83Ad9
