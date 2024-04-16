package expo.modules.coinbasewalletsdkexpo.records

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ConfigParamsRecord : Record {
    @Field
    var callbackURL: String = ""

    @Field
    var hostURL: String? = null

    @Field
    var hostPackageName: String? = null
}