import { withBase } from "./base-url";
import { normalizeBalanceData } from "./normalize";
import type { BalanceData, NormalizedBalance } from "./types";
import { parseBalanceData } from "./validation";

export async function loadNormalizedBalance(): Promise<NormalizedBalance> {
  var response = await fetch(withBase("data/balance.json"));
  if (!response.ok) {
    throw new Error("Failed to load balance.json");
  }
  var raw = await response.json();
  var balance = parseBalanceData(raw);
  return normalizeBalanceData(balance);
}

export function validateDraftBalance(value: unknown): BalanceData {
  return parseBalanceData(value);
}

export function serializeBalance(balance: BalanceData): string {
  return JSON.stringify(balance, null, 2) + "\n";
}
