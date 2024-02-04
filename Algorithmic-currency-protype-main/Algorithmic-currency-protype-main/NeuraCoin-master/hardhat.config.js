require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");

require("hardhat-deploy");
require ('dotenv').config();
const PRIVATE_KEY = "0x43e303136c7eb24384ff665d182ebf2f241a95838869b12c67a785b7b69681c6";
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks:{
    localganache : {
      url: 'HTTP://127.0.0.1:7545',
      accounts : [PRIVATE_KEY],
  }
},
solidity: {
  version: "0.8.20",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
},
paths: {
  sources: "./contracts",
  tests: "./test",
  cache: "./cache",
  artifacts: "./artifacts"
},
mocha: {
  timeout: 40000
}
};
