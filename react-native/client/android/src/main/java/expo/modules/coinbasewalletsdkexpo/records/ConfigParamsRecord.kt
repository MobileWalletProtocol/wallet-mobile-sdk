package expo.modules.coinbasewalletsdkexpo.records

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ConfigParamsRecord : Record {
    @Field
    var callbackURL: String = ""

    @Field
    var appID: String? = null

    @Field
    var appName: String? = null

    @Field
    var appIconURL: String? = null
}