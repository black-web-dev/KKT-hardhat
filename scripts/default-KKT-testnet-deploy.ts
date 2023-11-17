import {ethers, network, upgrades} from "hardhat";

import * as fs from "fs";

async function main() {
    var dir = "./deployed";

    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir);
    }

    // Obtain reference to contract and ABI.
    const DefaultKKTContract = await ethers.getContractFactory("DefaultKKT");
    console.log("DefaultKKT Contract is deploying to ", network.name);

    //  Deploy logic contract using the proxy pattern.
    const DefaultKKTContract_ = await upgrades.deployProxy(
        DefaultKKTContract,

        //Since the logic contract has an initialize() function
        // we need to pass in the arguments to the initialize()
        // function here.
        [100000000],

        // We don't need to expressly specify this
        // as the Hardhat runtime will default to the name 'initialize'
        {initializer: "initialize"}
    );
    await DefaultKKTContract_.deployed();
    await fs.writeFileSync(
        `${dir}/testnet-kkt-proxy.txt`,
        DefaultKKTContract_.address
    );

    console.log(
        "DefaultKKT Contract deployed to:",
        DefaultKKTContract_.address
    );
}

main();
