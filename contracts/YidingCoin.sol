// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract YidingCoin is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18; // 1亿代币
    constructor() ERC20("YidingCoin", "YDC") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

}