// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityProvider is ReentrancyGuard, Ownable {
    struct StakingPosition {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastUpdateTime;
    }
    
    IERC20 public lpToken;
    IERC20 public rewardToken;
    
    uint256 public rewardRate;
    uint256 public totalStaked;
    uint256 public accRewardPerShare;
    uint256 public lastUpdateTime;
    
    mapping(address => StakingPosition) public positions;
    
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    
    constructor(
        address _lpToken,
        address _rewardToken,
        uint256 _rewardRate
    ) Ownable(msg.sender) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }
    
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        updateRewards();
        
        positions[msg.sender].amount += amount;
        positions[msg.sender].rewardDebt = (positions[msg.sender].amount * accRewardPerShare) / 1e18;
        totalStaked += amount;
        
        emit Staked(msg.sender, amount);
    }
    
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0 && amount <= positions[msg.sender].amount, "Invalid amount");
        updateRewards();
        
        positions[msg.sender].amount -= amount;
        positions[msg.sender].rewardDebt = (positions[msg.sender].amount * accRewardPerShare) / 1e18;
        totalStaked -= amount;
        
        emit Withdrawn(msg.sender, amount);
    }
    
    function claimRewards() external nonReentrant {
        updateRewards();
        uint256 pending = (positions[msg.sender].amount * accRewardPerShare) / 1e18 - 
            positions[msg.sender].rewardDebt;
            
        if (pending > 0) {
            positions[msg.sender].rewardDebt = (positions[msg.sender].amount * accRewardPerShare) / 1e18;
            rewardToken.transfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, pending);
        }
    }
    
    function updateRewards() internal {
        if (totalStaked == 0) {
            lastUpdateTime = block.timestamp;
            return;
        }
        
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        uint256 rewards = timeElapsed * rewardRate;
        accRewardPerShare += (rewards * 1e18) / totalStaked;
        lastUpdateTime = block.timestamp;
    }
} 