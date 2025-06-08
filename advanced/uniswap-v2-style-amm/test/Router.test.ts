import hre from "hardhat";
import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { parseEther } from "viem";

describe("Router Test Cases", function () {
    async function deployRouterFixture() {
        const [deployer, acc1, acc2] = await hre.viem.getWalletClients();

        
    }
})