import {ethers, run} from "hardhat";

async function main() {
    const kakiOrder = await ethers.getContractFactory("KakiOrder");

    const kaki = await kakiOrder.deploy();
    console.log("KakiOrder deployed to address:", kaki.address);
    
    run("verify:verify", {
        address: kaki.address,
    })
        .then(() => {
            console.log("KakiOrder verified successfully");
        })
        .catch(() => console.log("KakiOrder not verified"));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
