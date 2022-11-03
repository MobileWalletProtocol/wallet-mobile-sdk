# Multi-chain support
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
