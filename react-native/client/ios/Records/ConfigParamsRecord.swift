import ExpoModulesCore
import Foundation

struct ConfigParamsRecord : Record {
    @Field
    var callbackURL: String

    @Field
    var appID: String?

    @Field
    var appName: String?

    @Field
    var appIconURL: String?
}
