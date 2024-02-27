//
//  Response.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/13/22.
//

import Foundation

public enum ResponseContent: UnencryptedContent {
    case response(requestId: UUID, values: [Value])
    case failure(requestId: UUID, description: String)
    
    public enum Value: Codable {
        case result(value: JSONString)
        case error(code: Int, message: String)
    }
    
    var requestId: UUID {
        switch self {
        case .response(let requestId, _),
             .failure(let requestId, _):
            return requestId
        }
    }
}

public typealias ResponseMessage = Message<ResponseContent>
