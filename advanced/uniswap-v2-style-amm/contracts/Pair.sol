// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract Pair is ERC20 {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    constructor() ERC20("LP Token", "LP") {}

    function initialize(address _token0, address _token1) external {
        require(token0 == address(0) && token1 != address(0), "Zero address");
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestampLast);
    }

    function _update(uint112 _reserve0, uint112 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = uint32(block.timestamp);
    }

    function mint(address to) external returns (uint256 liquidity) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        if (totalSupply() == 0) {
            liquidity = Math.sqrt(amount0 * amount1);
        } else {
            liquidity = Math.min((amount0 * totalSupply()) / reserve0, (amount1 * totalSupply()) / reserve1);
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        _mint(to, liquidity);
        _update(uint112(balance0), uint112(balance1));
    }

    function burn(address to) external returns (uint256 amount0, uint256 amount1) {
        uint256 liquidity = balanceOf(address(this));
        require(liquidity > 0, "Insufficient liquidity");

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        amount0 = (liquidity * balance0) / totalSupply();
        amount1 = (liquidity * balance1) / totalSupply();

        require(amount0 > 0 && amount1 > 0, "Insufficient amounts burned");

        _burn(address(this), liquidity);
        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);

        _update(uint112(IERC20(token0).balanceOf(address(this))), uint112(IERC20(token1).balanceOf(address(this))));

        return (amount0, amount1);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");

        (uint112 _reserve0, uint112 _reserve1,) = getReserves();

        require(amount0Out < _reserve0 && amount1Out < _reserve1, "Insufficient reserves");

        if (amount0Out > 0) {
            IERC20(token0).transfer(to, amount0Out);
        }

        if (amount1Out > 0) {
            IERC20(token1).transfer(to, amount1Out);
        }

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        require(balance0 * balance1 >= uint256(_reserve0) * uint256(_reserve1), "K");

        _update(uint112(balance0), uint112(balance1));
    }

    function sync() external {
        _update(uint112(IERC20(token0).balanceOf(address(this))), uint112(IERC20(token1).balanceOf(address(this))));
    }
}
