import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct RequestRecord : Record {
    @Field
    var actions: [ActionRecord]

    @Field
    var account: AccountRecord?
}

extension RequestRecord {
    var asRequest: Request {
        let requestActions: [Action] = self.actions.map { $0.asAction }
        let requestAccount: Account? = self.account?.asAccount
        return Request(actions: requestActions, account: requestAccount)
    }
}
