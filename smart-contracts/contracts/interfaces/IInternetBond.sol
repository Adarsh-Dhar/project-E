// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IInternetBond {
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
    function distributeYield(uint256 amount) external;
} 