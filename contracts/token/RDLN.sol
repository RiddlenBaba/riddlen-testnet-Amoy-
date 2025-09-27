// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "../interfaces/IRDLN.sol";

/**
 * @title RDLN - Riddlen Token
 * @dev ERC-20 token with integrated deflationary mechanics for the Riddlen ecosystem
 * @notice Features burn mechanisms, prize pool management, and gaming integration
 *
 * Total Supply: 1,000,000,000 RDLN
 * Allocation:
 * - 700M RDLN: Prize pools (70%)
 * - 100M RDLN: Treasury (10%)
 * - 100M RDLN: Community airdrop (10%)
 * - 100M RDLN: Liquidity (10%)
 */
contract RDLN is ERC20, ERC20Burnable, AccessControl, ReentrancyGuard, Pausable, IRDLN {

    // ============ CONSTANTS ============

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant GAME_ROLE = keccak256("GAME_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // Token distribution constants
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion RDLN
    uint256 public constant PRIZE_POOL_ALLOCATION = 700_000_000 * 10**18; // 70%
    uint256 public constant TREASURY_ALLOCATION = 100_000_000 * 10**18; // 10%
    uint256 public constant AIRDROP_ALLOCATION = 100_000_000 * 10**18; // 10%
    uint256 public constant LIQUIDITY_ALLOCATION = 100_000_000 * 10**18; // 10%

    // ============ STATE VARIABLES ============

    // Allocation tracking
    uint256 public prizePoolMinted;
    uint256 public treasuryMinted;
    uint256 public airdropMinted;
    uint256 public liquidityMinted;

    // Burn tracking for deflationary mechanics
    uint256 public totalBurned;
    uint256 public gameplayBurned; // Burns from failed attempts, rejections
    uint256 public transferBurned; // Burns from transfer fees (if enabled)

    // Game mechanics
    mapping(address => uint256) public failedAttempts; // Track failed attempts per user
    mapping(address => uint256) public questionsSubmitted; // Track questions per user

    // Wallets for allocations
    address public treasuryWallet;
    address public liquidityWallet;
    address public airdropWallet;

    // Deflationary settings
    bool public burnOnTransferEnabled;
    uint256 public transferBurnRate = 100; // 1% burn on transfers (100/10000)
    uint256 public constant MAX_BURN_RATE = 500; // Max 5% burn rate

    // ============ EVENTS ============

    event BurnOnTransferToggled(bool enabled);
    event TransferBurnRateUpdated(uint256 oldRate, uint256 newRate);
    event WalletUpdated(string indexed walletType, address indexed oldWallet, address indexed newWallet);

    // ============ ERRORS ============

    error AllocationExceeded(string allocationType, uint256 requested, uint256 remaining);
    error InvalidAddress(address addr);
    error InvalidBurnRate(uint256 rate);
    error InsufficientBalance(address user, uint256 required, uint256 available);
    error GameContractOnly();

    // ============ CONSTRUCTOR ============

    constructor(
        address _admin,
        address _treasuryWallet,
        address _liquidityWallet,
        address _airdropWallet
    ) ERC20("Riddlen", "RDLN") {
        if (_admin == address(0)) revert InvalidAddress(_admin);
        if (_treasuryWallet == address(0)) revert InvalidAddress(_treasuryWallet);
        if (_liquidityWallet == address(0)) revert InvalidAddress(_liquidityWallet);
        if (_airdropWallet == address(0)) revert InvalidAddress(_airdropWallet);

        treasuryWallet = _treasuryWallet;
        liquidityWallet = _liquidityWallet;
        airdropWallet = _airdropWallet;

        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _admin);
        _grantRole(BURNER_ROLE, _admin);
        _grantRole(PAUSER_ROLE, _admin);

        // Initial mint for immediate needs (small allocation for initial setup)
        _mint(_admin, 1_000_000 * 10**18); // 1M RDLN for initial setup
    }

    // ============ ALLOCATION MINTING ============

    /**
     * @dev Mint tokens for prize pool allocation
     */
    function mintPrizePool(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        if (prizePoolMinted + amount > PRIZE_POOL_ALLOCATION) {
            revert AllocationExceeded("PRIZE_POOL", amount, PRIZE_POOL_ALLOCATION - prizePoolMinted);
        }

        prizePoolMinted += amount;
        _mint(to, amount);
        emit AllocationMinted("PRIZE_POOL", to, amount);
    }

    /**
     * @dev Mint tokens for treasury allocation
     */
    function mintTreasury(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        if (treasuryMinted + amount > TREASURY_ALLOCATION) {
            revert AllocationExceeded("TREASURY", amount, TREASURY_ALLOCATION - treasuryMinted);
        }

        treasuryMinted += amount;
        _mint(to, amount);
        emit AllocationMinted("TREASURY", to, amount);
    }

    /**
     * @dev Mint tokens for airdrop allocation
     */
    function mintAirdrop(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        if (airdropMinted + amount > AIRDROP_ALLOCATION) {
            revert AllocationExceeded("AIRDROP", amount, AIRDROP_ALLOCATION - airdropMinted);
        }

        airdropMinted += amount;
        _mint(to, amount);
        emit AllocationMinted("AIRDROP", to, amount);
    }

    /**
     * @dev Mint tokens for liquidity allocation
     */
    function mintLiquidity(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        if (liquidityMinted + amount > LIQUIDITY_ALLOCATION) {
            revert AllocationExceeded("LIQUIDITY", amount, LIQUIDITY_ALLOCATION - liquidityMinted);
        }

        liquidityMinted += amount;
        _mint(to, amount);
        emit AllocationMinted("LIQUIDITY", to, amount);
    }

    // ============ GAME MECHANICS INTEGRATION ============

    /**
     * @dev Burn tokens for failed riddle attempts (progressive cost)
     * @param user Address of the user making the attempt
     * @return burnAmount Amount of tokens burned
     */
    function burnFailedAttempt(address user) external onlyRole(GAME_ROLE) whenNotPaused returns (uint256 burnAmount) {
        failedAttempts[user]++;
        burnAmount = failedAttempts[user] * 1 * 10**18; // N RDLN for Nth failed attempt

        if (balanceOf(user) < burnAmount) {
            revert InsufficientBalance(user, burnAmount, balanceOf(user));
        }

        _burn(user, burnAmount);
        gameplayBurned += burnAmount;
        totalBurned += burnAmount;

        emit FailedAttemptBurn(user, failedAttempts[user], burnAmount);
        emit GameplayBurn(user, burnAmount, "FAILED_ATTEMPT");

        return burnAmount;
    }

    /**
     * @dev Burn tokens for question submission (progressive cost)
     * @param user Address of the user submitting the question
     * @return burnAmount Amount of tokens burned
     */
    function burnQuestionSubmission(address user) external onlyRole(GAME_ROLE) whenNotPaused returns (uint256 burnAmount) {
        questionsSubmitted[user]++;
        burnAmount = questionsSubmitted[user] * 1 * 10**18; // N RDLN for Nth question

        if (balanceOf(user) < burnAmount) {
            revert InsufficientBalance(user, burnAmount, balanceOf(user));
        }

        _burn(user, burnAmount);
        gameplayBurned += burnAmount;
        totalBurned += burnAmount;

        emit QuestionSubmissionBurn(user, questionsSubmitted[user], burnAmount);
        emit GameplayBurn(user, burnAmount, "QUESTION_SUBMISSION");

        return burnAmount;
    }

    /**
     * @dev Burn tokens for NFT minting (riddle attempts)
     * @param user Address of the user minting NFT
     * @param cost Cost in RDLN for the NFT mint
     */
    function burnNFTMint(address user, uint256 cost) external onlyRole(GAME_ROLE) whenNotPaused {
        if (balanceOf(user) < cost) {
            revert InsufficientBalance(user, cost, balanceOf(user));
        }

        _burn(user, cost);
        gameplayBurned += cost;
        totalBurned += cost;

        emit GameplayBurn(user, cost, "NFT_MINT");
    }

    // ============ DEFLATIONARY MECHANICS ============

    /**
     * @dev Override transfer to implement optional burn on transfer
     */
    function _update(address from, address to, uint256 amount) internal override {
        require(!paused(), "RDLN: token transfer while paused");

        // Apply burn on transfer if enabled (exclude minting and burning)
        if (burnOnTransferEnabled && from != address(0) && to != address(0)) {
            uint256 burnAmount = (amount * transferBurnRate) / 10000;
            if (burnAmount > 0) {
                // Burn tokens before the transfer
                super._update(from, address(0), burnAmount);
                transferBurned += burnAmount;
                totalBurned += burnAmount;
                emit TransferBurn(from, burnAmount);

                // Reduce the amount to transfer by the burn amount
                amount -= burnAmount;
            }
        }

        super._update(from, to, amount);
    }

    /**
     * @dev Enable/disable burn on transfer mechanism
     */
    function setBurnOnTransfer(bool enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        burnOnTransferEnabled = enabled;
        emit BurnOnTransferToggled(enabled);
    }

    /**
     * @dev Update transfer burn rate (max 5%)
     */
    function setTransferBurnRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newRate > MAX_BURN_RATE) revert InvalidBurnRate(newRate);

        uint256 oldRate = transferBurnRate;
        transferBurnRate = newRate;
        emit TransferBurnRateUpdated(oldRate, newRate);
    }

    // ============ ADMIN FUNCTIONS ============

    /**
     * @dev Update treasury wallet
     */
    function setTreasuryWallet(address newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newWallet == address(0)) revert InvalidAddress(newWallet);
        address oldWallet = treasuryWallet;
        treasuryWallet = newWallet;
        emit WalletUpdated("TREASURY", oldWallet, newWallet);
    }

    /**
     * @dev Update liquidity wallet
     */
    function setLiquidityWallet(address newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newWallet == address(0)) revert InvalidAddress(newWallet);
        address oldWallet = liquidityWallet;
        liquidityWallet = newWallet;
        emit WalletUpdated("LIQUIDITY", oldWallet, newWallet);
    }

    /**
     * @dev Update airdrop wallet
     */
    function setAirdropWallet(address newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newWallet == address(0)) revert InvalidAddress(newWallet);
        address oldWallet = airdropWallet;
        airdropWallet = newWallet;
        emit WalletUpdated("AIRDROP", oldWallet, newWallet);
    }

    /**
     * @dev Pause contract
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause contract
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // ============ VIEW FUNCTIONS ============

    /**
     * @dev Get remaining allocation amounts
     */
    function getRemainingAllocations() external view returns (
        uint256 prizePoolRemaining,
        uint256 treasuryRemaining,
        uint256 airdropRemaining,
        uint256 liquidityRemaining
    ) {
        prizePoolRemaining = PRIZE_POOL_ALLOCATION - prizePoolMinted;
        treasuryRemaining = TREASURY_ALLOCATION - treasuryMinted;
        airdropRemaining = AIRDROP_ALLOCATION - airdropMinted;
        liquidityRemaining = LIQUIDITY_ALLOCATION - liquidityMinted;
    }

    /**
     * @dev Get burn statistics
     */
    function getBurnStats() external view returns (
        uint256 _totalBurned,
        uint256 _gameplayBurned,
        uint256 _transferBurned,
        uint256 currentSupply
    ) {
        _totalBurned = totalBurned;
        _gameplayBurned = gameplayBurned;
        _transferBurned = transferBurned;
        currentSupply = totalSupply();
    }

    /**
     * @dev Get user gameplay statistics
     */
    function getUserStats(address user) external view returns (
        uint256 _failedAttempts,
        uint256 _questionsSubmitted,
        uint256 balance
    ) {
        _failedAttempts = failedAttempts[user];
        _questionsSubmitted = questionsSubmitted[user];
        balance = balanceOf(user);
    }

    /**
     * @dev Calculate next burn cost for failed attempt
     */
    function getNextFailedAttemptCost(address user) external view returns (uint256) {
        return (failedAttempts[user] + 1) * 1 * 10**18;
    }

    /**
     * @dev Calculate next burn cost for question submission
     */
    function getNextQuestionCost(address user) external view returns (uint256) {
        return (questionsSubmitted[user] + 1) * 1 * 10**18;
    }

    // ============ EMERGENCY FUNCTIONS ============

    /**
     * @dev Emergency burn function for admin use
     */
    function emergencyBurn(address account, uint256 amount) external onlyRole(BURNER_ROLE) whenPaused {
        _burn(account, amount);
        totalBurned += amount;
        emit GameplayBurn(account, amount, "EMERGENCY_BURN");
    }

    // ============ COMPATIBILITY ============

    /**
     * @dev Override required by Solidity for multiple inheritance
     */
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}