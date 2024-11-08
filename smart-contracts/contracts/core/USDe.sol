// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract USDe is ERC20, Ownable, Pausable, ReentrancyGuard {
    mapping(address => bool) public reserveAssets;
    mapping(address => uint256) public reserveBalances;
    uint256 public totalReserves;
    
    event ReserveAssetAdded(address indexed asset);
    event ReserveAssetRemoved(address indexed asset);
    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);
    
    constructor() ERC20("USD Enterprise", "USDe") Ownable(msg.sender) {
        _pause(); // Start paused for safety
    }
    
    function addReserveAsset(address asset) external onlyOwner {
        require(asset != address(0), "Invalid asset address");
        reserveAssets[asset] = true;
        emit ReserveAssetAdded(asset);
    }
    
    function removeReserveAsset(address asset) external onlyOwner {
        require(reserveAssets[asset], "Asset not found");
        reserveAssets[asset] = false;
        emit ReserveAssetRemoved(asset);
    }
    
    function mint(address to, uint256 amount) external nonReentrant whenNotPaused {
        require(reserveAssets[msg.sender], "Not authorized");
        _mint(to, amount);
        emit Minted(to, amount);
    }
    
    function burn(address from, uint256 amount) external nonReentrant whenNotPaused {
        require(reserveAssets[msg.sender], "Not authorized");
        _burn(from, amount);
        emit Burned(from, amount);
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
} 