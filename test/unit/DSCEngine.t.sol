// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockERC20FailTransfer} from "../mocks/MockERC20FailTransfer.sol";
import {MockFailedTransferFrom} from "../mocks/MockFailedTransferFrom.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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
    address wbtc;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    uint256 deployerKey;

    address public USER = makeAddr("user");
    uint256 public COLLATERAL_VALUE = 10 ether;
    uint256 public INITIAL_BALANCE = 10 ether;

    uint256 amountCollteral = 10 ether;

    /**
     * @notice : Setting up the contract for tests
     */
    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        // token address onyl for ETH/USD for ref from HelperConfig>NetworkConfig
        (ethUsdPriceFeed, btcUsdPriceFeed, weth, wbtc, deployerKey) = config.activeNetworkConfig();
        // Assuming it's 2000 USD per ETH for the test
        MockV3Aggregator(ethUsdPriceFeed).updateAnswer(2000e8); // 8 decimals for Chainlink
        // adding the user a initial balance of 10 ether
        ERC20Mock(weth).mint(USER, INITIAL_BALANCE);
    }

    /**
     * @notice : Constructor test
     * @notice : All the tokens should be avalable in the price feeds
     * @notice : If tokens contains etc and btc but pricefeeds contain onyl etc then we expect a revert
     */
    address[] public tokenAddress;
    address[] public priceFeedAddress;

    function test__revertIfTokenLengthDoesNotMatchPriceFeedsLength() public {
        tokenAddress.push(weth);
        tokenAddress.push(wbtc);
        priceFeedAddress.push(ethUsdPriceFeed);
        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch.selector);
        new DSCEngine(tokenAddress, priceFeedAddress, address(dsc));
    }

    /**
     * @notice :getting value of tokens in usd
     * @notice : no nocking is done
     */
    function test__getUsdValue() public view {
        // params in the function are token , amount
        uint256 ethAmount = 15e18;
        uint256 expectedUsdValue = 30000e18;
        uint256 actualUsdValue = engine.getUsdValue(weth, ethAmount);
        assertEq(expectedUsdValue, actualUsdValue);
    }

    // get token amount from usd function
    function test__getTokenAmountFromUsd() public view {
        uint256 usdAmountInWei = 100 ether;
        (, int256 price,,,) = AggregatorV3Interface(ethUsdPriceFeed).latestRoundData();
        uint256 PRECISION = 1e18;
        uint256 ADDITIONAL_FEED_PRECISION = 1e10;
        uint256 expectedResult = (usdAmountInWei * PRECISION) / uint256(price) * ADDITIONAL_FEED_PRECISION;
        uint256 programaticResult = engine.getTokenAmountFromUsd(weth, usdAmountInWei);
        assertEq(expectedResult, programaticResult);
    }

    /**
     * @notice : Deposit collateral functions
     */
    function test__DepositCollateralRevertsIfZeroAmount() public {
        vm.startPrank(USER);
        vm.expectRevert(); // moreThanZero modifier should revert
        engine.depositCollateral(address(weth), 0);
        vm.stopPrank();
    }

    /**
     * @notice : reverts if collateral is zero
     */
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

    /**
     * @notice : reverts if transfers from fails
     */

    function test__revertsIfTransferFromFails() public{
        address owner = msg.sender;
        vm.prank(owner);
        // failing mock
        MockFailedTransferFrom mockCollateral = new MockFailedTransferFrom();
        tokenAddress = [address(mockCollateral)];
        priceFeedAddress = [ethUsdPriceFeed];
        vm.prank(owner);
        DSCEngine mockDSE = new DSCEngine(tokenAddress,priceFeedAddress,address(dsc));
        mockCollateral.mint(USER,amountCollteral);
        vm.startPrank(USER);
        ERC20Mock(address(mockCollateral)).approve(address(mockDSE),amountCollteral);
        vm.expectRevert(DSCEngine.DSCEngine__TransferFailed.selector);
        mockDSE.depositCollateral(address(mockCollateral),amountCollteral);
        vm.stopPrank();
    }

    /**
     * @notice : This function takes a transaction through a failing mock
     * @notice : Always gets a revert
     *
     *
     * function testDepositCollateralRevertsIfTransferFails() public {
     *     MockERC20FailTransfer badToken = new MockERC20FailTransfer();
     *     badToken.mint(USER, 100 ether);
     *
     *     vm.startPrank(USER);
     *     badToken.approve(address(engine), type(uint256).max);
     *     vm.expectRevert(DSCEngine.DSCEngine__TransferFailed.selector);
     *     engine.depositCollateral(address(badToken), 100 ether);
     *     vm.stopPrank();
     * }
     */
}
