// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockERC20FailTransfer} from "../mocks/MockERC20FailTransfer.sol";
import {MockFailedTransferFrom} from "../mocks/MockFailedTransferFrom.sol";
import {MockFailedTransfer} from "../mocks/MockFailedTransfer.sol";
import {MockFailedMintDSC} from "../mocks/MockFailedMintDSC.sol";
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

    uint256 amountCollateral = 10 ether;
    uint256 amountToMint = 100 ether;

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
        uint256 expectedResult = (usdAmountInWei * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION);
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
    function test__revertsIfTransferFromFails() public {
        address owner = msg.sender;
        vm.prank(owner);
        // failing mock
        MockFailedTransferFrom mockCollateral = new MockFailedTransferFrom();
        tokenAddress = [address(mockCollateral)];
        priceFeedAddress = [ethUsdPriceFeed];
        vm.prank(owner);
        DSCEngine mockDSE = new DSCEngine(tokenAddress, priceFeedAddress, address(dsc));
        mockCollateral.mint(USER, amountCollateral);
        vm.startPrank(USER);
        ERC20Mock(address(mockCollateral)).approve(address(mockDSE), amountCollateral);
        vm.expectRevert(DSCEngine.DSCEngine__TransferFailed.selector);
        mockDSE.depositCollateral(address(mockCollateral), amountCollateral);
        vm.stopPrank();
    }

    /**
     * @notice smaller tests for deposit collateral
     */
    function test__revertWhenUnapprovedCollateral() public {
        ERC20Mock mockToken = new ERC20Mock("Unapproved", "UAT", USER, 100e18);
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__TokenNotAllowed.selector, address(mockToken)));
        engine.depositCollateral(address(mockToken), amountCollateral);
        vm.stopPrank();
    }

    /**
     * @notice function to test the deposit collateral without minting
     * @notice this function is after the token is accepted
     */
    modifier depositedCollateral() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateral(weth, amountCollateral); // <-- missing before
        vm.stopPrank();
        _;
    }

    function test__depositCollateralWithoutMinting() public depositedCollateral {
        // testing the toalDSC minted with 0
        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    function test__canDepositedCollateralAndGetAccountInfo() public depositedCollateral {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);

        assertEq(totalDscMinted, 0);
        // direct check: collateralValueInUsd == USD value of deposited amount
        assertEq(collateralValueInUsd, engine.getUsdValue(weth, amountCollateral));
    }

    /**
     * @notice The following are the tests for minting
     * @notice Requires a seperate setup for minting
     */
    function test__revertsIfMintingFails() public {
        MockFailedMintDSC mockDsc = new MockFailedMintDSC();
        tokenAddress = [weth];
        priceFeedAddress = [ethUsdPriceFeed];
        address owner = msg.sender;
        vm.prank(owner);
        DSCEngine mockDscEngine = new DSCEngine(tokenAddress, priceFeedAddress, address(mockDsc));
        mockDsc.transferOwnership(address(mockDscEngine));
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(mockDscEngine), amountCollateral);
        vm.expectRevert(DSCEngine.DSCEngine__MintFailed.selector);
        mockDscEngine.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
    }

    function test__revertIfMintAmountIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateral(weth, amountCollateral);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.mintDsc(0);
        vm.stopPrank();
    }

    function test__revertsIfMintAmountBreaksHealthFactor() public depositedCollateral {
        (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRoundData();
        amountToMint =
            (amountCollateral * (uint256(price) * engine.getAdditionalFeedPrecision())) / engine.getPrecision();
        vm.startPrank(USER);
        uint256 expectedHealthFactor =
            engine.calculateHealthFactor(amountToMint, engine.getUsdValue(weth, amountCollateral));
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.mintDsc(amountToMint);
        vm.stopPrank();
    }

    function test__canMintDsc() public depositedCollateral {
        vm.prank(USER);
        engine.mintDsc(amountToMint);
        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(amountToMint, userBalance);
    }

    /**
     * @notice : Now testing deposit colllateral and mint dsc
     */
    function test__revertIfDepositAndMintBreaksHealthFactor() public {
        (, int256 price,,,) = MockV3Aggregator(ethUsdPriceFeed).latestRoundData();
        amountToMint =
            (amountCollateral * (uint256(price) * engine.getAdditionalFeedPrecision())) / engine.getPrecision();
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);

        uint256 expectedHealthFactor =
            engine.calculateHealthFactor(amountToMint, engine.getUsdValue(weth, amountCollateral));
        vm.expectRevert(abi.encodeWithSelector(DSCEngine.DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
    }

    modifier depositedCollateralAndMintedDsc() {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
        vm.stopPrank();
        _;
    }

    function test__canMintWithDepositedCollateral() public depositedCollateralAndMintedDsc {
        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(userBalance, amountToMint);
    }

    /**
     * @notice : burn dsc tests
     */
    function test__revertIfBurnDscIsZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine), amountCollateral);
        engine.depositCollateralAndMintDsc(weth, amountCollateral, amountToMint);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.burnDsc(0);
        vm.stopPrank();
    }

    function test__cantBurnMoreThanUserHas() public {
        vm.prank(USER);
        vm.expectRevert();
        engine.burnDsc(1);
    }

    function test__canBurnDsc() public depositedCollateralAndMintedDsc {
        vm.startPrank(USER);
        dsc.approve(address(engine), amountToMint);
        engine.burnDsc(amountToMint);
        vm.stopPrank();
        uint256 userBalance = dsc.balanceOf(USER);
        assertEq(userBalance, 0);
    }

    /**
     * @notice : Redeem collateral function tests
     * @notice : Needs its own setup
     * 1. Make a failed transaction 
     * 2. mint 
     * 3. transfer the ownership to engine
     * 4. aprove 
     * 5. deposit collateral
     * 6. redeem collateral
     */
    function test__revertIfTransferFails() public {
        address owner = msg.sender;
        vm.prank(owner);
        MockFailedTransfer mockDsc = new MockFailedTransfer();
        tokenAddress = [address(mockDsc)];
        priceFeedAddress = [ethUsdPriceFeed];
        vm.prank(owner);

        DSCEngine engine = new DSCEngine(tokenAddress, priceFeedAddress, address(mockDsc));

        mockDsc.mint(USER, amountCollateral);
        // transfer the ownership
        vm.prank(owner);
        mockDsc.transferOwnership(address(engine));
        // change to user
        vm.startPrank(USER);
        ERC20Mock(address(mockDsc)).approve(address(engine), amountCollateral);
        // deposit and redeem
        engine.depositCollateral(address(mockDsc), amountCollateral);
        vm.expectRevert(DSCEngine.DSCEngine__TransferFailed.selector);
        engine.redeemCollateral(address(mockDsc), amountCollateral);
        vm.stopPrank();
    }

    function test__redeemAmountIsGreaterThanZero() public{
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(engine),amountCollateral);
        engine.depositCollateralAndMintDsc(weth,amountCollateral,amountToMint);
        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        engine.redeemCollateral(weth,0);
        vm.stopPrank();
    }

    function test__redeemCollateral() public depositedCollateral{
        vm.startPrank(USER);
        uint256 initialUserBalance = engine.getCollateralBalanceOfUser(USER,weth);
        assertEq(initialUserBalance,amountCollateral);
        engine.redeemCollateral(weth,amountCollateral);
        uint256 userBalanceAfterRedeemCollateral = engine.getCollateralBalanceOfUser(USER,weth);
        assertEq(userBalanceAfterRedeemCollateral,0);
        vm.stopPrank();
    }

    function test__emitCollateralRedeemedWithCorrectArguments() public depositedCollateral{
        vm.expectEmit(true,true,true,true,address(engine));
        emit DSCEngine.CollateralRedeemed(USER,USER,weth,amountCollateral);
        vm.startPrank(USER);
        engine.redeemCollateral(weth,amountCollateral);
        vm.stopPrank();
    }





}
