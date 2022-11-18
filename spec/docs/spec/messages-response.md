# Response content

Response content can be either `response` or `failure`.

## `response`

As long as the host wallet can derive a valid shared secret to decrypt the request from the sender and encrypt the response from itself, 
the return message has `response` as its `content`.

The data of `response` content are encrypted. More details on [encryption](encryption).

### Properties

#### `requestId`
ID of the corresponding request

#### `values`
Array of `value`s. More details on [batch requests](batch).

`Value` can be either:
- `result` of JSON string type
- `error` with `code` and `message`

### Example

coming soon


## `failure`

If the wallet fails to derive a valid shared secret, it returns a unencrypted failure message with following properties:

### Properties

#### `requestId`
ID of the corresponding request

#### `description`
Error description

### Example failure response message
```json
{
  "version": "1.0.3",
  "sender": "lEC/X3K68rlgOoldMdk0D77738Y7W0mDbMMV5R6VyCE=",
  "content": {
    "failure": {
      "requestId": "B78F510E-DD5C-4477-8350-7550FAC7452E",
      "description": "Request denied"
    }
  },
  "timestamp": 689611333.369556,
  "uuid": "E485820B-8F5E-4F8C-9A00-CE5B5B9C6F35"
}
```