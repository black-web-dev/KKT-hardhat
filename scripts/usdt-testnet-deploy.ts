import hre, {ethers} from "hardhat";

import * as fs from "fs";

async function main() {
    var dir = "./deployed";

    const TUSDT = await ethers.getContractFactory("TUSDT");

    const tusdtContract = await TUSDT.deploy(100000);
    await tusdtContract.deployed();
    console.log("TUSDT contract address: ", tusdtContract.address);
    await fs.writeFileSync(`${dir}/testnet-usdt.txt`, tusdtContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
