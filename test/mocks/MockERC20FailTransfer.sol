// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/**
 * @title MockERC20FailTransfer contract
 * @author chat-gpt
 * @notice This mock always fails for every transaction
 */

contract MockERC20FailTransfer is ERC20 {
    constructor() ERC20("BadToken", "BAD") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Override transferFrom to always return false
    function transferFrom(address from, address to, uint256 amount) public pure override returns (bool) {
        // Pretend to fail token transfer
        return false;
    }
}
