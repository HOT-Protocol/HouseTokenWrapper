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
  networks: {
    main: {
      url: "https://main.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: []
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: []
    }
  },
  etherscan: {
    apiKey: "4G2S76NN697YDSP2HRR78AAGEIDWAF9TGV"
  }
};
