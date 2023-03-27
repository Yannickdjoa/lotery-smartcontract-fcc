require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config()
require("hardhat-deploy")

GOERLI_URL = process.env.GOERLI_URL
GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.7",
            },
            {
                version: "0.4.24",
            },
        ],
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        localhost: {
            chainId: 31337,
            blockConfirmations: 1,
            url: "http://localhost:8545",
        },
        // goerli: {
        //     chainId: 5,
        //     url: GOERLI_URL,
        //     accounts: [GOERLI_PRIVATE_KEY],
        // },
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        player: {
            default: 1,
        },
    },
}
