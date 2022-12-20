import { EthereumAction } from "./ethereum";

export type RequestAction = {
  method: string;
  params: Record<string, unknown>;
  optional: boolean;
};

export type EthereumRequestAction = EthereumAction & { optional: boolean };

export type Action = RequestAction | EthereumRequestAction;
