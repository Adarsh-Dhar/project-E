export interface Token {
  tokenAddress: string;
  LTV: number;
  stableRate: number;
  name: string;
}

export interface LendingState {
  lenders: string[];
  borrowers: string[];
  tokensForLending: Token[];
  tokensForBorrowing: Token[];
}

export interface TransactionResponse {
  hash: string;
  wait: () => Promise<TransactionReceipt>;
}

export interface TransactionReceipt {
  status: number;
  blockNumber: number;
  transactionHash: string;
} 