package expo.modules.coinbasewalletsdkexpo.records

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class HandshakeParamsRecord : Record {
    @Field
    var wallet: WalletRecord = WalletRecord()

    @Field
    var initialActions: List<ActionRecord> = listOf()
}