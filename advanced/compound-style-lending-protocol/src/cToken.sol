// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Comptroller.sol";
import "./InterestRateModel.sol";

contract cToken is ERC20 {
    IERC20 public immutable underlying;
    Comptroller public comptroller;
    InterestRateModel public interestRateModel;

    uint256 public exchangeRate;
    uint256 public totalBorrows;
    uint256 public totalReserves;
    uint256 public accrualBlockNumber;

    mapping(address => uint256) public borrowBalance;

    constructor(
        address _underlying,
        address _comptroller,
        address _interestRateModel
    ) ERC20("cToken", "cTOKEN") {
        underlying = IERC20(_underlying);
        comptroller = Comptroller(_comptroller);
        interestRateModel = InterestRateModel(_interestRateModel);
        exchangeRate = 1e18;
    }

    function mint(uint256 amount) external {
        // accrueInterest()
        // Transfer `amount` of underlying from user to contract
        // Mint cTokens to user based on current exchangeRate
    }

    function redeem(uint256 cTokenAmount) external {
        // accrueInterest()
        // Burn cTokens
        // Transfer underlying = cTokenAmount * exchangeRate / 1e18 to user
    }

    function borrow(uint256 amount) external {
        // accrueInterest()
        // Check collateral from comptroller
        // Update borrowBalance and totalBorrows
        // Transfer underlying to borrower
    }

    function repay(uint256 amount) external {
        // accrueInterest()
        // Transfer underlying from user to contract
        // Reduce borrowBalance and totalBorrows
    }

    function accrueInterest() public {
        // Use InterestRateModel to calculate interest
        // Update totalBorrows, totalReserves, and exchangeRate
    }
}
