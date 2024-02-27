import ExpoModulesCore
import Foundation

struct ConfigParamsRecord : Record {
    @Field
    var callbackURL: String

    @Field
    var hostURL: String?

    @Field
    var hostPackageName: String?
}
