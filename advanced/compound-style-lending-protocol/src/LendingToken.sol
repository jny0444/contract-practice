// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract LendingToken is ERC20Burnable {
    constructor() ERC20("Lending Token", "LTN") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
