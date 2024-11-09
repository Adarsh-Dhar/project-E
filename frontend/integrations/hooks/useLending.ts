import { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { LendingService } from '../LendingService';

export function useLending() {
  const [lendingService, setLendingService] = useState<LendingService | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const initializeLending = async () => {
      try {
        if (typeof window.ethereum !== 'undefined') {
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          await provider.send("eth_requestAccounts", []);
          const service = new LendingService(provider);
          setLendingService(service);
        } else {
          throw new Error('Please install MetaMask!');
        }
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    };

    initializeLending();
  }, []);

  const lend = async (tokenAddress: string, amount: string) => {
    if (!lendingService) throw new Error('Lending service not initialized');
    return await lendingService.lend(tokenAddress, amount);
  };

  const borrow = async (amount: string, tokenAddress: string) => {
    if (!lendingService) throw new Error('Lending service not initialized');
    return await lendingService.borrow(amount, tokenAddress);
  };

  const payDebt = async (tokenAddress: string, amount: string) => {
    if (!lendingService) throw new Error('Lending service not initialized');
    return await lendingService.payDebt(tokenAddress, amount);
  };

  const withdraw = async (tokenAddress: string, amount: string) => {
    if (!lendingService) throw new Error('Lending service not initialized');
    return await lendingService.withdraw(tokenAddress, amount);
  };

  return {
    lendingService,
    loading,
    error,
    lend,
    borrow,
    payDebt,
    withdraw
  };
} 