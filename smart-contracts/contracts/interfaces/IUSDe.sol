// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IUSDe {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function addReserveAsset(address asset) external;
    function removeReserveAsset(address asset) external;
} 