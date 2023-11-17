// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TUSDT is ERC20 {
    constructor(uint256 cap) ERC20("TUSDT Token", "TUSDT") {
        _mint(msg.sender, cap * 1000000);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
