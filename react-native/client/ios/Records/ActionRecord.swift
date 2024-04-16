import ExpoModulesCore
import CoinbaseWalletSDK
import Foundation

struct ActionRecord : Record {
    @Field
    var method: String

    @Field
    var paramsJson: String

    @Field
    var optional: Bool
}

extension ActionRecord {
    var asAction: Action {
        let paramsJson = self.paramsJson.data(using: .utf8)!
        let params = try! JSONSerialization.jsonObject(with: paramsJson) as! [String: Any]
        return Action(method: self.method, params: params)
    }
}
