const { run } = require("hardhat")

const verify = async function (contractAddress, args) {
    log("verifying contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.includes("contract verified")) {
            log("contract already verified")
        } else {
            log(e)
        }
    }
}
module.exports = {
    verify,
}
