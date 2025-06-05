// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IPair} from "./interfaces/IPair.sol";
import {Pair} from "./Pair.sol";

contract Factory {
    mapping(address => mapping(address => address)) public pairFor;
    address[] public allPairAddresses;

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Zero address");
        require(pairFor[token0][token1] == address(0), "Pair already exists");

        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IPair(pair).initialize(token0, token1);

        pairFor[token0][token1] = pair;
        pairFor[token1][token0] = pair;
        allPairAddresses.push(pair);
    }

    function getPair(address tokenA, address tokenB) external view returns (address pair) {
        require(tokenA != tokenB, "Identical addresses");
        require(tokenA != address(0) && tokenB != address(0), "Zero address");
        return pairFor[tokenA][tokenB];
    }

    function allPairs(uint256 index) external view returns (address pair) {
        return allPairAddresses[index];
    }

    function allPairsLength() external view returns (uint256) {
        return allPairAddresses.length;
    }
}
