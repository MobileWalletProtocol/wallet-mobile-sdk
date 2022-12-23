import {
  Account,
  Action,
  ConfigurationParams,
  Request,
  Result,
  Wallet,
} from "./types";
import * as MWPModule from "./module/MWPModule";

export class MWPClient {
  static #instances = new Map<Wallet, MWPClient>();

  #wallet: Wallet;

  private constructor(wallet: Wallet) {
    this.#wallet = wallet;
  }

  static configure(params: ConfigurationParams) {
    MWPModule.configure(params);
  }

  static getInstance(wallet: Wallet): MWPClient {
    if (!this.#instances.has(wallet)) {
      this.#instances.set(wallet, new MWPClient(wallet));
    }

    return this.#instances.get(wallet)!;
  }

  static handleResponse(url: URL): boolean {
    return MWPModule.handleResponse(url);
  }

  async initiateHandshake(
    initialActions?: Action[]
  ): Promise<[Result[], Account?]> {
    return MWPModule.initiateHandshake(this.#wallet, initialActions);
  }

  async makeRequest(request: Request): Promise<Result[]> {
    return MWPModule.makeRequest(this.#wallet, request);
  }

  isConnected(): boolean {
    return MWPModule.isWalletConnected(this.#wallet);
  }

  isInstalled(): boolean {
    return MWPModule.isWalletInstalled(this.#wallet);
  }

  resetSession() {
    MWPModule.resetSession(this.#wallet);
  }
}
