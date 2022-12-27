import ExpoModulesCore
import Foundation

struct HandshakeParamsRecord : Record {
    @Field
    var wallet: WalletRecord

    @Field
    var initialActions: [ActionRecord]
}
