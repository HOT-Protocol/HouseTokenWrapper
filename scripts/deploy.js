// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const SpellRegistry = await hre.ethers.getContractFactory("SpellRegistry");
  const HouseToken = await hre.ethers.getContractFactory("HouseToken");
  const HouseTokenFactory = await hre.ethers.getContractFactory("HouseTokenFactory");

  console.log("\nDeploy Contract ...")
  const ht = await HouseToken.deploy();
  const factory = await HouseTokenFactory.deploy(ht.address).then();
  const spr = await SpellRegistry.deploy([]);

  console.log(
    `all contracts was deployed successfully ...
      HouseToken = ${ht.address}
      HouseTokenFactory = ${factory.address}
      SpellRegistry = ${spr.address}`
  );

  console.log("\n\n set contracts ... \n");
  await ht.setMinter(factory.address).then(log => console);

  console.log("\n\n verify contracts ... \n");
  await hre.run("verify:verify", {address: ht.address}).then(log => console);
  await hre.run("verify:verify", {address: factory.address}).then(log => console);
  await hre.run("verify:verify", {address: spr.address}).then(log => console);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
