//
//  SolJSONRPC.swift
//  WalletSegue
//
//  Created by Jungho Bang on 10/26/22.
//

import Foundation

/// TODO: solana support
/// https://docs.solana.com/developing/clients/jsonrpc-api
enum SolJSONRPC: JSONRPC {
    case connect
    
    case signMessage(typedDataJson: JSONString)
    
    case signTransaction(tx: SolTx)
    
    case signAllTransactions(txs: [SolTx])
    
    case signAndSendTransaction(tx: SolTx)
}

struct SolTx: Codable {
    typealias PublicKey = String
    struct Instruction: Codable {
        let data: [UInt8]
        let programId: PublicKey
    }
    
    let instructions: [Instruction]
    let recentBlockhash: String?
    let feePayer: PublicKey?
}
