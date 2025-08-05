// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
        external
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

    function depositCollateralAndMintDsc() external {}

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

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

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

    // --------------------------ERRORS------------------//
    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine__MintFailed();
}
