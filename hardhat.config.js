require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.15",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "goerli",
  networks: {
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: ["2fefc9890dd45abfca51bbd9a72bc5efc0ceb5174261b309bc9698cb1b28796b"]
    }
  },
  etherscan: {
    apiKey: "4G2S76NN697YDSP2HRR78AAGEIDWAF9TGV"
  }
};
