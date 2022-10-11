const hre = require("hardhat");

async function main() {
  const HouseToken = await hre.ethers.getContractFactory("HouseToken");
  const HouseWrapper = await hre.ethers.getContractFactory("HouseWrapper");

  console.log("\nDeploy Contract ...")
  const ht = await HouseToken.deploy();
  const wrapp = await HouseWrapper.deploy();

  console.log(
    ` all contracts was deployed successfully ...
      HouseToken = ${ht.address}
      HouseWrapper = ${wrapp.address}
    `);

  console.log("\n set contracts ... ");
  await ht.setMinter(wrapp.address).then(console.log("HouseToken set minter successfully"));
  await wrapp.setHouseToken(ht.address).then(console.log("HouseWrapper set HouseToken successfully"));

  // console.log("\n verify contracts ... ");
  // await hre.run("verify:verify", {address: ht.address, contractorArguments:[]}).then(console.log("verify contract HouseToken successfully"));
  // await hre.run("verify:verify", {address: wrapp.address, contractorArguments:[ht.address]}).then(console.log("verify contract HouseWrapper successfully"));
 }


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
