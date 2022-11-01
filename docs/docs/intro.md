---
sidebar_position: 1
---

# Mobile Wallet Protocol (MWP)

MWP is a protocol to allow mobile web3 apps to interact with wallet apps and access users' web3 accounts. 
- Secure: It provides an encrypted P2P communication channel between client and server (wallet host) to exchange discrete stateless messages.
- Simple: The messages sent by the client app are called requests and the ones returned by the wallet host are called responses.
- Direct: The protocol uses deep links as its transport layer to let participating apps deliver messages directly to their peer without external entities such as a bridge server.
- Efficient: Reduces the number of hops between client applications and wallet via support for batch requests.
- Reliable: It defines a decentralized verification procedure to check authenticity of each other using well-known URI standard for univeral link without a centralized registry.

## Background

![](https://images.ctfassets.net/c5bd0wqjc7v0/2L8Padm8D0FqNrgkE7lUDh/7460be599006828b8f803e8d4d4ee424/image4.png)

- To use mobile wallets with dapps, communication solutions like WalletLink or WalletConnect have been used, which require bridge servers to pass on dapp’s requests and user’s responses. 
- These protocols were originally designed to deliver messages between entities located on different devices (desktop browser and user’s mobile).
- For mobile use cases, where both app and wallet are within a single device, repurposing the existing solutions would be inefficient and moreover introduce reliability issues as they rely on a connection to an external server via web sockets.

## Network layer

Deep linking through universal links on iOS and app links on Android.
(Intent on android.)

## Message format

- JSON -> JSON with encrypted ‘content’ -> Base64 encoded -> deep link URL
- Base64 encoded string of JSON object
- Content of message prop is encrypted using the access token so that only the wallet can read
- Allow client to make batched requests

### Example

#### handshake
- URL
`https://go.cb-w.com/wsegue?p=eyJ2ZXJzaW9uIjoiMS4yLjMiLCJzZW5kZXIiOiI0UG9QTEFDUjNCb0VxWTJBdSthamRISGRSZStvU0ZaUVwvSkpDU091bHpTYz0iLCJjb250ZW50Ijp7ImhhbmRzaGFrZSI6eyJhcHBJZCI6ImNvbS5teWFwcC5wYWNrYWdlLmlkIiwiY2FsbGJhY2siOiJodHRwczpcL1wvbXlhcHAueHl6XC9uYXRpdmUtc2RrIiwiaW5pdGlhbEFjdGlvbnMiOlt7Im1ldGhvZCI6ImV0aF9zb21lTWV0aG9kIiwicGFyYW1zIjpbInBhcmFtMSIsInBhcmFtMiJdfV19fSwidXVpZCI6IjExMUYzRTI2LTE2N0YtNEJGNS1BQzM4LTZEOTNBNjU2RTMyQiJ9`
- JSON (decoded the URL above. handshake messages are not encrypted)
```json
{
  "version" : "0.1.0",
  "sender" : "bwf9U+VbjmvfBr3p3aoJyOEKS6mq7sSrg56V6FDYMBs=",
  "content" : {
    "handshake" : {
      "appId" : "com.coinbase.NativeWeb3App",
      "callback" : "https:\/\/myapp.xyz\/mycallback",
      "initialActions" : [
        {
          "paramsJson" : "{}",
          "method" : "eth_requestAccounts",
          "optional" : false
        },
        {
          "paramsJson" : "{\"fromAddress\":\"\",\"data\":\"bWVzc2FnZQ==\"}",
          "method" : "personal_sign",
          "optional" : false
        }
      ]
    }
  },
  "uuid" : "634A5C15-0316-4FD1-86FB-4818DBD6C12D"
}
```

#### request
- URL
`https://go.cb-w.com/wsegue?p=eyJ2ZXJzaW9uIjoiMS4yLjMiLCJzZW5kZXIiOiJmbW5IZVh3OTNlY000QnFzSXpRTk5zb2FvS0ZxK3NOMHZRaWdvaVNQZ2dvPSIsImNvbnRlbnQiOnsicmVxdWVzdCI6eyJfMCI6IkdQYUwwTWJjbVhoVWU5eUprY0p5dnRJWVJUM3RXNEhcL1lBUmNKTXZGZlZWOWh6OXcya1h3YmxIMEJPcFN2UXI0RVhoV0FVUlwvZGFwWUVMZ2lvTkFXY3IxVlwvY1JoNDVUaFN2SFV1cHRlY0lJR0tLeGxKTWdwZ2RiMWNJRWhNWEdpVElBYkZTblJTOVlwOFowOHJcL3pkcjlBVytFQjRXSXBLcnhTTmVqQXRRTDJWTDByRWE2YzhvM0lodG5DQ1U1SzRpaVVZcTJkamd0eGRJZm1FbmhrTUFCQVwvSm5INFpBPT0ifX0sInV1aWQiOiJEMzg3MUYwRS03QkNFLTQxMjYtQjY1Ny05QjlGOEQ1NEU3N0YifQ%3D%3D`
- encrypted JSON (decoded from the URL above)
```json
{
  "version": "1.2.3",
  "sender": "oEC2AZndVwTcLs3ixQyxThlHrKBNdBczbWp9OjeglGY=",
  "content": {
    "request": {
      "data": "/LzMCiGCpiYuUHp2vdlQM4V+f7hYygKI2qhX/ZWuFA6/aqZ/bmnWhROK14vtBH3sbrROqfefMXue3rbqLOg1s+xzh6iXoVavhIeCSevugp1ZlERG9q+CSuLXyRR3tou6wdsJ60jOTDjGzLCvcHp2ykglfDUr2qaVRo3i/RXsJRoPrW9CurSM9+TmNZ46aq1Y/K8lBcpq1aFUYSn7+kHHR8xBY+QoPE0yox+dZrvSi7Z16fX3uwZ3NQPmhPqQXpDFEHrZeKEzoIZAPA8NUlrajgY/1mxhbkH9tmM8X5vSG7w="
    }
  },
  "uuid": "3E445386-8CB3-4995-99EC-DCF06A60081C"
}
```
- decrypted JSON (to pass via RN - native bridge)
```json
{
  "version": "1.2.3",
  "sender": "qSAE/fvQ1cnZvVnKDjiHRyzK6bVQ/qJ7W29DL2aMjns=",
  "content": {
    "request": {
      "actions": [
        {
          "paramsJson" : "{}",
          "method" : "eth_requestAccounts",
          "optional" : false
        },
        {
          "paramsJson" : "{\"fromAddress\":\"\",\"data\":\"bWVzc2FnZQ==\"}",
          "method" : "personal_sign",
          "optional" : false
        }
      ],
      "account": {
        "chain": "eth",
        "networkId": 17,
        "address": "0x12345678ABCD"
      }
    }
  },
  "uuid": "853BFBB5-A6F1-4FBA-B8C6-DC2BE3CCF6DF"
}
```

#### response
- plain response JSON (to pass via RN - native bridge)
```json
{
  "version": "7.13.1",
  "sender": "u9IB3p8tN8P4U2LvYfaCphd8/bXRN34eTnuQPO4g6zQ=",
  "content": {
    "response": {
      "requestId": "9D34C731-397B-473B-9850-C6F0261BC085",
      "values": [
        {
          "result": {
            "value": "return value 1"
          }
        },
        {
          "result": {
            "value": "return value 2"
          }
        },
        {
          "error": {
            "message": "error 1",
            "code": 1
          }
        },
        {
          "error": {
            "message": "error 2",
            "code": 2
          }
        }
      ]
    }
  },
  "uuid": "C5CDDCF7-7A31-4185-BB6B-7A3B8F9B19BA"
}
```
- encrypted JSON (encrypted the JSON object above)
```json
{
  "version": "7.13.1",
  "sender": "u9IB3p8tN8P4U2LvYfaCphd8/bXRN34eTnuQPO4g6zQ=",
  "content": {
    "response": {
      "requestId": "9D34C731-397B-473B-9850-C6F0261BC085",
      "data": "uXqgB78alErYBFXie8gP397igJ18dx+mcQcUV7K44W+96OQxNxJGm3WxEgsGMxeS8Wg1wiiRaXYRghFbwlnJuOLNpIvAiQYMOzJ1IAlFg452hwG7PrCCn6e9/xU5Hc+kzZYio355zSxSuXByo1bItCgNdjp5aocX1kUnZceV7dGjIGv66/z1k93hxGYooH0uCeI2wQ7qaZzJKfUJLgO0NFmj1fbTciv7CoVd8/mQAfHzlgaIhkHB+j4mAw=="
    }
  },
  "uuid": "C5CDDCF7-7A31-4185-BB6B-7A3B8F9B19BA"
}
```
- URL
`https://myapp.xyz/native-sdk?p=eyJ2ZXJzaW9uIjoiNy4xMy4xIiwic2VuZGVyIjoidTlJQjNwOHROOFA0VTJMdllmYUNwaGQ4XC9iWFJOMzRlVG51UVBPNGc2elE9IiwiY29udGVudCI6eyJyZXNwb25zZSI6eyJyZXF1ZXN0SWQiOiI5RDM0QzczMS0zOTdCLTQ3M0ItOTg1MC1DNkYwMjYxQkMwODUiLCJkYXRhIjoidVhxZ0I3OGFsRXJZQkZYaWU4Z1AzOTdpZ0oxOGR4K21jUWNVVjdLNDRXKzk2T1F4TnhKR20zV3hFZ3NHTXhlUzhXZzF3aWlSYVhZUmdoRmJ3bG5KdU9MTnBJdkFpUVlNT3pKMUlBbEZnNDUyaHdHN1ByQ0NuNmU5XC94VTVIYytrelpZaW8zNTV6U3hTdVhCeW8xYkl0Q2dOZGpwNWFvY1gxa1VuWmNlVjdkR2pJR3Y2NlwvejFrOTNoeEdZb29IMHVDZUkyd1E3cWFaekpLZlVKTGdPME5GbWoxZmJUY2l2N0NvVmQ4XC9tUUFmSHpsZ2FJaGtIQitqNG1Bdz09In19LCJ1dWlkIjoiQzVDRERDRjctN0EzMS00MTg1LUJCNkItN0EzQjhGOUIxOUJBIn0%3D`

#### error
- JSON (error messages are not encrypted)
```json
{
  "version": "7.13.1",
  "sender": "OzXg53x+wwIW1YCEbvP3sya7MmZT5yCQcArK3GbLmDo=",
  "content": {
    "failure": {
      "requestId": "6C7706C2-B17F-4E96-8D52-C6876C09AECB",
      "description": "error message from host"
    }
  },
  "uuid": "C6900BD5-25EE-46F4-AB01-EBB8FAB1AC76"
}
```
- URL
`https://myapp.xyz/native-sdk?p=eyJ2ZXJzaW9uIjoiNy4xMy4xIiwic2VuZGVyIjoiT3pYZzUzeCt3d0lXMVlDRWJ2UDNzeWE3TW1aVDV5Q1FjQXJLM0diTG1Ebz0iLCJjb250ZW50Ijp7ImZhaWx1cmUiOnsicmVxdWVzdElkIjoiNkM3NzA2QzItQjE3Ri00RTk2LThENTItQzY4NzZDMDlBRUNCIiwiZGVzY3JpcHRpb24iOiJlcnJvciBtZXNzYWdlIGZyb20gaG9zdCJ9fSwidXVpZCI6IkM2OTAwQkQ1LTI1RUUtNDZGNC1BQjAxLUVCQjhGQUIxQUM3NiJ9`

## Encryption

- [Diffie–Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange)
- client and wallet generate its own key pair for each session and derive shared key with peer’s public key
- For pairing (handshake) process: public key encryption to grant access token visible only to the caller
- After successful handshake: access token itself is the shared key to encrypt all messages between the client and the wallet for secure communication

## Authentication

- Decentralized verification of participating apps’ authenticity using [.well-known](https://en.wikipedia.org/wiki/Well-known_URI) data without centralized registry
- apple-app-site-association 
- [assetlinks.json](https://developer.android.com/training/app-links/verify-site-associations )
- 3rd party client apps make requests to the wallet through universal links, whose authenticity is verified by the OS.
- Wallet sends responses through universal links as well.
- Application ID passed by caller should match the information on their domain.

## Handshake

- Host wallet verifies the client app
    - well-known data for universal link configuration
- Fetch metadata of the app such as app’s name and icon image url 
- Show UI (e.g. user confirmation popup) to get user’s approval
- Generate a key pair for session

## App metadata

- This protocol only asks client apps to pass their application id.
- Then it loads metadata from the iOS App Store / Android package manager.

## Batched request

- allow client apps to make multiple requests at once 
- to improve UX by minimizing app switching
- Currently, CB wallet opens pop-ups sequentially to get user’s approval until the user signs all the actions requests or denies to sign any required action

## Action
- Request can have multiple actions
- Each action defines a single json rpc call with parameters
- Response has multiple ActionResult 

## Multi-chain support
- Follow [CAIP-10](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-10.md) standard, to identify an account in any blockchain specified by CAIP-2 blockchain id
- The account id specification will be prefixed with the CAIP-2 blockchain ID and delimited with a colon sign (:)
- Syntax
    - The account_id is a case-sensitive string in the form
    - account_id: chain_id + ":" + account_address
    - chain_id: [-a-z0-9]{3,8}:[-a-zA-Z0-9]{1,32}
    - account_address: [a-zA-Z0-9]{1,64}
- Semantics
    - The chain_id is specified by the CAIP-2 which describes the blockchain id. The account_address is a case sensitive string which its format is specific to the blockchain that is referred to by the chain_id
- Example:  
eip155:1:0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb
