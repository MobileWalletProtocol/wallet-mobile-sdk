package expo.modules.coinbasewalletsdkexpo.records

import com.coinbase.android.nativesdk.message.response.ActionResult
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ActionResultRecord : Record {
    @Field
    var result: String? = null

    @Field
    var errorMessage: String? = null

    @Field
    var errorCode: Int? = null
}

val ActionResult.asRecord: ActionResultRecord
    get() {
        val record = ActionResultRecord()
        when (this) {
            is ActionResult.Result -> record.result = value
            is ActionResult.Error -> {
                record.errorCode = code.toInt()
                record.errorMessage = message
            }
        }

        return record
    }