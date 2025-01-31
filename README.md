# Stacking Rewards Collateral System

A decentralized lending platform that enables STX holders to use their stacking rewards as collateral for loans.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contract Functions](#contract-functions)
- [Security](#security)
- [Testing](#testing)
- [Deployment](#deployment)

## Overview

This smart contract enables users to:
- Register their STX stacking positions
- Use future stacking rewards as loan collateral
- Receive loans based on projected rewards
- Automatically repay loans from stacking rewards

## Features

### Stacking Integration
- Register stacking positions
- Track reward cycles
- Calculate projected rewards
- Monitor unlock periods

### Loan System
- Collateral-backed loans
- Dynamic interest rates
- Automatic repayments
- Default protection

### Security Features
- Minimum collateralization ratio
- Cycle validation
- Reward verification
- Access controls

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/stacking-collateral

# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.0.0/clarinet-linux-x64-glibc.tar.gz | tar xz

# Initialize project
cd stacking-collateral
clarinet new .
```

## Usage

### Register Stacking Position
```clarity
(contract-call? .stacking-collateral register-stacking u1000000000 u6)
```

### Request Loan
```clarity
(contract-call? .stacking-collateral request-loan u500000000 u5)
```

### Process Repayment
```clarity
(contract-call? .stacking-collateral repay-from-rewards u1 u12)
```

## Contract Functions

### Core Functions
- `register-stacking`: Register STX stacking position
- `request-loan`: Request a loan against stacking rewards
- `repay-from-rewards`: Process reward-based repayments
- `fund-loan`: Fund an open loan request

### Administrative Functions
- `set-collateral-ratio`: Update minimum collateral ratio
- `set-min-cycles`: Set minimum stacking cycles

### Read-Only Functions
- `get-stacking-info`: Get stacker information
- `get-loan`: Get loan details
- `get-cycle-info`: Get reward cycle information

## Security

### Safeguards
1. Minimum stacking requirements
2. Collateral ratio enforcement
3. Cycle validation
4. Access control checks

### Best Practices
- Verify all transactions
- Monitor collateral ratios
- Track reward cycles
- Handle errors appropriately

## Testing

```bash
# Run all tests
clarinet test

# Test specific function
clarinet test tests/stacking-collateral_test.ts

# Check contract
clarinet check
```

## Deployment

### Testnet
```bash
# Deploy contract
clarinet deploy --testnet

# Verify deployment
stx call get-stacking-info ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
```

### Mainnet
```bash
# Deploy contract
clarinet deploy --mainnet

# Initialize parameters
stx contract_call set-collateral-ratio u150
```