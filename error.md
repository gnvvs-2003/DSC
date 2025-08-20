Compiling 1 files with Solc 0.8.28
Solc 0.8.28 finished in 1.31s
Compiler run successful with warnings:
Warning (2519): This declaration shadows an existing declaration.
   --> test/unit/DSCEngine.t.sol:296:9:
    |
296 |         DSCEngine engine = new DSCEngine(tokenAddress, priceFeedAddress, address(mockDsc));
    |         ^^^^^^^^^^^^^^^^
Note: The shadowed declaration is here:
  --> test/unit/DSCEngine.t.sol:29:5:
   |
29 |     DSCEngine engine;
   |     ^^^^^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> test/mocks/MockERC20FailTransfer.sol:19:27:
   |
19 |     function transferFrom(address from, address to, uint256 amount) public pure override returns (bool) {
   |                           ^^^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> test/mocks/MockERC20FailTransfer.sol:19:41:
   |
19 |     function transferFrom(address from, address to, uint256 amount) public pure override returns (bool) {
   |                                         ^^^^^^^^^^

Warning (5667): Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> test/mocks/MockERC20FailTransfer.sol:19:53:
   |
19 |     function transferFrom(address from, address to, uint256 amount) public pure override returns (bool) {
   |                                                     ^^^^^^^^^^^^^^


Ran 1 test for test/unit/DSCEngine.t.sol:DSCEngineTest
[FAIL: ERC20InsufficientAllowance(0x50EEf481cae4250d252Ae577A09bF514f224C6C4, 0, 10000000000000000000 [1e19])] test__revertIfTransferFails() (gas: 2605048)
Traces:
  [16943817] DSCEngineTest::setUp()
    ├─ [8215601] → new DeployDSC@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    │   └─ ← [Return] 40911 bytes of code
    ├─ [8396546] DeployDSC::run()
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
    │   ├─ [1339387] → new DSCEngine@0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
    │   │   └─ ← [Return] 6007 bytes of code
    │   ├─ [2819] DecentralizedStableCoin::transferOwnership(DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512])
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, newOwner: DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512])
    │   │   └─ ← [Stop]
    │   ├─ [0] VM::stopBroadcast()
    │   │   └─ ← [Return]
    │   └─ ← [Return] DecentralizedStableCoin: [0x5FbDB2315678afecb367f032d93F642f64180aa3], DSCEngine: [0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512], HelperConfig: [0x104fBc016F4bb334D775a19E8A6510109AC63E00]
    ├─ [1636] HelperConfig::activeNetworkConfig() [staticcall]
    │   └─ ← [Return] MockV3Aggregator: [0x34A1D3fff3958843C43aD80F30b94c510645C316], MockV3Aggregator: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496], ERC20Mock: [0x90193C961A926261B756D1E5bb255e67ff9498A1], ERC20Mock: [0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3], 77814517325470205911140941194401928579557062014761831930645393041380819009408 [7.781e76]
    ├─ [67894] MockV3Aggregator::updateAnswer(200000000000 [2e11])
    │   └─ ← [Stop]
    ├─ [25414] ERC20Mock::mint(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], value: 10000000000000000000 [1e19])
    │   └─ ← [Stop]
    └─ ← [Stop]

  [2605048] DSCEngineTest::test__revertIfTransferFails()
    ├─ [0] VM::prank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    │   └─ ← [Return]
    ├─ [1032876] → new MockFailedTransfer@0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    │   ├─  storage changes:
    │   │   @ 5: 0 → 0x0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38
    │   │   @ 3: 0 → 0x446563656e7472616c697a6564537461626c65436f696e00000000000000002e
    │   │   @ 4: 0 → 0x4453430000000000000000000000000000000000000000000000000000000006
    │   └─ ← [Return] 4812 bytes of code
    ├─ [0] VM::prank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    │   └─ ← [Return]
    ├─ [1293903] → new DSCEngine@0x50EEf481cae4250d252Ae577A09bF514f224C6C4
    │   ├─  storage changes:
    │   │   @ 4: 0 → 1
    │   │   @ 0x55fed9a4091b778ae36f21bc5f72194aabef607cee67d0a2aa3b5b31316423b4: 0 → 0x00000000000000000000000034a1d3fff3958843c43ad80f30b94c510645c316
    │   │   @ 0: 0 → 1
    │   │   @ 0x8a35acfbc15ff81a39ae7d344fd709f28e8600b4aa8c65c6b64bfe7fe36bd19b: 0 → 0x000000000000000000000000db8cff278adccf9e9b5da745b44e754fc4ee3c76
    │   └─ ← [Return] 6007 bytes of code
    ├─ [47358] MockFailedTransfer::mint(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], value: 10000000000000000000 [1e19])
    │   ├─  storage changes:
    │   │   @ 2: 0 → 0x0000000000000000000000000000000000000000000000008ac7230489e80000
    │   │   @ 0xb4260ebeada881f749f68942b3f0e36ae8ba2751d11fbbad46a58feb7b4cda51: 0 → 0x0000000000000000000000000000000000000000000000008ac7230489e80000
    │   └─ ← [Stop]
    ├─ [0] VM::prank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    │   └─ ← [Return]
    ├─ [2819] MockFailedTransfer::transferOwnership(DSCEngine: [0x50EEf481cae4250d252Ae577A09bF514f224C6C4])
    │   ├─ emit OwnershipTransferred(previousOwner: DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38], newOwner: DSCEngine: [0x50EEf481cae4250d252Ae577A09bF514f224C6C4])
    │   ├─  storage changes:
    │   │   @ 5: 0x0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38 → 0x00000000000000000000000050eef481cae4250d252ae577a09bf514f224c6c4
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    │   └─ ← [Return]
    ├─ [25319] MockFailedTransfer::approve(MockFailedTransfer: [0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76], 10000000000000000000 [1e19])
    │   ├─ emit Approval(owner: user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], spender: MockFailedTransfer: [0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76], value: 10000000000000000000 [1e19])
    │   ├─  storage changes:
    │   │   @ 0x6aa4659e4cd7936d32e4db1ca0ad90be131813ac9950643149e56a81c00d5a11: 0 → 0x0000000000000000000000000000000000000000000000008ac7230489e80000
    │   └─ ← [Return] true
    ├─ [30002] DSCEngine::depositCollateral(MockFailedTransfer: [0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76], 10000000000000000000 [1e19])
    │   ├─ emit CollateralDeposited(user: user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], token: MockFailedTransfer: [0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76], amount: 10000000000000000000 [1e19])
    │   ├─ [3743] MockFailedTransfer::transferFrom(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], DSCEngine: [0x50EEf481cae4250d252Ae577A09bF514f224C6C4], 10000000000000000000 [1e19])
    │   │   └─ ← [Revert] ERC20InsufficientAllowance(0x50EEf481cae4250d252Ae577A09bF514f224C6C4, 0, 10000000000000000000 [1e19])
    │   ├─  storage changes:
    │   │   @ 0x06d215a921a46544af4a561668458a5df2f0129c9792ce098f83037fdc4a4046: 0 → 0x0000000000000000000000000000000000000000000000008ac7230489e80000
    │   │   @ 0: 1 → 2
    │   └─ ← [Revert] ERC20InsufficientAllowance(0x50EEf481cae4250d252Ae577A09bF514f224C6C4, 0, 10000000000000000000 [1e19])
    ├─  storage changes:
    │   @ 0x6aa4659e4cd7936d32e4db1ca0ad90be131813ac9950643149e56a81c00d5a11: 0 → 0x0000000000000000000000000000000000000000000000008ac7230489e80000
    │   @ 0x4a2cc91ee622da3bc833a54c37ffcb6f3ec23b7793efc5eaf5e71b7b406c5c06: 0 → 0x000000000000000000000000db8cff278adccf9e9b5da745b44e754fc4ee3c76
    │   @ 45: 0 → 1
    │   @ 46: 0 → 1
    │   @ 0x37fa166cbdbfbb1561ccd9ea985ec0218b5e68502e230525f544285b2bdf3d7e: 0 → 0x00000000000000000000000034a1d3fff3958843c43ad80f30b94c510645c316
    │   @ 5: 0x0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38 → 0x00000000000000000000000050eef481cae4250d252ae577a09bf514f224c6c4
    └─ ← [Revert] ERC20InsufficientAllowance(0x50EEf481cae4250d252Ae577A09bF514f224C6C4, 0, 10000000000000000000 [1e19])

Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 15.24ms (9.64ms CPU time)

Ran 1 test suite in 22.79ms (15.24ms CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

Failing tests:
Encountered 1 failing test in test/unit/DSCEngine.t.sol:DSCEngineTest
[FAIL: ERC20InsufficientAllowance(0x50EEf481cae4250d252Ae577A09bF514f224C6C4, 0, 10000000000000000000 [1e19])] test__revertIfTransferFails() (gas: 2605048)

Encountered a total of 1 failing tests, 0 tests succeeded
