const hre = require("hardhat");

async function main() {
  console.log("Deploying NeuraCoin...");

  const Neuracoin = await hre.ethers.getContractFactory("NeuraCoin");
  const neuraCoin = await Neuracoin.deploy(100_000_000_000_000, 5_000);

 //await neuraCoin.deploy();

  console.log(`NeuraCoin deployed at ${neuraCoin.address}`);



  // Additional deployment steps or contracts can be added here

  console.log("Deployment completed!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
