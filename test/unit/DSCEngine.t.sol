// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

import {Test} from "forge-std/Test.sol";

import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";

import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";

/**
 * @title DSCEngine Testing contract
 * @author gnvvs-2003
 * @notice This contract tests all the functionality of DSCEngine contract
 */
contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;

    address weth;
    // address wbtc;
    address ethUsdPriceFeed;
    // address btcUsdPriceFeed;

    address public USER = makeAddr("user");
    uint256 public COLLATERAL_VALUE = 10 ether;
    uint256 public INITIAL_BALANCE = 10 ether;

    /**
     * @notice : Setting up the contract for tests
     */
    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        // token address onyl for ETH/USD for ref from HelperConfig>NetworkConfig
        (ethUsdPriceFeed,, weth,,) = config.activeNetworkConfig();
        // Assuming it's 2000 USD per ETH for the test
        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(2000e8); // 8 decimals for Chainlink
        // adding the user a initial balance of 10 ether
        ERC20Mock(weth).mint(USER, INITIAL_BALANCE);
    }

    /**
     * @notice :Unit tests
     */

    // 1. Price Tests

    function test__getUsdValue() public view {
        // params in the function are token , amount
        uint256 ethAmount = 15e18;
        uint256 expectedUsdValue = 30000e18;
        uint256 actualUsdValue = engine.getUsdValue(weth, ethAmount);
        assertEq(expectedUsdValue, actualUsdValue);
    }

    // 2. Deposit collateral
    function test__revertIfCollateralIsZero() public {
        // pranking as user
        vm.startPrank(USER);
        // mocking
        ERC20Mock(weth).approveInternal(address(engine), USER, COLLATERAL_VALUE);
        // revert
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        // functions to be expected a revert
        engine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
