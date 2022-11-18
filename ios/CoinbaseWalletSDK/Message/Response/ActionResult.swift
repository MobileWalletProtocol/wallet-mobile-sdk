//
//  ActionResult.swift
//  MobileWalletProtocol
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

@available(iOS 13.0, *)
public typealias ResponseResult = Result<BaseMessage<[ActionResult]>, Error>

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
public typealias ResponseHandler = (ResponseResult) -> Void

@available(iOS 13.0, *)
extension ResponseMessage {
    var result: ResponseResult {
        switch self.content {
        case .response(_, let values):
            let results: [ActionResult] = values.map { $0.asActionResult }
            return .success(
                BaseMessage<[ActionResult]>.copy(self, replaceContentWith: results)
            )
        case .failure(_, let description):
            return .failure(MWPError.walletReturnedError(description))
        }
    }
}
