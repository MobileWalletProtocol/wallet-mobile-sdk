import ExpoModulesCore
import Foundation

struct RequestParamsRecord : Record {
    @Field
    var wallet: WalletRecord

    @Field
    var request: RequestRecord
}
