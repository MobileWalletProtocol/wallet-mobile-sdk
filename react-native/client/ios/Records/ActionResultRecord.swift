import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct ActionResultRecord : Record {
    @Field
    var result: String?

    @Field
    var errorMessage: String?

    @Field
    var errorCode: Int?
}

extension ActionResult {
    var asRecord: ActionResultRecord.Dict {
        let record = ActionResultRecord()

        switch self {
        case .success(let value):
            record.result = value.rawValue
        case .failure(let error):
            record.errorCode = error.code
            record.errorMessage = error.message
        }

        return record.toDictionary()
    }
}
