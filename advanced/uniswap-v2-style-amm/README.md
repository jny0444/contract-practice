<!-- filepath: /Users/jnyandeepsingh/Programming/Github/contract-practice/advanced/uniswap-v2-style-amm/README.md -->

## Uniswap V2 Style AMM Contracts

This document outlines the core contracts and functions to be implemented in a simplified Uniswap V2 style Automated Market Maker (AMM). The system primarily consists of a Factory contract, multiple Pair contracts (one for each unique token pair), and an optional Router contract to facilitate user interactions.

### 1. Factory Contract

The Factory contract is responsible for creating and managing Pair contracts.

**Functions:**

- **`createPair(address tokenA, address tokenB)`**
  - Creates a new Pair contract for the given `tokenA` and `tokenB` if one doesn't already exist.
  - `tokenA`, `tokenB`: Addresses of the two ERC20 tokens. The order usually doesn't matter as they are sorted internally.
  - Returns `(address pair)`: The address of the newly created or existing Pair contract.
- **`getPair(address tokenA, address tokenB)`**
  - Retrieves the address of the Pair contract for `tokenA` and `tokenB`.
  - Returns `(address pair)`: The address of the Pair contract, or the zero address if it doesn't exist.
- **`allPairs(uint index)`**
  - Returns the address of the Pair contract at a given `index` in the list of all created pairs.
- **`allPairsLength()`**
  - Returns the total number of Pair contracts created.
- **`feeTo()`**
  - (Optional) Address to which protocol fees are sent.
- **`feeToSetter()`**
  - (Optional) Address that can set the `feeTo` address.
- **`setFeeTo(address)`**
  - (Optional) Sets the `feeTo` address.
- **`setFeeToSetter(address)`**
  - (Optional) Sets the `feeToSetter` address.

**Events:**

- **`PairCreated(address indexed token0, address indexed token1, address pair, uint allPairsLength)`**
  - Emitted when a new pair is created.

### 2. Pair Contract (Liquidity Pool)

Each Pair contract manages a liquidity pool for a specific pair of ERC20 tokens and implements the core AMM logic. It also acts as an ERC20 token itself, representing liquidity provider (LP) shares.

**Core Logic (Internal):**

- Constant product formula: `k = reserveA * reserveB`.
- Manages reserves of `tokenA` and `tokenB`.
- Mints and burns LP tokens.
- (Optional) Collects a small percentage of swap volume as a protocol fee, which can be claimed by the `feeTo` address.

**Functions (typically called by a Router contract):**

- **`mint(address to)` (Internal function called during `addLiquidity`)**
  - Mints LP tokens to the `to` address after liquidity is deposited.
  - Returns `(uint liquidity)`: The amount of LP tokens minted.
- **`burn(address to)` (Internal function called during `removeLiquidity`)**
  - Burns LP tokens from the caller and sends back the underlying `tokenA` and `tokenB` to the `to` address.
  - Returns `(uint amount0, uint amount1)`: The amounts of `tokenA` and `tokenB` returned.
- **`swap(uint amount0Out, uint amount1Out, address to, bytes calldata data)`**
  - Performs a swap. Called by users (usually through a router).
  - `amount0Out`, `amount1Out`: The amounts of `token0` or `token1` to send out. One of these must be zero.
  - `to`: The address to receive the output tokens.
  - `data`: Optional data, can be used for flash loans (e.g., to call a function on the receiver contract).
- **`skim(address to)`**
  - Removes any excess tokens in the contract (tokens sent directly without using `mint` or `swap`) and sends them to the `to` address.
- **`sync()`**
  - Updates the contract's reserve balances to match the actual token balances. Useful if tokens are sent to the pair contract directly.
- **`getReserves()`**
  - Returns the current reserves of `token0` and `token1` in their liquidity pool, and the `blockTimestampLast` (timestamp of the last block in which an interaction occurred).
  - Returns `(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)`.
- **`price0CumulativeLast()` / `price1CumulativeLast()`**
  - Used for oracle price feeds. Stores the cumulative price of token0 and token1 respectively.
- **`kLast()`**
  - (Optional) Stores the `k` value (reserve0 \* reserve1) from the last interaction, used for fee calculation.

**ERC20 Functions (for LP tokens):**

- `name()`, `symbol()`, `decimals()`, `totalSupply()`, `balanceOf(address owner)`, `allowance(address owner, address spender)`
- `approve(address spender, uint value)`, `transfer(address to, uint value)`, `transferFrom(address from, address to, uint value)`

**Events:**

- **`Mint(address indexed sender, uint amount0, uint amount1)`**
  - Emitted when liquidity is added and LP tokens are minted.
- **`Burn(address indexed sender, uint amount0, uint amount1, address indexed to)`**
  - Emitted when liquidity is removed and LP tokens are burned.
- **`Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to)`**
  - Emitted on each swap.
- **`Sync(uint reserve0, uint reserve1)`**
  - Emitted after reserves are updated.
- **`Approval(address indexed owner, address indexed spender, uint value)`** (Standard ERC20)
- **`Transfer(address indexed from, address indexed to, uint value)`** (Standard ERC20)

### 3. Router Contract (Optional but Recommended)

The Router contract provides a user-friendly interface for interacting with Pair contracts. It handles complexities like calculating amounts, managing token approvals, and routing swaps through multiple pairs if necessary.

**Functions:**

1.  **`addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline)`**

    - Adds liquidity to a token pair's pool.
    - `tokenA`, `tokenB`: Addresses of the two ERC20 tokens.
    - `amountADesired`, `amountBDesired`: The amounts of tokenA and tokenB the liquidity provider wishes to deposit.
    - `amountAMin`, `amountBMin`: The minimum amounts of tokenA and tokenB that must be deposited.
    - `to`: The address that will receive the LP tokens.
    - `deadline`: A timestamp after which the transaction will revert.
    - Returns `(uint amountA, uint amountB, uint liquidity)`: Actual amounts deposited and LP tokens minted.

2.  **`addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline)`**

    - Adds liquidity for a token-ETH pair. `msg.value` is used for the ETH amount.
    - Returns `(uint amountToken, uint amountETH, uint liquidity)`.

3.  **`removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline)`**

    - Removes liquidity from a token pair's pool.
    - Returns `(uint amountA, uint amountB)`: Amounts of tokenA and tokenB withdrawn.

4.  **`removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline)`**

    - Removes liquidity for a token-ETH pair.
    - Returns `(uint amountToken, uint amountETH)`.

5.  **`swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)`**

    - Swaps an exact amount of input tokens for as many output tokens as possible.
    - `path`: Array of token addresses for the swap route (e.g., `[tokenIn, intermediateToken, tokenOut]`).

6.  **`swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)`**

    - Swaps as few input tokens as possible for an exact amount of output tokens.

7.  **`swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)`**

    - Swaps exact ETH for tokens. `msg.value` is the ETH amount.

8.  **`swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)`**

    - Swaps tokens for exact ETH.

9.  **`swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)`**

    - Swaps exact tokens for ETH.

10. **`swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)`**
    - Swaps ETH for exact tokens. `msg.value` is the max ETH to spend.

**Helper/View Functions (often part of the Router or a separate Library):**

- **`quote(uint amountA, uint reserveA, uint reserveB)`**
  - Given an amount of `tokenA` and pool reserves, returns the equivalent amount of `tokenB`.
- **`getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)`**
  - Calculates output amount for a given input amount and reserves (includes fees).
- **`getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)`**
  - Calculates input amount for a given output amount and reserves (includes fees).
- **`getAmountsOut(uint amountIn, address[] calldata path)`**
  - Given an input amount and a swap path, returns an array of output amounts for each step.
- **`getAmountsIn(uint amountOut, address[] calldata path)`**
  - Given an output amount and a swap path, returns an array of required input amounts for each step.

This structure provides a robust and flexible AMM. The separation of concerns (Factory for creation, Pair for core logic, Router for user interaction) is a key design pattern in Uniswap V2.
