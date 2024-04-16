import ExpoModulesCore
import Foundation

struct HandshakeParamsRecord : Record {
    @Field
    var initialActions: [ActionRecord]
}
