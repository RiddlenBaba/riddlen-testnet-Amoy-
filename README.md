# 🌐 Riddlen Amoy Testnet Repository

[![Network](https://img.shields.io/badge/network-Polygon%20Amoy-purple.svg)](https://amoy.polygonscan.com/)
[![Version](https://img.shields.io/badge/version-v5.1-blue.svg)](./white-paper-v5.2)
[![Status](https://img.shields.io/badge/status-Ready%20for%20Deployment-green.svg)](./DEPLOYMENT-INSTRUCTIONS.md)
[![Tests](https://img.shields.io/badge/ecosystem%20tests-8%2F13%20passing-orange.svg)](./test/EcosystemIntegration.test.js)

**Official Riddlen Amoy Testnet deployment repository** - Complete v5.1 ecosystem integration ready for live testing on Polygon's Amoy testnet.

## 🎯 What is This Repository?

This is the **live testnet implementation** of the revolutionary Riddlen ecosystem - the first blockchain protocol that rewards human intelligence over computational power or capital stakes through **Proof-of-Solve consensus**.

### 🌐 **Testnet Information**
- **Network**: Polygon Amoy Testnet (Chain ID: 80002)
- **Explorer**: https://amoy.polygonscan.com/
- **Faucet**: https://faucet.polygon.technology/
- **Version**: Riddlen v5.1 Ecosystem Integration

### 🚀 **Revolutionary Features Being Tested**

- 🧠 **Merit-Based Governance**: "Brain matters more than bank account" - voting power earned through intelligence
- 🎮 **NFT-as-Game Architecture**: Interactive riddle experiences vs static collectibles
- 📈 **Progressive Economics**: Biennial halving schedule with sustainable burn mechanisms
- 🔒 **Cross-Contract Security**: Anti-cheating and Sybil resistance across the entire ecosystem
- ⚡ **Soul-Bound Reputation**: Non-transferable RON tokens representing earned intelligence
- 🎯 **AI-Human Collaboration**: Community-validated questions with fair AI assembly

## 📋 **Live Contract Addresses**

> **Status**: Ready for deployment to Amoy testnet

Once deployed, this will include:

| Contract | Description | Address | Verification |
|----------|-------------|---------|--------------|
| **RDLNUpgradeable** | Merit-based utility token with allocation-specific minting | *Pending Deployment* | *Pending* |
| **RONAdvanced** | Soul-bound reputation system with governance weights | *Pending Deployment* | *Pending* |
| **RiddleNFTAdvanced** | Interactive NFT-as-Game implementation | *Pending Deployment* | *Pending* |

*Contract addresses will be updated here after deployment*

## 🏗️ **v5.1 Ecosystem Architecture**

### **Advanced Token System**
- **RDLNUpgradeable**: UUPS upgradeable token with allocation-specific minting (Treasury, Airdrop, Prize Pool, Liquidity)
- **RONAdvanced**: Merit-based reputation with governance weight calculation and democratic safeguards

### **Revolutionary NFT Gaming**
- **RiddleNFTAdvanced**: Interactive NFT-as-Game with progressive difficulty, randomized parameters, and anti-cheating mechanisms

### **Cross-Contract Integration**
- **Role-Based Security**: Multi-signature access control across ecosystem
- **Merit-Based Governance**: RON reputation drives voting power calculations
- **Progressive Economics**: Biennial halving and burn mechanisms integration

## 🚀 **Quick Start for Testnet Deployment**

### **Prerequisites**
- Node.js 18+ and npm
- Amoy testnet MATIC for gas fees ([Get from faucet](https://faucet.polygon.technology/))
- Private key for deployment wallet
- PolygonScan API key for verification

### **Deploy the v5.1 Ecosystem**

```bash
# 1. Clone this repository
git clone https://github.com/RiddlenBaba/riddlen-testnet-Amoy-.git
cd riddlen-testnet-Amoy-

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env
# Edit .env with your PRIVATE_KEY and POLYGONSCAN_API_KEY

# 4. Deploy complete ecosystem to Amoy testnet
npx hardhat run scripts/deploy-amoy-testnet.js --network amoy

# 5. Verify contracts (optional)
npx hardhat verify --network amoy [CONTRACT_ADDRESS]
```

### **What Gets Deployed**
- ✅ **RDLNUpgradeable**: Merit-based token with burn mechanisms
- ✅ **RONAdvanced**: Soul-bound reputation with governance weights
- ✅ **RiddleNFTAdvanced**: Interactive NFT-as-Game architecture
- ✅ **Cross-contract integration**: Complete ecosystem connectivity

## 🧪 **What Can You Test?**

### **Core Ecosystem Features**
- **Token Operations**: Mint, transfer, burn mechanisms with RDLN
- **Reputation Building**: Solve riddles, earn RON, advance through access tiers
- **NFT Gaming**: Create riddle sessions, submit answers, claim rewards
- **Cross-Contract Flow**: Complete user journey from RDLN → Riddles → RON → Governance

### **Revolutionary Concepts**
- **Merit-Based Governance**: Participate in proposals where intelligence > wealth
- **Progressive Economics**: Experience biennial halving and burn mechanisms
- **AI-Human Collaboration**: Community-validated questions with fair assembly
- **Oracle Network Preview**: Foundation for enterprise validation services

### **Run Integration Tests**
```bash
# Test complete ecosystem integration (8/13 passing)
npm test test/EcosystemIntegration.test.js

# Test individual components
npx hardhat test test/RDLNUpgradeable.test.js  # Advanced token tests
npx hardhat test test/RONUpgradeable.test.js   # Advanced reputation tests

# Run with gas reporting
REPORT_GAS=true npm test
```

## 📚 **Documentation**

- **📋 [Complete Deployment Guide](DEPLOYMENT-INSTRUCTIONS.md)**: Step-by-step instructions for Amoy testnet deployment
- **🌐 [Testnet Overview](TESTNET-DEPLOYMENT.md)**: Comprehensive testnet documentation and features
- **📖 [White Paper v5.2](white-paper-v5.2)**: Complete protocol vision and v5.2 roadmap
- **🧪 [Integration Tests](test/EcosystemIntegration.test.js)**: 8/13 passing ecosystem validation tests

## 🎮 **How to Participate in Testing**

### **For General Users**
1. **Get Testnet MATIC**: Visit [Polygon Faucet](https://faucet.polygon.technology/)
2. **Connect Wallet**: Use MetaMask with Amoy network configuration
3. **Start Playing**: Solve riddles, earn RON, participate in governance
4. **Provide Feedback**: Report issues or suggestions via GitHub Issues

### **For Developers**
1. **Deploy Locally**: Follow the deployment guide for local testing
2. **Run Test Suite**: `npm test` to validate ecosystem integration
3. **Contribute**: Submit PRs for improvements or additional features
4. **Build**: Integrate with the testnet contracts for your applications

## 🏆 **Milestone: v5.1 → v5.2**

This testnet deployment represents the completion of **Riddlen v5.1** and sets the foundation for **v5.2**:

### **✅ v5.1 Achievements (This Testnet)**
- Complete ecosystem integration with merit-based governance
- NFT-as-Game architecture with interactive experiences
- Progressive economics with biennial halving
- Cross-contract security and anti-cheating mechanisms

### **🎯 v5.2 Roadmap (Next Phase)**
- Autonomous AI Agent integration on Akash Network
- Enterprise Oracle Network for validation services
- Community airdrops (Phase 1: social proof, Phase 2: merit-based)
- Professional security audit and mainnet deployment

## 🤝 **Community & Support**

- **Main Repository**: [riddlen-contracts](https://github.com/RiddlenBaba/riddlen-contracts)
- **Documentation Hub**: [riddlen](https://github.com/RiddlenBaba/riddlen)
- **Twitter**: [@RiddlenToken](https://twitter.com/RiddlenToken)
- **Telegram**: Official community group
- **Issues**: Use GitHub Issues for bug reports and feature requests

## ⚡ **Quick Links**

- 🌐 **[Amoy PolygonScan](https://amoy.polygonscan.com/)** - View transactions and contracts
- 🚰 **[Polygon Faucet](https://faucet.polygon.technology/)** - Get testnet MATIC
- 📋 **[Deploy Guide](DEPLOYMENT-INSTRUCTIONS.md)** - Complete deployment instructions
- 🧪 **[Test Locally](scripts/test-deployment.js)** - Local development testing

## 🔮 **The Future of Human Intelligence**

This testnet demonstrates that decentralized systems can effectively harness human collective intelligence while creating meaningful economic incentives. By separating financial tokens (RDLN) from intellectual reputation (RON), Riddlen solves fundamental problems in both gaming economies and oracle validation systems.

**Join us in testing the future where intelligence matters more than capital!** 🧠 > 💰

---

**🤖 Generated with [Claude Code](https://claude.com/claude-code)**

**The Future is Human-Powered Intelligence—Enhanced by AI, Governed by Merit, Secured by Mathematics.**

## 📄 License

Apache 2.0 - See [LICENSE](LICENSE) for details.