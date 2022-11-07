# Batch requests

To improve UX by minimizing app switches, 
MWP allows client apps to make requests with multiple actions at once. 
Wallets should return results in a single response message as well.
Client can specify whether each action is required or optional to customize the flow.

## Action
- A `Request` message has an array of `Action`s
- Each `Action` defines a single JSON RPC call with corresponding parameters in JSON format
- `optional` boolean property to tell the host wallet to cancel the request if it fails to process non-optional action.

## ActionResult
- A `Response` message has array of `ActionResult`s
- `ActionResult` can be either
    - success: JSON string
    - failure: error code and message
