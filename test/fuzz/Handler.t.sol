// SPDX-License-Identifier: MIt
pragma solidity ^0.8.18;

import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";

import {Test} from "forge-std/Test.sol";

import {ERC20Mock} from  "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract Handler is Test{
    uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

    ERC20Mock weth;
    ERC20Mock wbtc;

    DSCEngine engine;
    DecentralizedStableCoin dsc;

    constructor(DSCEngine _engine , DecentralizedStableCoin _dsc){
        engine = _engine;
        dsc = _dsc;

        address [] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    function depositCollateral(uint256 collateralSeed , uint256 amountCollateral) public{
        amountCollateral = bound(amountCollateral,1,MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender,amountCollateral);
        collateral.approve(address(engine),amountCollateral);
        engine.depositCollateral(address(collateral),amountCollateral);
        vm.stopPrank();
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns(ERC20Mock){
        if (collateralSeed % 2 == 0){
            return weth;
        }
        return wbtc;
    }
}