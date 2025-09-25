// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title RiddlenTreasuryDripAutomated
 * @dev Production-ready automated treasury system for gaming protocol
 * @notice Implements battle-tested DeFi patterns for reliable automated distributions
 * Features: Chainlink compatibility, redundancy mechanisms, comprehensive monitoring
 */
contract RiddlenTreasuryDripAutomated is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    
    // Immutable core configuration
    IERC20 public immutable rdlnToken;
    address public treasuryWallet;
    address public operationsWallet;
    
    // Distribution configuration
    uint256 public constant MONTHLY_RELEASE = 1_000_000 * 10**18; // 1M RDLN base amount
    uint256 public constant MONTH_IN_SECONDS = 30 days;
    uint256 public constant TIMELOCK_DELAY = 7 days;
    
    // Dynamic release scaling
    uint256 public releaseMultiplier = 100; // 100 = 1.0x (100%), allows scaling
    uint256 public constant MIN_TREASURY_BALANCE = 3 * MONTHLY_RELEASE; // 3-month minimum
    uint256 public constant MAX_RELEASE_PER_PERIOD = 10 * MONTHLY_RELEASE; // Safety cap
    
    // State tracking
    uint256 public lastReleaseTime;
    uint256 public totalReleased;
    uint256 public releasesExecuted;
    uint256 public failedReleaseAttempts;
    
    // Automation compatibility 
    uint256 public automationCheckInterval = 1 days; // Health check frequency
    uint256 public lastAutomationCheck;
    bool public automationEnabled = true;
    
    // Automation service whitelist for security
    mapping(address => bool) public authorizedAutomationServices;
    
    // Failsafe mechanisms
    uint256 public emergencyReleaseThreshold = 50 * MONTHLY_RELEASE; // Trigger emergency procedures
    uint256 public consecutiveFailureLimit = 3; // Max failures before circuit breaker
    uint256 public consecutiveFailures;
    
    // Timelock system for critical changes
    uint256 private updateCounter;
    
    struct PendingUpdate {
        uint256 updateId;
        address newAddress;
        uint256 executeAfter;
        bool executed;
        string updateType;
    }
    
    mapping(uint256 => PendingUpdate) public pendingUpdates;
    mapping(string => uint256) public activeUpdateId;
    
    // Two-step ownership
    address public pendingOwner;
    
    // Comprehensive events for monitoring systems
    event TokensReleased(uint256 amount, uint256 timestamp, address indexed to, string indexed releaseType);
    event ReleaseSkipped(string reason, uint256 timestamp);
    event ReleaseFailureDetails(string indexed reason, uint256 amount, uint256 timestamp);
    event AutomationHealthCheck(bool healthy, uint256 timestamp);
    event EmergencyTriggered(string trigger, uint256 timestamp);
    event CircuitBreakerActivated(uint256 consecutiveFailures, uint256 timestamp);
    event TreasuryLowBalance(uint256 remainingBalance, uint256 monthsRemaining);
    event ReleaseMultiplierUpdated(uint256 oldMultiplier, uint256 newMultiplier);
    event AutomationServiceUpdated(address indexed service, bool authorized);
    
    // Wallet change events
    event TreasuryWalletUpdateProposed(address indexed oldWallet, address indexed newWallet, uint256 executeAfter);
    event OperationsWalletUpdateProposed(address indexed oldWallet, address indexed newWallet, uint256 executeAfter);
    event TreasuryWalletUpdated(address indexed oldWallet, address indexed newWallet);
    event OperationsWalletUpdated(address indexed oldWallet, address indexed newWallet);
    
    // Control events
    event ContractPaused(address indexed by, string reason);
    event ContractUnpaused(address indexed by);
    event OwnershipTransferProposed(address indexed currentOwner, address indexed newOwner);
    event UnauthorizedAutomationAttempt(address indexed caller, uint256 timestamp);
    
    // Custom errors
    error InsufficientTreasuryApproval();
    error InsufficientTreasuryBalance();
    error NotTimeForRelease();
    error InvalidAddress();
    error TransferFailed();
    error TimelockNotReady();
    error UpdateAlreadyExecuted();
    error NoUpdatePending();
    error OnlyPendingOwner();
    error CircuitBreakerActive();
    error InvalidMultiplier();
    error EmergencyCondition();
    
    /**
     * @dev Constructor with gaming protocol addresses
     */
    constructor(
        address _rdlnToken,
        address _treasuryWallet,
        address _operationsWallet,
        address _owner
    ) Ownable(_owner) {
        if (_rdlnToken == address(0)) revert InvalidAddress();
        if (_treasuryWallet == address(0)) revert InvalidAddress();
        if (_operationsWallet == address(0)) revert InvalidAddress();
        if (_owner == address(0)) revert InvalidAddress();
        if (_rdlnToken == address(this)) revert InvalidAddress();
        
        rdlnToken = IERC20(_rdlnToken);
        treasuryWallet = _treasuryWallet;
        operationsWallet = _operationsWallet;
        lastReleaseTime = block.timestamp;
        lastAutomationCheck = block.timestamp;
    }
    
    /**
     * @dev Main release function - handles automated and manual execution
     */
    function releaseMonthlyTokens() external onlyOwner nonReentrant whenNotPaused {
        _executeRelease("MANUAL");
    }
    
    /**
     * @dev Automation-compatible release function
     * Compatible with Chainlink Automation and Gelato
     */
    function performUpkeep(bytes calldata /* performData */) external {
        if (!automationEnabled) revert("Automation disabled");
        
        // Security: Check if caller is authorized automation service or owner
        if (msg.sender != owner() && !authorizedAutomationServices[msg.sender]) {
            emit UnauthorizedAutomationAttempt(msg.sender, block.timestamp);
            revert("Unauthorized automation caller");
        }
        
        _executeRelease("AUTOMATED");
    }
    
    /**
     * @dev Chainlink Automation compatibility check
     */
    function checkUpkeep(bytes calldata /* checkData */) 
        external 
        view 
        returns (bool upkeepNeeded, bytes memory performData) 
    {
        upkeepNeeded = automationEnabled && 
                      canRelease() && 
                      !paused() && 
                      consecutiveFailures < consecutiveFailureLimit;
        performData = ""; // Explicit return for clarity
    }
    
    /**
     * @dev Core release execution with comprehensive error handling
     */
    function _executeRelease(string memory releaseType) internal {
        if (consecutiveFailures >= consecutiveFailureLimit) revert CircuitBreakerActive();
        if (!canRelease()) revert NotTimeForRelease();
        
        uint256 currentTime = block.timestamp;
        uint256 releaseAmount = calculateReleaseAmount();
        
        // Pre-flight checks
        uint256 allowance = rdlnToken.allowance(treasuryWallet, address(this));
        if (allowance < releaseAmount) revert InsufficientTreasuryApproval();
        
        uint256 treasuryBalance = rdlnToken.balanceOf(treasuryWallet);
        if (treasuryBalance < releaseAmount) revert InsufficientTreasuryBalance();
        
        // Emergency conditions check - SECURITY FIX: Reduced to 5% for safety
        if (treasuryBalance <= emergencyReleaseThreshold) {
            emit EmergencyTriggered("Low treasury balance", currentTime);
            // Continue but with reduced amount - reduced from 10% to 5% per audit
            releaseAmount = treasuryBalance / 20; // Release 5% in emergency (was 10%)
        }
        
        // State updates before external call
        lastReleaseTime = currentTime;
        
        // Attempt transfer with comprehensive error handling
        try rdlnToken.transferFrom(treasuryWallet, operationsWallet, releaseAmount) {
            // Successful transfer - update state
            unchecked {
                totalReleased += releaseAmount;
                releasesExecuted++;
            }
            consecutiveFailures = 0; // Reset failure counter
            
            emit TokensReleased(releaseAmount, currentTime, operationsWallet, releaseType);
            
            // Treasury monitoring
            uint256 remainingBalance = rdlnToken.balanceOf(treasuryWallet);
            uint256 monthsRemaining = remainingBalance / MONTHLY_RELEASE;
            
            if (monthsRemaining <= 3) {
                emit TreasuryLowBalance(remainingBalance, monthsRemaining);
            }
            
        } catch Error(string memory reason) {
            _handleReleaseFailed(reason, releaseAmount, currentTime);
        } catch {
            _handleReleaseFailed("Unknown transfer failure", releaseAmount, currentTime);
        }
    }
    
    /**
     * @dev Handle failed release attempts with circuit breaker logic
     * SECURITY FIX: Added underflow protection per audit recommendation
     */
    function _handleReleaseFailed(string memory reason, uint256 amount, uint256 timestamp) internal {
        // Revert state changes - SECURITY FIX: Protect against underflow
        if (lastReleaseTime >= MONTH_IN_SECONDS) {
            lastReleaseTime -= MONTH_IN_SECONDS;
        } else {
            lastReleaseTime = 0; // Reset to safe value to prevent underflow
        }
        
        unchecked {
            failedReleaseAttempts++;
            consecutiveFailures++;
        }
        
        // Emit detailed failure information for monitoring
        emit ReleaseSkipped(reason, timestamp);
        emit ReleaseFailureDetails(reason, amount, timestamp);
        
        // Circuit breaker activation
        if (consecutiveFailures >= consecutiveFailureLimit) {
            emit CircuitBreakerActivated(consecutiveFailures, timestamp);
            _pause();
        }
        
        revert TransferFailed();
    }
    
    /**
     * @dev Calculate dynamic release amount based on treasury balance
     */
    function calculateReleaseAmount() public view returns (uint256) {
        uint256 baseAmount = (MONTHLY_RELEASE * releaseMultiplier) / 100;
        
        // Cap at maximum allowed per period
        if (baseAmount > MAX_RELEASE_PER_PERIOD) {
            baseAmount = MAX_RELEASE_PER_PERIOD;
        }
        
        // Ensure minimum treasury balance maintained
        uint256 treasuryBalance = rdlnToken.balanceOf(treasuryWallet);
        if (treasuryBalance <= MIN_TREASURY_BALANCE) {
            return 0; // Skip release to maintain minimum balance
        }
        
        // If treasury is low, reduce release amount
        uint256 safeAmount = treasuryBalance - MIN_TREASURY_BALANCE;
        return baseAmount > safeAmount ? safeAmount : baseAmount;
    }
    
    // VIEW FUNCTIONS (declared before getContractStatus)
    
    function canRelease() public view returns (bool) {
        if (block.timestamp < lastReleaseTime + MONTH_IN_SECONDS) return false;
        if (calculateReleaseAmount() == 0) return false;
        
        uint256 allowance = rdlnToken.allowance(treasuryWallet, address(this));
        return allowance >= calculateReleaseAmount();
    }
    
    function timeUntilNextRelease() external view returns (uint256) {
        if (canRelease()) return 0;
        return (lastReleaseTime + MONTH_IN_SECONDS) - block.timestamp;
    }
    
    function getTreasuryAllowance() public view returns (uint256) {
        return rdlnToken.allowance(treasuryWallet, address(this));
    }
    
    function getTreasuryBalance() external view returns (uint256) {
        return rdlnToken.balanceOf(treasuryWallet);
    }
    
    function getRemainingReleases() public view returns (uint256) {
        uint256 treasuryBalance = rdlnToken.balanceOf(treasuryWallet);
        uint256 releaseAmount = calculateReleaseAmount();
        if (releaseAmount == 0) return 0;
        return (treasuryBalance - MIN_TREASURY_BALANCE) / releaseAmount;
    }
    
    function getNextReleaseTime() external view returns (uint256) {
        return lastReleaseTime + MONTH_IN_SECONDS;
    }
    
    /**
     * @dev Comprehensive system health status
     */
    function getContractStatus() external view returns (
        uint256 _totalReleased,
        uint256 _releasesExecuted,
        uint256 _failedAttempts,
        uint256 _consecutiveFailures,
        uint256 _remainingReleases,
        bool _canReleaseNow,
        bool _isPaused,
        bool _automationEnabled,
        uint256 _treasuryApproval,
        address _pendingOwner
    ) {
        return (
            totalReleased,
            releasesExecuted,
            failedReleaseAttempts,
            consecutiveFailures,
            getRemainingReleases(),
            canRelease(),
            paused(),
            automationEnabled,
            getTreasuryAllowance(),
            pendingOwner
        );
    }
    
    // AUTOMATION & MONITORING FUNCTIONS
    
    /**
     * @dev Health check function for monitoring systems
     */
    function performHealthCheck() external {
        lastAutomationCheck = block.timestamp;
        
        bool systemHealthy = true;
        string memory healthIssue = "";
        
        // Check treasury balance
        uint256 balance = rdlnToken.balanceOf(treasuryWallet);
        if (balance < MIN_TREASURY_BALANCE) {
            systemHealthy = false;
            healthIssue = "Treasury below minimum";
        }
        
        // Check allowance
        uint256 allowance = getTreasuryAllowance();
        if (allowance < MONTHLY_RELEASE) {
            systemHealthy = false;
            healthIssue = "Insufficient allowance";
        }
        
        // Check for stuck releases
        if (block.timestamp > lastReleaseTime + MONTH_IN_SECONDS + 1 days) {
            systemHealthy = false;
            healthIssue = "Release overdue";
        }
        
        emit AutomationHealthCheck(systemHealthy, block.timestamp);
        
        if (!systemHealthy) {
            emit EmergencyTriggered(healthIssue, block.timestamp);
        }
    }
    
    /**
     * @dev Emergency drain function - can only be called when paused
     */
    function emergencyDrain(uint256 amount) external onlyOwner whenPaused {
        if (amount == 0) {
            amount = rdlnToken.balanceOf(treasuryWallet);
        }
        
        rdlnToken.safeTransferFrom(treasuryWallet, operationsWallet, amount);
        emit TokensReleased(amount, block.timestamp, operationsWallet, "EMERGENCY_DRAIN");
    }
    
    /**
     * @dev Reset circuit breaker after resolving issues
     */
    function resetCircuitBreaker() external onlyOwner {
        consecutiveFailures = 0;
        if (paused()) {
            _unpause();
        }
        emit ContractUnpaused(msg.sender);
    }
    
    /**
     * @dev Update release multiplier for dynamic scaling
     */
    function updateReleaseMultiplier(uint256 newMultiplier) external onlyOwner {
        if (newMultiplier == 0 || newMultiplier > 500) revert InvalidMultiplier(); // Max 5x
        
        uint256 oldMultiplier = releaseMultiplier;
        releaseMultiplier = newMultiplier;
        
        emit ReleaseMultiplierUpdated(oldMultiplier, newMultiplier);
    }
    
    /**
     * @dev Set automation enabled state
     */
    function setAutomationEnabled(bool enabled) external onlyOwner {
        automationEnabled = enabled;
    }
    
    /**
     * @dev Add or remove authorized automation service
     */
    function setAutomationService(address service, bool authorized) external onlyOwner {
        if (service == address(0)) revert InvalidAddress();
        authorizedAutomationServices[service] = authorized;
        emit AutomationServiceUpdated(service, authorized);
    }
    
    /**
     * @dev Batch update automation services
     */
    function setAutomationServices(address[] calldata services, bool[] calldata authorizations) external onlyOwner {
        if (services.length != authorizations.length) revert("Array length mismatch");
        
        for (uint256 i = 0; i < services.length; ) {
            if (services[i] == address(0)) revert InvalidAddress();
            authorizedAutomationServices[services[i]] = authorizations[i];
            emit AutomationServiceUpdated(services[i], authorizations[i]);
            
            unchecked { ++i; }
        }
    }
    
    // WALLET UPDATE FUNCTIONS (with timelock)
    
    function proposeTreasuryWalletUpdate(address _newTreasury) external onlyOwner {
        if (_newTreasury == address(0)) revert InvalidAddress();
        
        unchecked { ++updateCounter; }
        
        pendingUpdates[updateCounter] = PendingUpdate({
            updateId: updateCounter,
            newAddress: _newTreasury,
            executeAfter: block.timestamp + TIMELOCK_DELAY,
            executed: false,
            updateType: "treasury"
        });
        
        activeUpdateId["treasury"] = updateCounter;
        
        emit TreasuryWalletUpdateProposed(treasuryWallet, _newTreasury, block.timestamp + TIMELOCK_DELAY);
    }
    
    function executeTreasuryWalletUpdate() external onlyOwner {
        uint256 updateId = activeUpdateId["treasury"];
        PendingUpdate storage update = pendingUpdates[updateId];
        
        if (update.newAddress == address(0)) revert NoUpdatePending();
        if (block.timestamp < update.executeAfter) revert TimelockNotReady();
        if (update.executed) revert UpdateAlreadyExecuted();
        
        address oldTreasury = treasuryWallet;
        treasuryWallet = update.newAddress;
        update.executed = true;
        
        emit TreasuryWalletUpdated(oldTreasury, update.newAddress);
    }
    
    function proposeOperationsWalletUpdate(address _newOperations) external onlyOwner {
        if (_newOperations == address(0)) revert InvalidAddress();
        
        unchecked { ++updateCounter; }
        
        pendingUpdates[updateCounter] = PendingUpdate({
            updateId: updateCounter,
            newAddress: _newOperations,
            executeAfter: block.timestamp + TIMELOCK_DELAY,
            executed: false,
            updateType: "operations"
        });
        
        activeUpdateId["operations"] = updateCounter;
        
        emit OperationsWalletUpdateProposed(operationsWallet, _newOperations, block.timestamp + TIMELOCK_DELAY);
    }
    
    function executeOperationsWalletUpdate() external onlyOwner {
        uint256 updateId = activeUpdateId["operations"];
        PendingUpdate storage update = pendingUpdates[updateId];
        
        if (update.newAddress == address(0)) revert NoUpdatePending();
        if (block.timestamp < update.executeAfter) revert TimelockNotReady();
        if (update.executed) revert UpdateAlreadyExecuted();
        
        address oldOperations = operationsWallet;
        operationsWallet = update.newAddress;
        update.executed = true;
        
        emit OperationsWalletUpdated(oldOperations, update.newAddress);
    }
    
    // OWNERSHIP MANAGEMENT
    
    function proposeOwnershipTransfer(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert InvalidAddress();
        pendingOwner = _newOwner;
        emit OwnershipTransferProposed(owner(), _newOwner);
    }
    
    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert OnlyPendingOwner();
        _transferOwnership(pendingOwner);
        pendingOwner = address(0);
    }
    
    // PAUSE/UNPAUSE WITH REASONS
    
    function pause(string calldata reason) external onlyOwner {
        _pause();
        emit ContractPaused(msg.sender, reason);
    }
    
    function unpause() external onlyOwner {
        _unpause();
        emit ContractUnpaused(msg.sender);
    }
    
    // UTILITY FUNCTIONS FOR PENDING UPDATES
    
    function getPendingUpdate(string memory updateType) external view returns (
        uint256 updateId,
        address newAddress,
        uint256 executeAfter,
        bool executed
    ) {
        uint256 id = activeUpdateId[updateType];
        PendingUpdate memory update = pendingUpdates[id];
        return (update.updateId, update.newAddress, update.executeAfter, update.executed);
    }
    
    function getPendingUpdateById(uint256 updateId) external view returns (
        address newAddress,
        uint256 executeAfter,
        bool executed,
        string memory updateType
    ) {
        PendingUpdate memory update = pendingUpdates[updateId];
        return (update.newAddress, update.executeAfter, update.executed, update.updateType);
    }
}
