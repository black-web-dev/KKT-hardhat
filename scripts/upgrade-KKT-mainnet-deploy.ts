import {ethers, upgrades} from "hardhat";
import * as fs from "fs";

async function main() {
    const deployedProxyAddress = fs.readFileSync(
        "./deployed/mainnet-kkt-proxy.txt",
        {
            encoding: "utf8",
        }
    );
    console.log("KKT Contract Proxy Address: " + deployedProxyAddress);

    const UpgradedKKTV2 = await ethers.getContractFactory("KKT");

    console.log("Upgrading KKT Contract to V2...");

    await upgrades.upgradeProxy(deployedProxyAddress, UpgradedKKTV2);
    console.log("KKT Proxy upgraded");
}

main();
