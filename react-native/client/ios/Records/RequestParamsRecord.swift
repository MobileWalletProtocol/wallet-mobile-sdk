import ExpoModulesCore
import Foundation

struct RequestParamsRecord : Record {
    @Field
    var actions: [ActionRecord]

    @Field
    var account: AccountRecord?
}
