package expo.modules.coinbasewalletsdkexpo.records

import com.coinbase.android.nativesdk.message.request.Account
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class AccountRecord : Record {
    @Field
    var chain: String = ""

    @Field
    var networkId: Int = 1

    @Field
    var address: String = ""
}

val AccountRecord.asAccount: Account
    get() {
        return Account(
            chain = this.chain,
            networkId = this.networkId.toLong(),
            address = this.address
        )
    }

val Account.asRecord: AccountRecord
    get() {
        val record = AccountRecord()
        record.chain = chain
        record.networkId = networkId.toInt()
        record.address = address
        return record
    }
