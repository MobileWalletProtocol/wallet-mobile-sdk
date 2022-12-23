package expo.modules.coinbasewalletsdkexpo.records

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class RequestParamsRecord : Record {
    @Field
    var wallet: WalletRecord = WalletRecord()

    @Field
    var request: RequestRecord = RequestRecord()
}