import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-gas-reporter";
import "solidity-coverage";
import * as dotenv from "dotenv";
import {HardhatUserConfig, task} from "hardhat/config";
import * as process from "process";

dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.17",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {},
        polygonMumbai: {
            url: process.env.MUMBAI_RPC_URL,
            accounts: process.env.TEST_WALLET_PRIVATE_KEY
                ? [process.env.TEST_WALLET_PRIVATE_KEY]
                : [],
            chainId: 80001,
        },
        polygonMatic: {
            url: process.env.MATIC_RPC_URL,
            accounts: process.env.MAIN_WALLET_PRIVATE_KEY
                ? [process.env.MAIN_WALLET_PRIVATE_KEY]
                : [],
            chainId: 137,
        },
    },

    etherscan: {
        apiKey: process.env.POLYGONSCAN_API_KEY,
    },
};

export default config;
