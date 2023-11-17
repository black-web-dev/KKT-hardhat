import hre from "hardhat";
import {HardhatRuntimeEnvironment} from "hardhat/types";

describe("KakiOrder NFT", function () {
    let kakiContract: any;

    before(async function () {
        const [owner] = await hre.ethers.getSigners();
        const kakiOrder = await hre.ethers.getContractFactory("BasicNFT");
        kakiContract = await kakiOrder.deploy();

        await kakiContract.deployed();

        await kakiContract
            .connect(owner)
            .initialize(
                "https://ipfs.io/ipfs/QmVv7iABg6DSzo8BHBgGqptGX49TAn1q5eEigPUj3bCBD5/",
                "0xd9faD5E6997e72d726bdCe6C441f3Edf9d908776",
                "0x11C59838463Dbfd4302854F4F02498d979Ef0af3",
                "0x5D5dC95d2B3a456F716D24802219A0a94BFd16Bb",
                "0xE592427A0AEce92De3Edee1F18E0157C05861564",
                20,
                2
            );

        console.log(`Verifying contract on...`);

        // await hre.run(`verify:verify`, {
        //     address: kakiContract.address,
        //     constructorArguments: [],
        // });
    });

    describe("Deployment", function () {
        it("Should deploy and verify KakiOrder", async function () {
            console.log("KakiOrder deployed to: ", kakiContract.address);
        });

        // it("Mint basicNFT(Number 1) on KakiOrder contract", async function () {
        //     const [owner] = await hre.ethers.getSigners();

        //     const basicNFTDetail = await kakiContract._nftTypeDetails(0);
        //     const basicNFTPrice = await kakiContract.getCurrentMintPrice(
        //         0,
        //         Number(basicNFTDetail.mintedAmount) + 1
        //     );
        //     await kakiContract.connect(owner).mint(0, {value: basicNFTPrice});
        //     const updatedBasicNFTDetail = await kakiContract._nftTypeDetails(0);
        //     console.log("Basic NFT detail: ", updatedBasicNFTDetail);

        //     const balanceOfOwner = await kakiContract.balanceOf(owner.address);
        //     console.log("Balance of NFT by Owner: ", balanceOfOwner);
        // });

        // it("Mint commonNFT(Number 2) on KakiOrder contract", async function () {
        //     const [owner] = await hre.ethers.getSigners();

        //     let commonNFTDetail = await kakiContract._nftTypeDetails(1);
        //     let commonNFTPrice = await kakiContract.getCurrentMintPrice(
        //         1,
        //         Number(commonNFTDetail.mintedAmount) + 1
        //     );
        //     await kakiContract.connect(owner).mint(1, {value: commonNFTPrice});

        //     commonNFTDetail = await kakiContract._nftTypeDetails(1);
        //     commonNFTPrice = await kakiContract.getCurrentMintPrice(
        //         1,
        //         Number(commonNFTDetail.mintedAmount) + 1
        //     );
        //     await kakiContract.connect(owner).mint(1, {value: commonNFTPrice});

        //     const updatedBasicNFTDetail = await kakiContract._nftTypeDetails(1);
        //     console.log("Common NFT detail: ", updatedBasicNFTDetail);

        //     const nftITems = await kakiContract.getNftItemsByAddress(
        //         owner.address
        //     );
        //     console.log("NFT items of owner address: ", nftITems);
        // });

        it("Stake and unStatke", async function () {
            const [owner] = await hre.ethers.getSigners();

            await kakiContract.connect(owner).mint();

            const balanceOf = await kakiContract.balanceOf(owner.address);
            console.log("Basic NFT balanceOf: ", balanceOf);

            kakiContract.connect(owner).setApprovalForAll(kakiContract.address, true);
            await kakiContract.connect(owner).staking(1);
            const address = await kakiContract.ownerOf(1);
            console.log('Owner Address: ', address);

            await kakiContract.connect(owner).unstaking(1);

            const balanceOfkakiContract = await kakiContract.balanceOf(kakiContract.address);
            console.log("Basic NFT balanceOf kakiContract: ", balanceOfkakiContract);
        });
    });
});
