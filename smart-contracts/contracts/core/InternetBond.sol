// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InternetBond is ReentrancyGuard, Ownable {
    struct Strategy {
        address asset;
        uint256 allocation;
        bool active;
    }
    
    struct UserPosition {
        uint256 shares;
        uint256 depositTime;
    }
    
    mapping(address => UserPosition) public positions;
    mapping(uint256 => Strategy) public strategies;
    uint256 public totalShares;
    uint256 public totalValue;
    uint256 public strategyCount;
    
    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdraw(address indexed user, uint256 amount, uint256 shares);
    event YieldDistributed(uint256 amount);
    
    constructor() Ownable(msg.sender) {}
    
    function addStrategy(address asset, uint256 allocation) external onlyOwner {
        require(asset != address(0), "Invalid asset");
        require(allocation > 0, "Invalid allocation");
        
        strategies[strategyCount] = Strategy({
            asset: asset,
            allocation: allocation,
            active: true
        });
        strategyCount++;
    }
    
    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        
        uint256 shares = totalShares == 0 ? 
            amount : (amount * totalShares) / totalValue;
            
        positions[msg.sender].shares += shares;
        positions[msg.sender].depositTime = block.timestamp;
        totalShares += shares;
        totalValue += amount;
        
        emit Deposit(msg.sender, amount, shares);
    }
    
    function withdraw(uint256 shares) external nonReentrant {
        require(shares > 0 && shares <= positions[msg.sender].shares, "Invalid shares");
        
        uint256 amount = (shares * totalValue) / totalShares;
        positions[msg.sender].shares -= shares;
        totalShares -= shares;
        totalValue -= amount;
        
        emit Withdraw(msg.sender, amount, shares);
    }
    
    function distributeYield(uint256 amount) external onlyOwner {
        totalValue += amount;
        emit YieldDistributed(amount);
    }
} 