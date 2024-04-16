package expo.modules.coinbasewalletsdkexpo.records

import com.coinbase.android.nativesdk.message.request.Action
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ActionRecord : Record {
    @Field
    var method: String = ""

    @Field
    var paramsJson: String = "{}"

    @Field
    var optional: Boolean = false
}

val ActionRecord.asAction: Action
    get() {
        return Action(
            method = this.method,
            paramsJson = this.paramsJson,
            optional = this.optional
        )
    }