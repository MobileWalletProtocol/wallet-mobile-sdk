//
//  ReturnValue.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/24/22.
//

import Foundation

@available(iOS 13.0, *)
public typealias ResponseResult = Result<BaseMessage<[JSONStringResult]>, Error>

@available(iOS 13.0, *)
extension ResponseContent.Value {
    var asJSONStringResult: JSONStringResult {
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
            let results: [JSONStringResult] = values.map { $0.asJSONStringResult }
            return .success(
                BaseMessage<[JSONStringResult]>.copy(self, replaceContentWith: results)
            )
        case .failure(_, let description):
            return .failure(CoinbaseWalletSDK.Error.walletReturnedError(description))
        }
    }
}
