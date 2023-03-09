package expo.modules.coinbasewalletsdkexpo.records

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class RequestParamsRecord : Record {
    @Field
    var actions: List<ActionRecord> = listOf()

    @Field
    var account: AccountRecord? = null
}