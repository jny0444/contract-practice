# 🟢 Beginner Level

These will help you understand Solidity syntax, state variables, functions, and basic Ethereum concepts. (Skipping these contracts as they are too simple.)

## HelloWorld Contract

Just returns a "Hello, World!" string.

Practice deployment and interaction.

## Counter Contract

Increments/decrements a number.

Practice with state variables and functions.

## Simple Storage

Store and retrieve a string, number, and boolean.

## Basic Token (ERC20-lite)

Implement mint, transfer, and balanceOf manually.

No need to follow full ERC20 standard yet.

## Todo List

Add/remove/mark tasks.

Use arrays and structs.

## Voting System

Add candidates and let users vote.

Prevent double-voting.

# 🟡 Intermediate Level

These teach you modifiers, mappings, events, access control, inheritance, and more complex interactions.

## Time-Locked Wallet

Users can withdraw only after a certain time.

## Simple Auction

Bidders compete within a deadline, and winner claims prize.

## Crowdfunding / ICO

Users send ETH to support a project.

If target reached, creator can withdraw. Otherwise, users get refunded.

## Multi-Sig Wallet

Require 2-of-3 owners to approve before executing a transaction.

# 🟠 Advanced Level

Now dive into DeFi mechanics, gas optimization, security, and complex architectural patterns.

## Uniswap V2-style AMM

Create pairs, add liquidity, do swaps.

Learn about constant product formulas.

## Compound-style Lending Protocol

Users deposit collateral, borrow assets.

Liquidation, interest accrual.

## Staking Contract with Rewards

Users stake tokens and earn reward tokens over time.

## Yield Farming Vault

Auto-compounds yield into LP tokens and reinvests.

## DAO Voting System

Token-weighted voting on proposals.

Execution based on passed proposals.

## Upgradeable Contracts (via Proxy Pattern)

Use delegate calls and understand storage layout.

## ZK-based Proof-of-Action System

Integrate with a zkSNARK verifier.

Example: only allow action if user proves identity/ownership privately.

# 🟣 Expert/Research Level

If you're aiming for protocol design or audit-level mastery:

## Modular Algorithmic Stablecoin System

Includes: collateral vault, price oracle, minting logic, peg enforcement.

## MEV-resistant Auction System

Prevent frontrunning using commit-reveal schemes or batch auctions.

## Layer-2 Rollup Contract (Simple Optimistic Rollup)

Accepts batches of tx, verifies fraud proofs.

## Cross-chain Bridge

Sends tokens or messages across chains with attestation/verifier logic.

