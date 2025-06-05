// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IFactory} from "./interfaces/IFactory.sol";
import {IPair} from "./interfaces/IPair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract Router {
    address public immutable factory;

    constructor(address _factory) {
        require(_factory != address(0), "Factory address cannot be zero");
        factory = _factory;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        address pair = IFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = IFactory(factory).createPair(tokenA, tokenB);
        }

        (uint112 reserve0, uint112 reserve1,) = IPair(pair).getReserves();
        (amountA, amountB) = (tokenA < tokenB)
            ? _calculateLiquidityAmounts(amountADesired, amountBDesired, amountAMin, amountBMin, reserve0, reserve1)
            : _calculateLiquidityAmounts(amountBDesired, amountADesired, amountBMin, amountAMin, reserve1, reserve0);

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);
        liquidity = IPair(pair).mint(to);

        require(liquidity > 0, "Insufficient liquidity minted");
        require(amountA >= amountAMin, "Insufficient A amount");
        require(amountB >= amountBMin, "Insufficient B amount");
    }

    function _calculateLiquidityAmounts(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint112 reserveA,
        uint112 reserveB
    ) private pure returns (uint256 amountA, uint256 amountB) {
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Insufficient B amount");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "Insufficient A amount");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = IFactory(factory).getPair(tokenA, tokenB);
        require(pair != address(0), "Pair does not exist");

        IERC20(pair).transferFrom(msg.sender, pair, liquidity);
        (amountA, amountB) = IPair(pair).burn(to);

        require(amountA >= amountAMin, "Insufficient A amount");
        require(amountB >= amountBMin, "Insufficient B amount");
    }

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to)
        external
        returns (uint256[] memory amounts)
    {
        require(path.length >= 2, "Invalid path length");
        amounts = getAmountsOut(amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "Insufficient output amount");

        IERC20(path[0]).transferFrom(msg.sender, IFactory(factory).getPair(path[0], path[1]), amounts[0]);

        for (uint256 i = 0; i < path.length - 1; i++) {
            address input = path[i];
            address output = path[i + 1];
            address pair = IFactory(factory).getPair(input, output);
            (address token0,) = input < output ? (input, output) : (output, input);

            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));

            address nextTo = i < path.length - 2 ? IFactory(factory).getPair(output, path[i + 2]) : to;

            IPair(pair).swap(amount0Out, amount1Out, nextTo);
        }
    }

    function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts) {
        require(path.length >= 2, "INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i = 0; i < path.length - 1; i++) {
            address pair = IFactory(factory).getPair(path[i], path[i + 1]);
            require(pair != address(0), "PAIR_NOT_FOUND");
            (uint112 reserve0, uint112 reserve1,) = IPair(pair).getReserves();
            (uint112 reserveIn, uint112 reserveOut) =
                path[i] < path[i + 1] ? (reserve0, reserve1) : (reserve1, reserve0);
            require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
            amounts[i + 1] = (amounts[i] * reserveOut) / (reserveIn + amounts[i]);
        }
    }
}
