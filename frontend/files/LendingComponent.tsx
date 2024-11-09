"use client"
import { useState } from 'react';
import { useLending } from '../integrations/hooks/useLending';
import { Input } from "@/components/ui/input"

export function LendingComponent() {
  const { lend, borrow, loading, error } = useLending();
  const [amount, setAmount] = useState('');
  const [tokenAddress, setTokenAddress] = useState('');

  const handleLend = async () => {
    try {
      await lend(tokenAddress, amount);
      // Handle success
    } catch (err) {
      // Handle error
      console.error(err);
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <Input
        type="text"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount"
      />
      <Input
        type="text"
        value={tokenAddress}
        onChange={(e) => setTokenAddress(e.target.value)}
        placeholder="Token Address"
      />
      <button onClick={handleLend}>Lend</button>
    </div>
  );
} 