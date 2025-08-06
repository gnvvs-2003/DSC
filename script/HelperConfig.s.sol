// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";

/**
 * @title Helper config contract
 * @author gnvvs-2003
 * @notice This contract returns the config details for different network
 * @notice Chosen network is anvil for local dev and sepolia for testnet
 */
contract HelperConfig is Script {
    // ------------structs-------------------//
    struct NetworkConfig {
        address wethUsdPriceFeed;
        address wbtcUsdPriceFeed;
        address weth;
        address wbtc;
        uint256 deployerKey; // private key
    }

    NetworkConfig public activeNetworkConfig;

    uint256 private LOCAL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 2000e8;
    int256 public constant BTC_USD_PRICE = 1000e8;

    /**
     * @notice This constructor function is setting the chain
     */
    constructor() {
        if (block.chainid == 11155111) {
            // sepolia chain
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            // local chain
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    /**
     * @notice network configurations
     */

    // sepolia network
    function getSepoliaEthConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcUsdPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY")
        });
    }

    // local network : anvil

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        /**
         * @notice Creates the local anvil chain if it does not exist
         */

        // Check to see if we set an active network config
        if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // broadcasting within the Helper config with local chain
        /**
         * @notice The parameters of the MockV3Aggregator are (uint8 _decimals, int256 _initialAnswer)
         */
        vm.startBroadcast();
        // Mocking for eth
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_PRICE);
        // using ERC20Mock protocol
        ERC20Mock wethMock = new ERC20Mock("WETH", "WETH", msg.sender, 1000e8);

        // Mocking for btc
        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(DECIMALS, BTC_USD_PRICE);
        // using ERC20Mock protocol
        ERC20Mock wbtcMock = new ERC20Mock("WBTC", "WBTC", msg.sender, 2000e8);

        vm.stopBroadcast();
        anvilNetworkConfig = NetworkConfig({
            wethUsdPriceFeed: address(ethUsdPriceFeed),
            wbtcUsdPriceFeed: address(btcUsdPriceFeed),
            weth: address(wethMock),
            wbtc: address(wbtcMock),
            deployerKey: LOCAL_PRIVATE_KEY
        });
    }
}
