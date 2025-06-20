// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./cToken.sol";

contract LendingMarket {
    cToken public cTokenContract;

    constructor(address _cToken) {
        cTokenContract = cToken(_cToken);
    }

    function supply(uint256 amount) external {
        // User supplies `amount` of underlying
        // Approve should be done off-chain first
        // Call cToken.mint(amount)
    }

    function redeem(uint256 cTokenAmount) external {
        // User redeems cTokenAmount for underlying
        // Call cToken.redeem(cTokenAmount)
    }

    function borrow(uint256 amount) external {
        // User borrows `amount` of underlying
        // Call cToken.borrow(amount)
    }

    function repay(uint256 amount) external {
        // User repays `amount` of underlying
        // Call cToken.repay(amount)
    }

    function getUserBorrowBalance(address user) external view returns (uint256) {
        // Return user’s borrow balance from cToken contract
    }

    function getExchangeRate() external view returns (uint256) {
        // Return current exchangeRate from cToken
    }
}
