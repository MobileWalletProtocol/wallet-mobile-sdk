import {
  RequestArguments,
  Web3Provider,
} from "@coinbase/wallet-sdk/dist/provider/Web3Provider";
import {
  JSONRPCMethod,
  JSONRPCRequest,
  JSONRPCResponse,
} from "@coinbase/wallet-sdk/dist/provider/JSONRPC";
import {
  AddressString,
  Callback,
  IntNumber,
} from "@coinbase/wallet-sdk/dist/types";
import { ethErrors } from "eth-rpc-errors";
import {
  initiateHandshake,
  isConnected,
  makeRequest,
  resetSession,
} from "./CoinbaseWalletSDK";
import { Action, Result } from "./CoinbaseWalletSDK.types";
import {
  bigIntStringFromBN,
  ensureAddressString,
  ensureBN,
  ensureBuffer,
  ensureIntNumber,
  ensureParsedJSONObject,
  hexStringFromBuffer,
  prepend0x,
} from "@coinbase/wallet-sdk/dist/util";
import { EthereumTransactionParams } from "@coinbase/wallet-sdk/dist/relay/EthereumTransactionParams";
import BN from "bn.js";
import { MMKV, NativeMMKV } from "react-native-mmkv";
import SafeEventEmitter from "@metamask/safe-event-emitter";

global.Buffer = global.Buffer || require("buffer").Buffer;

const CACHED_ADDRESSES_KEY = "mobile_sdk.addresses";
const CHAIN_ID_KEY = "mobile_sdk.chain_id";

export interface WalletMobileSDKProviderOptions {
  chainId?: number;
  storage?: KVStorage;
  jsonRpcUrl?: string;
}

export interface KVStorage
  extends Pick<NativeMMKV, "set" | "getString" | "delete"> {}

interface AddEthereumChainParams {
  chainId: string;
  blockExplorerUrls?: string[];
  chainName?: string;
  iconUrls?: string[];
  rpcUrls?: string[];
  nativeCurrency?: {
    name: string;
    symbol: string;
    decimals: number;
  };
}

interface SwitchEthereumChainParams {
  chainId: string;
}

interface WatchAssetParams {
  type: string;
  options: {
    address: string;
    symbol?: string;
    decimals?: number;
    image?: string;
  };
}

export class WalletMobileSDKEVMProvider
  extends SafeEventEmitter
  implements Web3Provider
{
  private _chainId?: number;
  private _jsonRpcUrl?: string;
  private _addresses: AddressString[] = [];
  private _storage: KVStorage;

  constructor(opts?: WalletMobileSDKProviderOptions) {
    super();

    this.send = this.send.bind(this);
    this.sendAsync = this.sendAsync.bind(this);
    this.request = this.request.bind(this);

    this._storage = opts?.storage ?? new MMKV({ id: "mobile_sdk.store" });
    this._chainId = opts?.chainId;
    this._jsonRpcUrl = opts?.jsonRpcUrl;

    const chainId = this._chainId ?? this._getChainId();
    const chainIdStr = prepend0x(chainId.toString(16));
    this.emit("connect", { chainId: chainIdStr });

    const cachedAddresses = this._storage.getString(CACHED_ADDRESSES_KEY);
    if (cachedAddresses) {
      const addresses = cachedAddresses.split(" ") as AddressString[];
      if (addresses[0] && addresses[0] !== "") {
        this._setAddresses(addresses);
      }
    }
  }

  public get host(): string {
    if (this._jsonRpcUrl) {
      return this._jsonRpcUrl;
    } else {
      throw new Error("No jsonRpcUrl provided");
    }
  }

  public get connected(): boolean {
    return isConnected();
  }

  public get chainId(): string {
    return prepend0x(this._getChainId().toString(16));
  }

  public supportsSubscriptions(): boolean {
    return false;
  }

  public disconnect(): boolean {
    resetSession();
    this._addresses = [];
    this._storage.delete(CACHED_ADDRESSES_KEY);
    return true;
  }

  private _send = this.send.bind(this);
  private _sendAsync = this.sendAsync.bind(this);

  public send(request: JSONRPCRequest): JSONRPCResponse;
  public send(request: JSONRPCRequest[]): JSONRPCResponse[];
  public send(
    request: JSONRPCRequest,
    callback: Callback<JSONRPCResponse>
  ): void;
  public send(
    request: JSONRPCRequest[],
    callback: Callback<JSONRPCResponse[]>
  ): void;
  public send<T = any>(method: string, params?: any[] | any): Promise<T>;
  public send(
    requestOrMethod: JSONRPCRequest | JSONRPCRequest[] | string,
    callbackOrParams?:
      | Callback<JSONRPCResponse>
      | Callback<JSONRPCResponse[]>
      | any[]
      | any
  ): JSONRPCResponse | JSONRPCResponse[] | void | Promise<any> {
    // send<T>(method, params): Promise<T>
    if (typeof requestOrMethod === "string") {
      const method = requestOrMethod;
      const params = Array.isArray(callbackOrParams)
        ? callbackOrParams
        : callbackOrParams !== undefined
        ? [callbackOrParams]
        : [];
      const request: JSONRPCRequest = {
        jsonrpc: "2.0",
        id: 0,
        method,
        params,
      };
      return this._sendRequestAsync(request).then((res) => res.result);
    }

    // send(JSONRPCRequest | JSONRPCRequest[], callback): void
    if (typeof callbackOrParams === "function") {
      const request = requestOrMethod as any;
      const callback = callbackOrParams;
      return this._sendAsync(request, callback);
    }

    // send(JSONRPCRequest[]): JSONRPCResponse[]
    if (Array.isArray(requestOrMethod)) {
      const requests = requestOrMethod;
      return requests.map((r) => this._sendRequest(r));
    }

    // send(JSONRPCRequest): JSONRPCResponse
    const req: JSONRPCRequest = requestOrMethod;
    return this._sendRequest(req);
  }

  public sendAsync(
    request: JSONRPCRequest,
    callback: Callback<JSONRPCResponse>
  ): void;
  public sendAsync(
    request: JSONRPCRequest[],
    callback: Callback<JSONRPCResponse[]>
  ): void;
  public async sendAsync(
    request: JSONRPCRequest | JSONRPCRequest[],
    callback: Callback<JSONRPCResponse> | Callback<JSONRPCResponse[]>
  ): Promise<void> {
    if (typeof callback !== "function") {
      throw new Error("callback is required");
    }

    // send(JSONRPCRequest[], callback): void
    if (Array.isArray(request)) {
      const arrayCb = callback as Callback<JSONRPCResponse[]>;
      this._sendMultipleRequestsAsync(request)
        .then((responses) => arrayCb(null, responses))
        .catch((err) => arrayCb(err, null));
      return;
    }

    // send(JSONRPCRequest, callback): void
    const cb = callback as Callback<JSONRPCResponse>;
    return this._sendRequestAsync(request)
      .then((response) => cb(null, response))
      .catch((err) => cb(err, null));
  }

  // request
  public async request<T>(args: RequestArguments): Promise<T> {
    if (!args || typeof args !== "object" || Array.isArray(args)) {
      throw ethErrors.rpc.invalidRequest({
        message: "Expected a single, non-array, object argument.",
        data: args,
      });
    }

    const { method, params } = args;

    if (typeof method !== "string" || method.length === 0) {
      throw ethErrors.rpc.invalidRequest({
        message: "'args.method' must be a non-empty string.",
        data: args,
      });
    }

    if (
      params !== undefined &&
      !Array.isArray(params) &&
      (typeof params !== "object" || params === null)
    ) {
      throw ethErrors.rpc.invalidRequest({
        message: "'args.params' must be an object or array if provided.",
        data: args,
      });
    }

    const newParams = params === undefined ? [] : params;

    const id = 0;
    const result = await this._sendRequestAsync({
      method,
      params: newParams,
      jsonrpc: "2.0",
      id,
    });

    return result.result as T;
  }

  private _sendRequest(request: JSONRPCRequest): JSONRPCResponse {
    throw new Error(`Unsupported synchronous method: ${request.method}`);
  }

  private _sendMultipleRequestsAsync(
    requests: JSONRPCRequest[]
  ): Promise<JSONRPCResponse[]> {
    return Promise.all(requests.map((r) => this._sendRequestAsync(r))); // TODO: Request batching
  }

  private _sendRequestAsync(request: JSONRPCRequest): Promise<JSONRPCResponse> {
    const method = request.method;
    const params = request.params || [];

    return new Promise<JSONRPCResponse>((resolve, reject) => {
      switch (method) {
        case JSONRPCMethod.eth_requestAccounts:
          this._eth_requestAccounts()
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.personal_sign:
          this._personal_sign(params)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.eth_signTypedData_v3:
          this._eth_signTypedData(params, "v3")
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.eth_signTypedData_v4:
          this._eth_signTypedData(params, "v4")
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.eth_signTransaction:
          this._eth_signTransaction(params, false)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.eth_sendTransaction:
          this._eth_signTransaction(params, true)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.wallet_switchEthereumChain:
          this._wallet_switchEthereumChain(params)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.wallet_addEthereumChain:
          this._wallet_addEthereumChain(params)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        case JSONRPCMethod.wallet_watchAsset:
          this._wallet_watchAsset(params)
            .then((res) => resolve(res))
            .catch((err) => reject(err));
          break;
        default:
          if (this._jsonRpcUrl) {
            this._makeEthereumJsonRpcRequest(request, this._jsonRpcUrl)
              .then((res) => resolve(res))
              .catch((err) => reject(err));
          } else {
            reject(
              ethErrors.provider.unsupportedMethod({
                message: `Unsupported method: ${method}`,
              })
            );
          }
      }
    });
  }

  private async _eth_requestAccounts(): Promise<JSONRPCResponse> {
    const action: Action = {
      method: JSONRPCMethod.eth_requestAccounts,
      params: {},
    };

    const res = await this._makeHandshakeRequest(action);
    if (res.result) {
      const resultJSON = JSON.parse(res.result);
      this._setAddresses([resultJSON.address]);
      return {
        jsonrpc: "2.0",
        id: 0,
        result: [resultJSON.address],
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private async _personal_sign(params: unknown[]): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const message = ensureBuffer(params[0]);
    const address = ensureAddressString(params[1]);

    const action: Action = {
      method: JSONRPCMethod.personal_sign,
      params: {
        message,
        address,
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result) {
      return {
        jsonrpc: "2.0",
        id: 0,
        result: res.result,
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private async _eth_signTypedData(
    params: unknown[],
    type: "v3" | "v4"
  ): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const address = ensureAddressString(params[0]);
    const typedDataJson = JSON.stringify(ensureParsedJSONObject(params[1]));

    const action: Action = {
      method:
        type === "v3"
          ? JSONRPCMethod.eth_signTypedData_v3
          : JSONRPCMethod.eth_signTypedData_v4,
      params: {
        address,
        typedDataJson,
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result) {
      return {
        jsonrpc: "2.0",
        id: 0,
        result: res.result,
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private async _eth_signTransaction(
    params: unknown[],
    shouldSubmit: boolean
  ): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const tx = this._prepareTransactionParams((params[0] as any) || {});
    const action: Action = {
      method: shouldSubmit
        ? JSONRPCMethod.eth_sendTransaction
        : JSONRPCMethod.eth_signTransaction,
      params: {
        fromAddress: tx.fromAddress,
        toAddress: tx.toAddress,
        weiValue: bigIntStringFromBN(tx.weiValue),
        data: hexStringFromBuffer(tx.data),
        nonce: tx.nonce,
        gasPriceInWei: tx.gasPriceInWei
          ? bigIntStringFromBN(tx.gasPriceInWei)
          : null,
        maxFeePerGas: tx.maxFeePerGas
          ? bigIntStringFromBN(tx.maxFeePerGas)
          : null,
        maxPriorityFeePerGas: tx.maxPriorityFeePerGas
          ? bigIntStringFromBN(tx.maxPriorityFeePerGas)
          : null,
        gasLimit: tx.gasLimit ? bigIntStringFromBN(tx.gasLimit) : null,
        chainId: tx.chainId,
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result) {
      return {
        jsonrpc: "2.0",
        id: 0,
        result: res.result,
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private _prepareTransactionParams(tx: {
    from?: unknown;
    to?: unknown;
    gasPrice?: unknown;
    maxFeePerGas?: unknown;
    maxPriorityFeePerGas?: unknown;
    gas?: unknown;
    value?: unknown;
    data?: unknown;
    nonce?: unknown;
  }): EthereumTransactionParams {
    const fromAddress = tx.from ? ensureAddressString(tx.from) : null;
    if (!fromAddress) {
      throw new Error("Ethereum address is unavailable");
    }

    const toAddress = tx.to ? ensureAddressString(tx.to) : null;
    const weiValue = tx.value != null ? ensureBN(tx.value) : new BN(0);
    const data = tx.data ? ensureBuffer(tx.data) : Buffer.alloc(0);
    const nonce = tx.nonce != null ? ensureIntNumber(tx.nonce) : null;
    const gasPriceInWei = tx.gasPrice != null ? ensureBN(tx.gasPrice) : null;
    const maxFeePerGas =
      tx.maxFeePerGas != null ? ensureBN(tx.maxFeePerGas) : null;
    const maxPriorityFeePerGas =
      tx.maxPriorityFeePerGas != null
        ? ensureBN(tx.maxPriorityFeePerGas)
        : null;
    const gasLimit = tx.gas != null ? ensureBN(tx.gas) : null;
    const chainId = this._chainId
      ? IntNumber(this._chainId)
      : this._getChainId();

    return {
      fromAddress,
      toAddress,
      weiValue,
      data,
      nonce,
      gasPriceInWei,
      maxFeePerGas,
      maxPriorityFeePerGas,
      gasLimit,
      chainId,
    };
  }

  private async _wallet_switchEthereumChain(
    params: unknown[]
  ): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const request = params[0] as SwitchEthereumChainParams;
    const chainId = parseInt(request.chainId, 16);

    const successResponse: JSONRPCResponse = {
      jsonrpc: "2.0",
      id: 0,
      result: null,
    };

    if (ensureIntNumber(chainId) === this._getChainId()) {
      return successResponse;
    }

    const action: Action = {
      method: JSONRPCMethod.wallet_switchEthereumChain,
      params: {
        chainId: chainId.toString(),
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result) {
      this._updateChainId(chainId);
      return successResponse;
    } else {
      throw ethErrors.provider.custom({
        code: res.errorCode ?? 1000,
        message: res.errorMessage ?? "",
      });
    }
  }

  private async _wallet_addEthereumChain(
    params: unknown[]
  ): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const request = params[0] as AddEthereumChainParams;

    if (!request.rpcUrls || request.rpcUrls?.length === 0) {
      throw ethErrors.rpc.invalidParams({
        message: "please pass in at least 1 rpcUrl",
      });
    }

    if (!request.chainName || request.chainName.trim() === "") {
      throw ethErrors.rpc.invalidParams({
        message: "chainName is a required field",
      });
    }

    if (!request.nativeCurrency) {
      throw ethErrors.rpc.invalidParams({
        message: "nativeCurrency is a required field",
      });
    }

    const chainIdNumber = parseInt(request.chainId, 16);

    const action: Action = {
      method: JSONRPCMethod.wallet_addEthereumChain,
      params: {
        chainId: chainIdNumber.toString(),
        blockExplorerUrls: request.blockExplorerUrls ?? null,
        chainName: request.chainName ?? null,
        iconUrls: request.iconUrls ?? null,
        nativeCurrency: request.nativeCurrency ?? null,
        rpcUrls: request.rpcUrls ?? [],
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result && res.result === "true") {
      return {
        jsonrpc: "2.0",
        id: 0,
        result: null,
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private async _wallet_watchAsset(params: unknown): Promise<JSONRPCResponse> {
    this._requireAuthorization();
    const request = (
      Array.isArray(params) ? params[0] : params
    ) as WatchAssetParams;

    if (!request.type) {
      throw ethErrors.rpc.invalidParams({
        message: "Type is required",
      });
    }

    if (request?.type !== "ERC20") {
      throw ethErrors.rpc.invalidParams({
        message: `Asset of type '${request.type}' is not supported`,
      });
    }

    if (!request?.options) {
      throw ethErrors.rpc.invalidParams({
        message: "Options are required",
      });
    }

    if (!request?.options.address) {
      throw ethErrors.rpc.invalidParams({
        message: "Address is required",
      });
    }

    const { address, symbol, image, decimals } = request.options;

    const action: Action = {
      method: JSONRPCMethod.wallet_watchAsset,
      params: {
        type: request.type,
        options: {
          address,
          symbol: symbol ?? null,
          decimals: decimals ?? null,
          image: image ?? null,
        },
      },
    };

    const res = await this._makeSDKRequest(action);
    if (res.result) {
      return {
        jsonrpc: "2.0",
        id: 0,
        result: res.result === "true",
      };
    } else {
      throw this._getProviderError(res);
    }
  }

  private async _makeEthereumJsonRpcRequest(
    request: JSONRPCRequest,
    jsonRpcUrl: string
  ): Promise<JSONRPCResponse> {
    return fetch(jsonRpcUrl, {
      method: "POST",
      body: JSON.stringify(request),
      mode: "cors",
      headers: { "Content-Type": "application/json" },
    })
      .then((res) => res.json())
      .then((json) => {
        if (!json) {
          throw ethErrors.rpc.parse();
        }

        const response = json as JSONRPCResponse;
        if (response.error) {
          throw ethErrors.provider.custom(response.error);
        }

        return response;
      });
  }

  private async _makeHandshakeRequest(action: Action) {
    try {
      const [res] = await initiateHandshake([action]);
      if (res.errorMessage) {
        throw this._getProviderError(res);
      }
      return res;
    } catch (error) {
      if (error.message.match(/(session not found|session expired)/i)) {
        this.disconnect();
        throw ethErrors.provider.disconnected(error.message);
      }

      if (error.message.match(/(denied|rejected)/i)) {
        throw ethErrors.provider.userRejectedRequest();
      }

      throw error;
    }
  }

  private async _makeSDKRequest(action: Action) {
    try {
      const [res] = await makeRequest([action]);
      if (res.errorMessage) {
        throw this._getProviderError(res);
      }
      return res;
    } catch (error) {
      if (error.message.match(/(session not found|session expired)/i)) {
        this.disconnect();
        throw ethErrors.provider.disconnected(error.message);
      }

      if (error.message.match(/(denied|rejected)/i)) {
        throw ethErrors.provider.userRejectedRequest();
      }

      throw error;
    }
  }

  private _getProviderError(result: Result) {
    const errorMessage = result.errorMessage ?? "";
    if (errorMessage.match(/(denied|rejected)/i)) {
      return ethErrors.provider.userRejectedRequest();
    } else {
      return ethErrors.provider.custom({
        code: result.errorCode ?? 1000,
        message: errorMessage,
      });
    }
  }

  private _getChainId(): IntNumber {
    const chainIdStr = this._storage.getString(CHAIN_ID_KEY) || "1";
    const chainId = parseInt(chainIdStr, 10);
    return ensureIntNumber(chainId);
  }

  private _updateChainId(chainId: number) {
    const originalChainId = this._getChainId();
    this._storage.set(CHAIN_ID_KEY, chainId.toString(10));
    const chainChanged = ensureIntNumber(chainId) !== originalChainId;
    if (chainChanged) {
      this.emit("chainChanged", prepend0x(this._getChainId().toString(16)));
    }
  }

  private _setAddresses(addresses: string[]) {
    const newAddresses = addresses.map((address) =>
      ensureAddressString(address)
    );

    if (JSON.stringify(this._addresses) === JSON.stringify(newAddresses)) {
      return;
    }

    this._addresses = newAddresses;
    this._storage.set(CACHED_ADDRESSES_KEY, newAddresses.join(" "));
    this.emit("accountsChanged", this._addresses);
  }

  private _requireAuthorization() {
    if (!this.connected) {
      throw ethErrors.provider.unauthorized();
    }
  }
}
