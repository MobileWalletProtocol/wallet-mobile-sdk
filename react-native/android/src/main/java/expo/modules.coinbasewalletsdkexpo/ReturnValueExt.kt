package expo.modules.coinbasewalletsdkexpo

import com.coinbase.android.nativesdk.message.response.ReturnValue
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ReturnValueRecord : Record {
    @Field
    var result: String? = null

    @Field
    var errorMessage: String? = null

    @Field
    var errorCode: Int? = null
}

val ReturnValue.asRecord: ReturnValueRecord
    get() {
        val record = ReturnValueRecord()
        when (this) {
            is ReturnValue.Result -> record.result = value
            is ReturnValue.Error -> {
                record.errorCode = code.toInt()
                record.errorMessage = message
            }
        }

        return record
    }