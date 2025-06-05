// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPair {
    function initialize(address token0, address token1) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to) external;

    function mint(address to) external returns (uint256 liquidity);  // Only for Factory
    function burn(address to) external returns (uint256 amount0, uint256 amount1); // Only for Factory
}


