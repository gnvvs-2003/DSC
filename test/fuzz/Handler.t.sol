// SPDX-License-Identifier: MIt
pragma solidity ^0.8.18;

import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";

import {Test} from "forge-std/Test.sol";

import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    ERC20Mock weth;
    ERC20Mock wbtc;

    DSCEngine engine;
    DecentralizedStableCoin dsc;

    uint256 public timesMintIsCalled;

    address [] usersWithCollateralDeposited;

    constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
        engine = _engine;
        dsc = _dsc;

        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    // Deposit collateral

    function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral);
        collateral.approve(address(engine), amountCollateral);
        engine.depositCollateral(address(collateral), amountCollateral);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);
    }

    // Redeem collateral
    function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = engine.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }
        engine.redeemCollateral(address(collateral), amountCollateral);
    }

    // mint DSC

    function mintDsc(uint256 amount,uint256 addressSeed) public{
        if(usersWithCollateralDeposited.length == 0){
            return ;
        }
        address sender = usersWithCollateralDeposited[addressSeed%usersWithCollateralDeposited.length];
        (uint256 totalDscMinted,uint256 collateralValueInUSD) = engine.getAccountInformation(sender);
        uint256 maxDscToMint = (collateralValueInUSD/2) - totalDscMinted;
        if(maxDscToMint < 0){
            return ;
        }
        amount = bound(amount,0,maxDscToMint);
        if(amount < 0){
            return ;
        }
        vm.startPrank(msg.sender);
        engine.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled+=1;
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
