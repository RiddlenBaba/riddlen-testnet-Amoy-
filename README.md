# Riddlen Protocol Smart Contracts

[![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)](./VERSION)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](#testing)

Smart contracts powering the Riddlen ecosystem - a human intelligence validation network with weekly NFT riddles, progressive burn mechanics, and reputation systems.

## 🎯 Overview

Riddlen is a Web3 protocol implementing **Proof-of-Solve** consensus through NFT-based weekly riddles. Players mint NFTs to attempt riddles, with progressive burn costs and substantial RDLN prize pools, while earning RON reputation tokens for successful solving.

### ✨ Key Features (v0.3.0)

- 🧩 **Weekly Riddle System**: 1000 riddles over 20 years starting January 1, 2025
- 🔥 **Progressive Burn Protocol**: Failed attempts cost 1, 2, 3... N RDLN per NFT
- 💰 **Massive Prize Pools**: 700M RDLN allocated across randomized prize distributions
- 🏆 **RON Reputation System**: Soul-bound tokens for intelligence validation
- 🔄 **NFT Resale Market**: Tradeable riddle NFTs with commission structure
- ⏰ **Biennial Halving**: Mint costs halve every 2 years
- 🎲 **Randomized Parameters**: Each riddle has unique mint rates, prizes, and winner slots

## 📋 Contract Architecture

### Core System Contracts

| Contract | Description | Status | Tests |
|----------|-------------|--------|-------|
| **RDLN.sol** | ERC20 token with burn mechanics | ✅ Complete | 20 passing |
| **RON.sol** | Soul-bound reputation system | ✅ Complete | 26 passing |
| **RiddleNFT_v2.sol** | Weekly riddle NFT system | ✅ Complete | 13 passing |

### Token Contracts (`/contracts/token/`)
- **RDLN**: Main utility token (1B supply, progressive burns, allocations)
- **RON**: Reputation token (soul-bound, tier-based, oracle validation)

### NFT Contracts (`/contracts/nft/`)
- **RiddleNFT_v2**: Weekly riddle system with resale mechanics
- **RiddleNFT_v1**: Legacy attempt-based system (deprecated)

### Interfaces (`/contracts/interfaces/`)
- **IRDLN**: Token interface with game mechanics
- **IRON**: Reputation system interface
- **IRiddleNFT_v2**: Weekly riddle system interface

### Governance (`/contracts/governance/`)
- **TreasuryDrip**: Automated treasury distribution system

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Git

### Installation & Setup

```bash
# Clone the repository
git clone https://github.com/riddlen/riddlen-contracts.git
cd riddlen-contracts

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run all tests
npm test

# Check test coverage
npm run coverage
```

### 🧪 Testing

The project includes comprehensive test suites for all major components:

```bash
# Run specific contract tests
npx hardhat test test/RDLN.test.js        # Token tests (20 passing)
npx hardhat test test/RON.test.js         # Reputation tests (26 passing)
npx hardhat test test/RiddleNFT_v2.test.js # NFT system tests (13 passing)

# Run with gas reporting
REPORT_GAS=true npm test

# Generate coverage report
npm run coverage
```

### 🏗️ Deployment

```bash
# Individual contract deployment
npx hardhat run scripts/deploy-rdln.js --network sepolia      # RDLN token
npx hardhat run scripts/deploy-ron.js --network sepolia       # RON reputation
npx hardhat run scripts/deploy-riddlenfts.js --network sepolia # RiddleNFT system

# Deploy to testnets
npm run deploy:sepolia    # Sepolia testnet
npm run deploy:mumbai     # Polygon Mumbai testnet

# Deploy to mainnets (requires env setup)
npm run deploy:polygon    # Polygon mainnet
```

#### Environment Setup
Create a `.env` file with your configuration:

```bash
# Network RPC URLs
SEPOLIA_URL=https://sepolia.infura.io/v3/YOUR_KEY
POLYGON_URL=https://polygon-mainnet.infura.io/v3/YOUR_KEY
MUMBAI_URL=https://polygon-mumbai.infura.io/v3/YOUR_KEY

# Deployment account
PRIVATE_KEY=your_deployer_private_key

# Contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key

# Wallet addresses for deployment
ADMIN_WALLET=0x...
LIQUIDITY_WALLET=0x...
DEVOPS_WALLET=0x...
```

## Security

- All contracts undergo comprehensive testing
- External audits planned before mainnet deployment
- Formal verification for critical components
- Bug bounty program (details TBA)

## Documentation

- [Tokenomics](docs/tokenomics.md)
- [NFT Mechanics](docs/nft-mechanics.md)
- [Burning Protocol](docs/burning-protocol.md)
- [API Reference](docs/api.md)

## Deployment

### Testnets
- **Sepolia**: Coming soon
- **Polygon Mumbai**: Coming soon

### Mainnet
- **Ethereum**: Planned
- **Polygon**: Planned

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

[MIT License](LICENSE)

## Security Contact

For security issues, please email: security@riddlen.com

## Community

- [Discord](https://discord.gg/riddlen)
- [Twitter](https://twitter.com/riddlen)
- [Website](https://riddlen.com)