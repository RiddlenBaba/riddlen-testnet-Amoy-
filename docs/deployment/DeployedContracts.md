# Deployed Contracts Documentation

## Current Production Contracts

### RDLN Token (Thirdweb ERC-20)
- **Network**: Polygon Mainnet
- **Address**: `0x683e52ec4a0dF61345172395b700208dd7ACcA53`
- **PolygonScan**: https://polygonscan.com/address/0x683e52ec4a0dF61345172395b700208dd7ACcA53
- **Deployment Platform**: Thirdweb
- **Contract Type**: ERC-20 with Thirdweb extensions

#### Current Features ✅
- ✅ ERC-20 standard compliance
- ✅ Burnable tokens (`ERC20BurnableUpgradeable`)
- ✅ Access control with roles (MINTER_ROLE, TRANSFER_ROLE)
- ✅ Meta-transaction support
- ✅ Signature-based minting
- ✅ Platform fee mechanisms
- ✅ Upgradeable contract architecture
- ✅ Voting/Governance features (`ERC20VotesUpgradeable`)

#### Missing Riddlen Features ❌
- ❌ Progressive burn mechanics for failed attempts
- ❌ Question submission burn costs
- ❌ NFT minting burn integration
- ❌ 1 billion token supply cap enforcement
- ❌ Allocation tracking (Prize Pool: 700M, Treasury: 100M, etc.)
- ❌ Deflationary transfer mechanisms
- ❌ Game contract integration
- ❌ RON reputation system integration

#### Key Contract Details
```solidity
// Roles
MINTER_ROLE = keccak256("MINTER_ROLE")
TRANSFER_ROLE = keccak256("TRANSFER_ROLE")

// Platform Fees
DEFAULT_FEE_RECIPIENT = 0x1Af20C6B23373350aD464700B5965CE4B0D2aD94
DEFAULT_FEE_BPS = 100 (1%)
MAX_BPS = 10,000

// Key Functions
- mintTo(address to, uint256 amount)
- mintWithSignature(MintRequest req, bytes signature)
- burn(uint256 amount) / burnFrom(address account, uint256 amount)
- setPrimarySaleRecipient(address recipient)
- setPlatformFeeInfo(address recipient, uint256 feeBps)
```

## Development Strategy

### Phase 1: New RDLN Contract
Create a new, clean RDLN contract specifically designed for Riddlen with:
1. All whitepaper tokenomics (1B supply, allocations)
2. Progressive burn mechanics
3. Game integration functions
4. Proper access controls for game contracts

### Phase 2: Migration Strategy
- Deploy new contract alongside existing one
- Create migration tools for existing holders
- Coordinate community migration
- Maintain both contracts during transition period

### Phase 3: Integration
- Connect new RDLN to RON reputation system
- Integrate with riddle NFT contracts
- Connect to prize pool management
- Enable full ecosystem functionality

## Next Steps
1. ✅ Document current state (this file)
2. 🔄 Design new RDLN contract with Riddlen features
3. ⏳ Create RON reputation system
4. ⏳ Build riddle NFT contract
5. ⏳ Develop prize pool management
6. ⏳ Create migration tools

---
**Last Updated**: September 27, 2025
**Status**: Phase 1 - Foundation Development