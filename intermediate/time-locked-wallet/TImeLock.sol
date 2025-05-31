// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract TimeLock {
    address public owner;
    uint256 public unlockTime;

    constructor(uint256 _unlockTime) {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");
        owner = msg.sender;
        unlockTime = _unlockTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyAfterUnlock() {
        require(block.timestamp >= unlockTime, "Cannot execute before unlock time");
        _;
    }

    function addFunds() external payable onlyOwner {
        require(msg.value > 0, "Must send some ether");
    }

    function withdrawFunds() external onlyOwner onlyAfterUnlock {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUnlockTime() external view returns (uint256) {
        return unlockTime;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
