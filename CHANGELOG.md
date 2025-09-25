# Changelog

All notable changes to the Riddlen smart contracts will be documented in this file.

## [Unreleased] - 2025-09-25

### Added
- Initial TreasuryDrip.sol contract implementation
- Comprehensive security audit documentation
- Automated treasury distribution system

### Security Fixes
- [MEDIUM-001] Fixed potential underflow in `_handleReleaseFailed()` function
- [MEDIUM-002] Reduced emergency release percentage from 10% to 5% for safety
- [LOW-001] Added unauthorized access attempt logging

### Documentation
- Added detailed security audit report
- Enhanced NatSpec documentation for complex functions
- Created comprehensive changelog

### Contract: TreasuryDrip.sol
**Location:** `contracts/governance/TreasuryDrip.sol`
**Audit Status:** ✅ PASSED with fixes applied
**Deployment Status:** 🚧 Pre-deployment

#### Changes Made:
1. **Underflow Protection** (Line 223-227)
   - Added safety check before subtracting MONTH_IN_SECONDS
   - Prevents state corruption in edge cases

2. **Emergency Release Safety** (Line 186)
   - Reduced emergency release from 10% to 5%
   - Added minimum threshold check

3. **Security Event Logging** (Line 143-145)
   - Added UnauthorizedAutomationAttempt event
   - Enhanced monitoring capabilities

## Contract Deployment History

### TreasuryDrip.sol
- **v1.0.0-pre** - Initial implementation with security fixes applied
- **Audit Date:** 2025-09-25
- **Status:** Ready for testnet deployment