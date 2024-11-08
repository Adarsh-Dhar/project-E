// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDe.sol";
import "./InternetBond.sol";

contract UndercollateralizedLending is ReentrancyGuard, Ownable {
    struct Loan {
        uint256 amount;
        uint256 collateral;
        uint256 startTime;
        uint256 duration;
        uint256 interestRate;
        bool active;
    }
    
    mapping(address => Loan) public loans;
    USDe public usde;
    InternetBond public internetBond;
    
    uint256 public minCollateralRatio;
    uint256 public liquidationThreshold;
    uint256 public totalLoans;
    
    event LoanCreated(address indexed borrower, uint256 amount, uint256 collateral);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event LoanLiquidated(address indexed borrower, uint256 amount);
    
    constructor(
        address _usde,
        address _internetBond,
        uint256 _minCollateralRatio,
        uint256 _liquidationThreshold
    ) Ownable(msg.sender) {
        usde = USDe(_usde);
        internetBond = InternetBond(_internetBond);
        minCollateralRatio = _minCollateralRatio;
        liquidationThreshold = _liquidationThreshold;
    }
    
    function requestLoan(uint256 amount, uint256 duration) external nonReentrant {
        require(amount > 0, "Invalid amount");
        require(duration > 0, "Invalid duration");
        require(!loans[msg.sender].active, "Existing loan");
        
        uint256 requiredCollateral = (amount * minCollateralRatio) / 100;
        
        loans[msg.sender] = Loan({
            amount: amount,
            collateral: requiredCollateral,
            startTime: block.timestamp,
            duration: duration,
            interestRate: calculateInterestRate(amount, requiredCollateral),
            active: true
        });
        
        totalLoans += amount;
        emit LoanCreated(msg.sender, amount, requiredCollateral);
    }
    
    function repayLoan() external nonReentrant {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "No active loan");
        
        uint256 interest = calculateInterest(loan);
        uint256 totalRepayment = loan.amount + interest;
        
        loan.active = false;
        totalLoans -= loan.amount;
        
        emit LoanRepaid(msg.sender, totalRepayment);
    }
    
    function liquidate(address borrower) external nonReentrant {
        Loan storage loan = loans[borrower];
        require(loan.active, "No active loan");
        require(isLiquidatable(loan), "Not liquidatable");
        
        loan.active = false;
        totalLoans -= loan.amount;
        
        emit LoanLiquidated(borrower, loan.amount);
    }
    
    function calculateInterestRate(uint256 amount, uint256 collateral) internal pure returns (uint256) {
        return 5; // 5% base rate, can be made more sophisticated
    }
    
    function calculateInterest(Loan memory loan) internal view returns (uint256) {
        uint256 timeElapsed = block.timestamp - loan.startTime;
        return (loan.amount * loan.interestRate * timeElapsed) / (365 days * 100);
    }
    
    function isLiquidatable(Loan memory loan) internal view returns (uint256) {
        uint256 currentRatio = (loan.collateral * 100) / loan.amount;
        return currentRatio < liquidationThreshold;
    }
} 