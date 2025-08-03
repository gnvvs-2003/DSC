// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @title : DecentralizedStableCoin
 * Collateral : Exogeneous crypto (ETH or BTC)
 * Minting : algorithmic
 * relative stability : pegged to USD
 * This contract is meant to be governed by DSCEngine This contract is just the ERC20 implementation of our stable coin
 */
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    constructor(address initialOwner) ERC20("DecentralizedStableCoin", "DSC") Ownable(initialOwner) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanOne();
        }
        if (_amount > balance) {
            revert DecentralizedStableCoin__BurnAmountMustBeLessThanBalance();
        }
        // burn
        super.burn(_amount); // `super` from `ERC20Burnable` contract
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        uint256 balance = balanceOf(msg.sender);
        if (_to == address(0)) {
            revert DecentralizedStableCoin__MintToZeroAddress();
        }
        if (_amount > balance) {
            revert DecentralizedStableCoin__BurnAmountMustBeLessThanBalance();
        }
        _mint(_to, _amount);
        return true;
    }

    error DecentralizedStableCoin__MustBeMoreThanOne();
    error DecentralizedStableCoin__BurnAmountMustBeLessThanBalance();
    error DecentralizedStableCoin__MintToZeroAddress();
}
