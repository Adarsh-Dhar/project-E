import { ethers } from 'ethers';
import { CONTRACT_ADDRESSES, CONTRACT_ABIS } from './config';

export class LendingService {
  private provider: ethers.providers.Web3Provider;
  private signer: ethers.Signer;
  private lendingContract: ethers.Contract;
  private adeToken: ethers.Contract;
  private larToken: ethers.Contract;

  constructor(provider: ethers.providers.Web3Provider) {
    this.provider = provider;
    this.signer = provider.getSigner();
    
    this.lendingContract = new ethers.Contract(
      CONTRACT_ADDRESSES.LENDING_AND_BORROWING,
      CONTRACT_ABIS.LENDING_AND_BORROWING,
      this.signer
    );

    this.adeToken = new ethers.Contract(
      CONTRACT_ADDRESSES.ADE_TOKEN,
      CONTRACT_ABIS.ADE_TOKEN,
      this.signer
    );

    this.larToken = new ethers.Contract(
      CONTRACT_ADDRESSES.LAR_TOKEN,
      CONTRACT_ABIS.LAR_TOKEN,
      this.signer
    );
  }

  async lend(tokenAddress: string, amount: string) {
    try {
      const token = new ethers.Contract(
        tokenAddress,
        CONTRACT_ABIS.ADE_TOKEN, // Using ADE ABI as base ERC20 ABI
        this.signer
      );

      // Approve spending
      const approveTx = await token.approve(
        CONTRACT_ADDRESSES.LENDING_AND_BORROWING,
        amount
      );
      await approveTx.wait();

      // Perform lending
      const tx = await this.lendingContract.lend(tokenAddress, amount);
      return await tx.wait();
    } catch (error) {
      console.error('Error in lend:', error);
      throw error;
    }
  }

  async borrow(amount: string, tokenAddress: string) {
    try {
      const tx = await this.lendingContract.borrow(amount, tokenAddress);
      return await tx.wait();
    } catch (error) {
      console.error('Error in borrow:', error);
      throw error;
    }
  }

  async payDebt(tokenAddress: string, amount: string) {
    try {
      const token = new ethers.Contract(
        tokenAddress,
        CONTRACT_ABIS.ADE_TOKEN,
        this.signer
      );

      // Approve spending
      const approveTx = await token.approve(
        CONTRACT_ADDRESSES.LENDING_AND_BORROWING,
        amount
      );
      await approveTx.wait();

      const tx = await this.lendingContract.payDebt(tokenAddress, amount);
      return await tx.wait();
    } catch (error) {
      console.error('Error in payDebt:', error);
      throw error;
    }
  }

  async withdraw(tokenAddress: string, amount: string) {
    try {
      // Approve LAR token spending
      const larAmount = await this.lendingContract.getAmountInDollars(amount, tokenAddress);
      const approveTx = await this.larToken.approve(
        CONTRACT_ADDRESSES.LENDING_AND_BORROWING,
        larAmount
      );
      await approveTx.wait();

      const tx = await this.lendingContract.withdraw(tokenAddress, amount);
      return await tx.wait();
    } catch (error) {
      console.error('Error in withdraw:', error);
      throw error;
    }
  }

  // Read functions
  async getLenders() {
    return await this.lendingContract.getLendersArray();
  }

  async getBorrowers() {
    return await this.lendingContract.getBorrowersArray();
  }

  async getTokensForLending() {
    return await this.lendingContract.getTokensForLendingArray();
  }

  async getTokensForBorrowing() {
    return await this.lendingContract.getTokensForBorrowingArray();
  }

  async getUserTotalAmountAvailableForBorrow(userAddress: string) {
    return await this.lendingContract.getUserTotalAmountAvailableForBorrowInDollars(userAddress);
  }

  async getTokenAvailableToWithdraw(userAddress: string) {
    return await this.lendingContract.getTokenAvailableToWithdraw(userAddress);
  }
} 