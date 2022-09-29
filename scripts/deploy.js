// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const SpellRegist = await hre.ethers.getContractFactory("SpellRegist");
  const HouseToken = await hre.ethers.getContractFactory("HouseToken");
  const HouseWrapper = await hre.ethers.getContractFactory("HouseWrapper");

  console.log("\nDeploy Contract ...")
  const ht = await HouseToken.deploy();
  const wrapp = await HouseWrapper.deploy(ht.address);
  const spr = await SpellRegist.deploy(2,1,["0x0dCC8b2240c7406100B9544Bd4e2a7Db5E0219A6", "0x5c980E6CdAE758d0C68e86064c1c06B1eA19A6a9","0xEb43bE4aa6101427154178F13d2661e5B2090a9F"]);

  console.log(
    `all contracts was deployed successfully ...
      HouseToken = ${ht.address}
      HouseWrapper = ${wrapp.address}
      SpellRegistry = ${spr.address}`
  );

  console.log("\n\n set contracts ... \n");
  await ht.setMinter(wrapp.address).then(log => console);

  console.log("\n\n verify contracts ... \n");
  await hre.run("verify:verify", {address: ht.address, contractorArguments:[]}).then(console.log("verify contract HouseToken successfully"));
  await hre.run("verify:verify", {address: wrapp.address, contractorArguments:[ht.address]}).then(console.log("verify contract HouseWrapper successfully"));
  await hre.run("verify:verify", {address: spr.address, contractorArguments:[0,[]]}).then(console.log("verify contract SpellRegist successfully"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
