# DSC Engine functionality

1. Deposit Collatoral : Consider this as user property that user submits as a collatoral for our token i.e stable coin (DSC)

2. Redeem their collatoral : Users can also claim their collatoral by providing our DSC tokens at the current price market only

3. Burn : If the user collatoral value suddenly falls (Eg : IF FALLS FROM 134USD TO 97USD) users will need to quickly rectify the collaterization of their taken DSC tokens

4. Liquidation : Protocal rule for liquidations is when the user collatoral value is fallen below our **Threshold** the collatoral of the user can be liquidated by any other user

Threshold explanation

If the threshold to liquidate is 150% collateralization, an account with $75 in ETH can support $50 in DSC. If the value of ETH falls to $74, the healthFactor is broken and the account can be liquidated

>Complete Explanation :

Users will deposit collateral greater in value than the DSC they mint. If their collateral value falls such that their position becomes under-collateralized, another user can liquidate the position, by paying back/burning the DSC in exchange for the positions collateral. This will net the liquidator the difference in the DSC value and the collateral value in profit as incentive for securing the protocol.

>Minting examples

| Collateral | Debt  | Health Factor | Status       |
| ---------- | ----- | ------------- | -----------  |
| $1000      | $400  | 1.25          | ✅ Safe      |
| $1000      | $500  | 1.0           | ✅ Just Safe |
| $1000      | $600  | 0.83          | ❌ Unsafe    |
