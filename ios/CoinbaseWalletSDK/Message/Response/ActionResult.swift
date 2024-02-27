//
//  ActionResult.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/24/22.
//

import Foundation

public typealias ActionResult = Result<JSONString, ActionError>
extension ActionResult: BaseContent {}

public struct ActionError: Swift.Error {
    public let code: Int
    public let message: String
}

public typealias ResponseResult = Result<BaseMessage<[ActionResult]>, Error>

extension ResponseContent.Value {
    var asActionResult: ActionResult {
        switch self {
        case let .result(value):
            return .success(value)
        case let .error(code, message):
            return .failure(.init(code: code, message: message))
        }
    }
}

public typealias ResponseHandler = (ResponseResult) -> Void

extension ResponseMessage {
    var result: ResponseResult {
        switch self.content {
        case .response(_, let values):
            let results: [ActionResult] = values.map { $0.asActionResult }
            return .success(
                BaseMessage<[ActionResult]>.copy(self, replaceContentWith: results)
            )
        case .failure(_, let description):
            return .failure(CoinbaseWalletSDK.Error.walletReturnedError(description))
        }
    }
}
