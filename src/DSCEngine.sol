// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title : DSCEngine Contract :Decrentralized Stable coin engine
 * @author : gnnvs-2003
 * @notice : This system is designed as minimum as possible and have the tokens (DSC) to maintain a value of 1USD peg at all times
 * @notice : properties
 * 1. Exogeneously Collaterized (ETH or BTC)
 * 2. Dollar pegged
 * 3. Algorithmically stable
 * @notice : Similar to DAI without any governance and fee
 * @notice : Engine maintainance conditions
 * 1. Always overcollatorized
 * 2. Liquidation avalability for collatoral when under collatorized
 * @notice : This contract is the core of the complete DSC
 * @notice : This contract is based on MakerDAO DSS system
 * @notice : The complete functionality description is in `DSCEngineExplanator.md` file
 */
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";

contract DSCEngine is ReentrancyGuard {
    // ------------------CONTRACTS----------------//
    DecentralizedStableCoin private immutable i_dsc;

    // ----------------CONSTANTS-----------------------//
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200%
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant LIQUIDATION_BONUS = 10;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;

    // ------------------MAPPINGS----------------//
    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;

    //------------------ADDRESSES---------------//
    address[] private s_collateralTokens;

    //------------------MODIFIERS-------------------//
    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;
    }

    // --------------EVENTS-------------------------//
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    event CollateralRedeemed(
        address indexed redeemedFrom, address indexed redeemedTo, address indexed token, uint256 amount
    );

    // -----------------CONSTRUCTOR------------------//
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            // adding all types of tokens
            s_collateralTokens.push(tokenAddresses[i]);
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //-----------------FUNCTIONS----------------//

    /*
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        nonReentrant
        isAllowedToken(tokenCollateralAddress)
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) {
        s_DSCMinted[msg.sender] += amountDscToMint;
        // if added DSC breaks the health factor
        _revertIfHealthFactorIsBroken(msg.sender);
        // minting
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if (!minted) {
            revert DSCEngine__MintFailed();
        }
    }

    /*

    * @param tokenCollateralAddress: the address of the token to deposit as collateral
    * @param amountCollateral: The amount of collateral to deposit
    * @param amountDscToMint: The amount of DecentralizedStableCoin to mint
    * @notice: This function will deposit your collateral and mint DSC in one transaction

    */

    function depositCollateralAndMintDsc(
        address tokenCollateralAddress,
        uint256 amountCollateral,
        uint256 amountDscToMint
    ) external {
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintDsc(amountDscToMint);
    }

    /*
     * @param tokenCollateralAddress: the collateral address to redeem
     * @param amountCollateral: amount of collateral to redeem
     * @param amountDscToBurn: amount of DSC to burn
     * This function burns DSC and redeems underlying collateral in one transaction
     */

    function redeemCollateralForDsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToBurn)
        external
    {
        burnDsc(amountDscToBurn);
        redeemCollateral(tokenCollateralAddress, amountCollateral);
    }

    /**
     * @param tokenAddress : address of the token
     * @param amountCollateral : amount as colleteral
     */
    function redeemCollateral(address tokenAddress, uint256 amountCollateral)
        public
        moreThanZero(amountCollateral)
        nonReentrant
    {
        _redeemCollateral(tokenAddress, amountCollateral, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /**
     * @param amount : amount in collateral
     * @notice : This function is only for burning
     */
    function burnDsc(uint256 amount) public moreThanZero(amount) {
        _burnDsc(amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender); // This is most probably won't be hitting
    }

    /**
     * @notice : Illustration for liquidation
     * user deposited $100 worth token(ETH) as collateral and mints $50 DSC
     * IF the collateral value falls i.e under collateralized
     * Another user(liquidator) can clear the debt of the user and claim his collateral
     * Additionally the liquidator gets a bonus of 10%
     * @param collateral : The token address of the collateral i.e ETH
     * @param user : user to be liquidated
     * @param debtToCover : debt to be covered by liquidator
     * @notice LIQUIDATION BONUS = 10%
     */
    function liquidate(address collateral, address user, uint256 debtToCover)
        external
        moreThanZero(debtToCover)
        nonReentrant
    {
        uint256 startingUserHealthFactor = _healthFactor(user);
        // if not under collateralized
        if (startingUserHealthFactor > MIN_HEALTH_FACTOR) {
            revert DSCEngine__HealthFactorIsOk();
        }
        // now liquidation begins
        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(collateral, debtToCover);
        // 10% bonus for liquidator
        uint256 bonusCollateral = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;
        // total amount
        uint256 totalCollateralRedeemed = tokenAmountFromDebtCovered + bonusCollateral;
        // redeem + burn
        _redeemCollateral(collateral, totalCollateralRedeemed, user, msg.sender);
        _burnDsc(debtToCover, user, msg.sender);
        // checking if any improve in user health factor
        uint256 endinguserHealthFactor = _healthFactor(user);
        if (endinguserHealthFactor <= startingUserHealthFactor) {
            revert DSCEngine__HealthFactorNotImproved();
        }
        // check if the liquidator health factor is not broken i.e under collateral
        _revertIfHealthFactorIsBroken(msg.sender);
    }
    /**
     *
     * @param token : Address of the token i.e collateral
     * @param usdAmountInWEI : amount in WEI
     * @notice User pricefeed from Aggregator
     */

    function getTokenAmountFromUsd(address token, uint256 usdAmountInWEI) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();
        return ((usdAmountInWEI * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION));
    }

    // -----------------------INTERNAL FUNCTIONS----------//

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 userHealthFactor = _healthFactor(user);
        if (userHealthFactor < MIN_HEALTH_FACTOR) {
            revert DSCEngine__BreaksHealthFactor(userHealthFactor);
        }
    }

    /**
     * @notice : Threshold as healthfactor
     * @notice : <1 => user collateral can be liquified
     * @notice : Requirements for calculation of health factor
     * 1. Total DSC minted
     * 2. Total collateral value
     * @notice : Math explanation
     * Suppose user deposits $1000 worth of ETH as collateral
     * Mints $400 worth DSC
     * =>collateralValueInUsd = 1000;
     * =>totalDscMinted = 400;
     * uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
     * => collateralAdjustedForThreshold = 1000*50/100 = 500
     * return value = (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
     * => returns 500*1e18/400 = 1.25e18
     * => healthFactor>MIN_HEALTH_FACTOR
     * => no revert
     */
    function _healthFactor(address user) private view returns (uint256) {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }

    function _calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd)
        internal
        pure
        returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

    function _getAccountInformation(address user)
        internal
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    function _redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral, address from, address to)
        private
    {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        emit CollateralRedeemed(from, to, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function _burnDsc(uint256 amountDscToBurn, address onBehalfOf, address dscFrom) private {
        s_DSCMinted[onBehalfOf] -= amountDscToBurn;
        bool success = i_dsc.transferFrom(dscFrom, address(this), amountDscToBurn);
        if (!success) {
            // hypothetical case handling
            revert DSCEngine__TransferFailed();
        }
        i_dsc.burn(amountDscToBurn);
    }

    /**
     * @param user : address of user
     * @notice : used Aggregator for price feeds and for total value of collateral
     * @notice : The function `getAccountCollateralValue` returns the collateral value of a user (which contains all the tokens)
     */
    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.latestRoundData();

        return (((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION);
    }

    function calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd)
        external
        pure
        returns (uint256)
    {
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
    }

    // getters
    function getAccountInformation(address user)
        external
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        return _getAccountInformation(user);
    }

    function getAdditionalFeedPrecision() external pure returns (uint256) {
        return ADDITIONAL_FEED_PRECISION;
    }

    function getPrecision() external pure returns (uint256) {
        return PRECISION;
    }

    function getCollateralBalanceOfUser(address user, address token) external view returns (uint256) {
        return s_collateralDeposited[user][token];
    }

    function getHealthFactor(address user) external view returns (uint256) {
        return _healthFactor(user);
    }

    function getLiquidationBonus() external pure returns (uint256) {
        return LIQUIDATION_BONUS;
    }

    function getLiquidationPrecision() external pure returns (uint256) {
        return LIQUIDATION_PRECISION;
    }

    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_priceFeeds[token];
    }

    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }

    function getMinHealthFactor() external pure returns (uint256) {
        return MIN_HEALTH_FACTOR;
    }

    function getLiquidationThreshold() external pure returns (uint256) {
        return LIQUIDATION_THRESHOLD;
    }

    function getDsc() external view returns (address) {
        return address(i_dsc);
    }

    // --------------------------ERRORS------------------//

    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NoTokensExist();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine__MintFailed();
    error DSCEngine__HealthFactorIsOk();
    error DSCEngine__HealthFactorNotImproved();
}
