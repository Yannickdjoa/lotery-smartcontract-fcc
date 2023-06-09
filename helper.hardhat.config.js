const { ethers } = require("hardhat")

const networkConfig = {
    31337: {
        name: "localhost",
        interval: "60",
        entranceFee: ethers.utils.parseEther("0.1"),
        callbackGasLimit: "500000",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    },
    5: {
        name: "goerli",
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        subscriptionId: "10876",
        callbackGasLimit: "500000",
        interval: "60",
        entranceFee: ethers.utils.parseEther("0.1"),
    },
}
const developmentChains = ["hardhat", "localhost"]
VERIFICATION_BLOCK_CONFIRMATIONS = 6
const DECIMALS = 8
const INITIAL_ANSWER = 200000000000
module.exports = {
    networkConfig,
    developmentChains,
    DECIMALS,
    INITIAL_ANSWER,
    VERIFICATION_BLOCK_CONFIRMATIONS,
}
