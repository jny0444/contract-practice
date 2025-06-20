// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InterestRateModel {
    uint256 public constant BASE_RATE = 1e16;
    uint256 public constant MULTIPLIER = 4e16;

    function getBorrowRate(uint256 cash, uint256 borrows, uint256 reserves) external pure returns (uint256) {
        if (borrows == 0) {
            return BASE_RATE;
        }

        uint256 utilizationRate = (borrows * 1e18) / (cash + borrows - reserves);
        uint256 borrowRate = BASE_RATE + (utilizationRate * MULTIPLIER) / 1e18;
        return borrowRate;
    }

    function getSupplyRate(uint256 borrowRate, uint256 reserveFactor) external pure returns (uint256) {
        uint256 oneMinusReserveFactor = 1e18 - reserveFactor;
        return (borrowRate * oneMinusReserveFactor) / 1e18;
    }
}
