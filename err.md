No files changed, compilation skipped

Ran 1 test for test/fuzz/InvariantsTest.t.sol:InvariantTest
[FAIL: invariant_protocolMustHaveMoreValueThanTotalSupply persisted failure revert]
	[Sequence] (original: 2, shrunk: 2)
		sender=0x000000000000000000000000000000000000243D addr=[test/fuzz/Handler.t.sol:Handler]0x2e234DAe75C793f67A35089C9d99245E1C58470b calldata=depositCollateral(uint256,uint256) args=[93121988801840253997600415558047606859433917953 [9.312e46], 3535]
		sender=0x0000000000000000000000000000000000000DCF addr=[test/fuzz/Handler.t.sol:Handler]0x2e234DAe75C793f67A35089C9d99245E1C58470b calldata=mintDsc(uint256,uint256) args=[88779466845831582029850776906554408512795919221911695020139214281547 [8.877e67], 32924833245174545386409800458324606498365 [3.292e40]]
 invariant_protocolMustHaveMoreValueThanTotalSupply() (runs: 1, calls: 1, reverts: 1)
Logs:
  Bound result 3535
  Bound result 1404191
  Total supply =  0
  weth value =  0
  wbtc value =  3535000
  No of times mint called  =  0

Traces:
  [19392443] InvariantTest::setUp()
    ├─ [8445799] → new DeployDSC@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← [Return] 42060 bytes of code
    ├─ [8625381] DeployDSC::run()
    │   ├─ [5728223] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    │   │   ├─ [0] VM::startBroadcast()
    │   │   │   └─ ← [Return]
    │   │   ├─ [578290] → new MockV3Aggregator@0x34A1D3fff3958843C43aD80F30b94c510645C316
    │   │   │   └─ ← [Return] 2109 bytes of code
    │   │   ├─ [902864] → new ERC20Mock@0x90193C961A926261B756D1E5bb255e67ff9498A1
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DeployDSC: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], value: 100000000000 [1e11])
    │   │   │   └─ ← [Return] 4040 bytes of code
    │   │   ├─ [578290] → new MockV3Aggregator@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    │   │   │   └─ ← [Return] 2109 bytes of code
    │   │   ├─ [902864] → new ERC20Mock@0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3
    │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DeployDSC: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], value: 200000000000 [2e11])
    │   │   │   └─ ← [Return] 4040 bytes of code
    │   │   ├─ [0] VM::stopBroadcast()
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return] 12353 bytes of code
    │   ├─ [1636] HelperConfig::activeNetworkConfig() [staticcall]
    │   │   └─ ← [Return] MockV3Aggregator: [0x34A1D3fff3958843C43aD80F30b94c510645C316], MockV3Aggregator: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496], ERC20Mock: [0x90193C961A926261B756D1E5bb255e67ff9498A1], ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], 77814517325470205911140941194401928579557062014761831930645393041380819009408 [7.781e76]
    │   ├─ [0] VM::startBroadcast(<pk>)
    │   │   └─ ← [Return]
    │   ├─ [0] VM::addr(<pk>) [staticcall]
    │   │   └─ ← [Return] 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    │   ├─ [1076662] → new DecentralizedStableCoin@0x5FbDB2315678afecb367f032d93F642f64180aa3
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)
    │   │   └─ ← [Return] 5029 bytes of code
    │   ├─ [1568047] → new DSCEngine@0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    │   │   └─ ← [Return] 7149 bytes of code
    │   ├─ [2819] DecentralizedStableCoin::transferOwnership(DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512])
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, newOwner: DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512])
    │   │   └─ ← [Stop]
    │   ├─ [0] VM::stopBroadcast()
    │   │   └─ ← [Return]
    │   └─ ← [Return] DecentralizedStableCoin: [0x5FbDB2315678afecb367f032d93F642f64180aa3], DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], HelperConfig: [0x104fBc016F4bb334D775a19E8A6510109AC63E00]
    ├─ [2053147] → new Handler@0x2e234DAe75C793f67A35089C9d99245E1C58470b
    │   ├─ [2037] DSCEngine::getCollateralTokens() [staticcall]
    │   │   └─ ← [Return] [0x90193C961A926261B756D1E5bb255e67ff9498A1, 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3]
    │   └─ ← [Return] 9458 bytes of code
    ├─ [1636] HelperConfig::activeNetworkConfig() [staticcall]
    │   └─ ← [Return] MockV3Aggregator: [0x34A1D3fff3958843C43aD80F30b94c510645C316], MockV3Aggregator: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496], ERC20Mock: [0x90193C961A926261B756D1E5bb255e67ff9498A1], ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], 77814517325470205911140941194401928579557062014761831930645393041380819009408 [7.781e76]
    └─ ← [Stop]

  [181769] Handler::depositCollateral(93121988801840253997600415558047606859433917953 [9.312e46], 3535)
    ├─ [0] console::log("Bound result", 3535) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(0x000000000000000000000000000000000000243D)
    │   └─ ← [Return]
    ├─ [30214] ERC20Mock::mint(0x000000000000000000000000000000000000243D, 3535)
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x000000000000000000000000000000000000243D, value: 3535)
    │   └─ ← [Stop]
    ├─ [25296] ERC20Mock::approve(DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], 3535)
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000243D, spender: DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], value: 3535)
    │   └─ ← [Return] true
    ├─ [60395] DSCEngine::depositCollateral(ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], 3535)
    │   ├─ emit CollateralDeposited(user: 0x000000000000000000000000000000000000243D, token: ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], amount: 3535)
    │   ├─ [26836] ERC20Mock::transferFrom(0x000000000000000000000000000000000000243D, DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], 3535)
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000243D, to: DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], value: 3535)
    │   │   └─ ← [Return] true
    │   └─ ← [Stop]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    └─ ← [Stop]

  [107083] Handler::mintDsc(88779466845831582029850776906554408512795919221911695020139214281547 [8.877e67], 32924833245174545386409800458324606498365 [3.292e40])
    ├─ [48358] DSCEngine::getAccountInformation(0x000000000000000000000000000000000000243D) [staticcall]
    │   ├─ [9930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 200000000000 [2e11], 1, 1, 1
    │   ├─ [9930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 100000000000 [1e11], 1, 1, 1
    │   └─ ← [Return] 0, 3535000 [3.535e6]
    ├─ [0] console::log("Bound result", 1404191 [1.404e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(0x0000000000000000000000000000000000000DCF)
    │   └─ ← [Return]
    ├─ [38625] DSCEngine::mintDsc(1404191 [1.404e6])
    │   ├─ [1930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 200000000000 [2e11], 1, 1, 1
    │   ├─ [1930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 100000000000 [1e11], 1, 1, 1
    │   └─ ← [Revert] DSCEngine__BreaksHealthFactor(0)
    └─ ← [Revert] DSCEngine__BreaksHealthFactor(0)

  [80228] InvariantTest::invariant_protocolMustHaveMoreValueThanTotalSupply()
    ├─ [2500] DecentralizedStableCoin::totalSupply() [staticcall]
    │   └─ ← [Return] 0
    ├─ [2895] ERC20Mock::balanceOf(DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512]) [staticcall]
    │   └─ ← [Return] 0
    ├─ [2895] ERC20Mock::balanceOf(DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512]) [staticcall]
    │   └─ ← [Return] 3535
    ├─ [17489] DSCEngine::getUsdValue(ERC20Mock: [0x90193C961A926261B756D1E5bb255e67ff9498A1], 0) [staticcall]
    │   ├─ [9930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 200000000000 [2e11], 1, 1, 1
    │   └─ ← [Return] 0
    ├─ [17489] DSCEngine::getUsdValue(ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], 3535) [staticcall]
    │   ├─ [9930] MockV3Aggregator::latestRoundData() [staticcall]
    │   │   └─ ← [Return] 1, 100000000000 [1e11], 1, 1, 1
    │   └─ ← [Return] 3535000 [3.535e6]
    ├─ [0] console::log("Total supply = ", 0) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("weth value = ", 0) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("wbtc value = ", 3535000 [3.535e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [2470] Handler::timesMintIsCalled() [staticcall]
    │   └─ ← [Return] 0
    ├─ [0] console::log("No of times mint called  = ", 0) [staticcall]
    │   └─ ← [Stop]
    └─ ← [Stop]

Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 9.07ms (3.61ms CPU time)

Ran 1 test suite in 12.69ms (9.07ms CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

Failing tests:
Encountered 1 failing test in test/fuzz/InvariantsTest.t.sol:InvariantTest
[FAIL: invariant_protocolMustHaveMoreValueThanTotalSupply persisted failure revert]
	[Sequence] (original: 2, shrunk: 2)
		sender=0x000000000000000000000000000000000000243D addr=[test/fuzz/Handler.t.sol:Handler]0x2e234DAe75C793f67A35089C9d99245E1C58470b calldata=depositCollateral(uint256,uint256) args=[93121988801840253997600415558047606859433917953 [9.312e46], 3535]
		sender=0x0000000000000000000000000000000000000DCF addr=[test/fuzz/Handler.t.sol:Handler]0x2e234DAe75C793f67A35089C9d99245E1C58470b calldata=mintDsc(uint256,uint256) args=[88779466845831582029850776906554408512795919221911695020139214281547 [8.877e67], 32924833245174545386409800458324606498365 [3.292e40]]
 invariant_protocolMustHaveMoreValueThanTotalSupply() (runs: 1, calls: 1, reverts: 1)

Encountered a total of 1 failing tests, 0 tests succeeded
