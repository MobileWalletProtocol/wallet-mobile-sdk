package expo.modules.coinbasewalletsdkexpo

import com.coinbase.android.nativesdk.Wallet
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class WalletRecord : Record {
    @Field
    var name: String = ""

    @Field
    var iconUrl: String = ""

    @Field
    var packageName: String = ""

    @Field
    var url: String = ""
}

val Wallet.asRecord: WalletRecord
    get() {
        val record = WalletRecord()
        record.name = name
        record.iconUrl = iconUrl
        record.packageName = packageName
        record.url = url
        return record
    }

val WalletRecord.asWallet: Wallet
    get() = Wallet(name, iconUrl, packageName, url)
