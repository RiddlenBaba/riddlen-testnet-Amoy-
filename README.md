# Riddlen Protocol Smart Contracts

Smart contracts powering the Riddlen ecosystem - a gamified NFT platform with token burning mechanics and community rewards.

## Overview

Riddlen is a Web3 protocol that combines NFT riddles, token economics, and community engagement through innovative burning and reward mechanisms.

## Contracts

### Token Contracts (`/contracts/token/`)
- **RDLN Token**: Main utility token for the Riddlen ecosystem
- **Token Economics**: Burning mechanisms and reward distribution

### NFT Contracts (`/contracts/nft/`)
- **RiddleNFT**: Core NFT contract for riddle-based collectibles
- **RiddleFactory**: Factory contract for creating and managing riddles

### Game Contracts (`/contracts/game/`)
- **PrizePool**: Prize distribution and management system
- **BurnProtocol**: Token burning mechanics and rewards

### Governance (`/contracts/governance/`)
- **Treasury**: Community treasury management

## Development Setup

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to testnet
npx hardhat run scripts/deploy.js --network sepolia
```

## Testing

```bash
# Run all tests
npm run test

# Run with coverage
npm run coverage

# Run specific test file
npx hardhat test test/RDLN.test.js
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