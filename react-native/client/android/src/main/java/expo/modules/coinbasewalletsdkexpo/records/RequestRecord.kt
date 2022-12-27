package expo.modules.coinbasewalletsdkexpo.records

import com.coinbase.android.nativesdk.message.request.RequestContent
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class RequestRecord : Record {
    @Field
    var actions: List<ActionRecord> = listOf()

    @Field
    var account: AccountRecord? = null
}

val RequestRecord.asRequest: RequestContent.Request
    get() {
        return RequestContent.Request(
            actions = this.actions.map { it.asAction },
            account = this.account?.asAccount
        )
    }