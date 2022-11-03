# Batched request

- allow client apps to make multiple requests at once 
- to improve UX by minimizing app switching
- Currently, CB wallet opens pop-ups sequentially to get user’s approval until the user signs all the actions requests or denies to sign any required action

## Action
- Request can have multiple actions
- Each action defines a single json rpc call with parameters

## ActionResult
- Response has multiple ActionResult 
