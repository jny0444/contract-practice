// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Comptroller {
    mapping(address => bool) public hasEnteredMarket;
    mapping(address => uint256) public collateralBalance;

    function enterMarket(address user) external {
        // Mark user as having supplied collateral
    }

    function getAccountLiquidity(address user) external view returns (uint256 collateralValue, uint256 borrowLimit) {
        // Return value of collateral and how much they can borrow
    }

    function isLiquidatable(address user) external view returns (bool) {
        // Return true if user has become undercollateralized
    }
}
