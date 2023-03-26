const { network, ethers } = require("hardhat")
const {
    developmentChains,
    networkConfig,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper.hardhat.config")
const { verify } = require("../utils/verify")

//arguments
const BASE_FEE = ethers.utils.parseEther("0.25")
const GAS_PRICE_LINK = 1e9 //gas in link

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const VRF_SUB_FUND_AMOUNT = ethers.utils.parseEther("30")
    let vrfCoordinatorAddress, subscriptionId

    //args
    const entranceFee = networkConfig[chainId]["entranceFee"]
    const gasLane = networkConfig[chainId]["gasLane"]
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"]
    const interval = networkConfig[chainId]["interval"]

    // args
    const args = [
        vrfCoordinatorAddress,
        subscriptionId,
        gasLane,
        callbackGasLimit,
        interval,
        entranceFee,
    ]
    if (developmentChains.includes(network.name)) {
        log("local network detected: deploying mocks....")

        //vrfCoordinatorAddress identification

        vrfCoordinatorV2Mock = await ethers.getContract("vrfCoordinatorV2Mock")
        vrfCoordinatorAddress = vrfCoordinatorV2Mock.address

        //create subscriptionId
        transactionResponse = await vrfCoordinatorV2Mock.createSubscription()
        transactionReceipt = transactionResponse.wait(1)
        subscriptionId = transactionReceipt.events[0].args.subId
        //once subscription created you need to fund it.
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, VRF_SUB_FUND_AMOUNT)
    } else {
        vrfCoordinatorAddress = networkConfig[chainId]["vrfCoordinatorV2"]
        subscriptionId = networkConfig[chainId]["subscriptionId"]
    }
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    log("----------------------------------------------------")
    const raffle = await deploy("Raffle", {
        from: deployer,
        log: true,
        args: args,
        waitConfirmations: waitBlockConfirmations,
    })
    // Ensure the Raffle contract is a valid consumer of the VRFCoordinatorV2Mock contract.
    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        await vrfCoordinatorV2Mock.addConsumer(subscriptionId, raffle.address)
    }
    //verify the contract
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(raffle.address, args)
    }
}

module.exports.tags = ["all", "raffle"]
