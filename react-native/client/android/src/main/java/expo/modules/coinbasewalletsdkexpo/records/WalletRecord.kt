package expo.modules.coinbasewalletsdkexpo

import com.coinbase.android.nativesdk.Wallet
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class WalletIdentifierRecord : Record {
    @Field
    var platform: String = "android"

    @Field
    var packageName: String = ""
}

class WalletRecord : Record {
    @Field
    var name: String = ""

    @Field
    var iconUrl: String = ""

    @Field
    var url: String = ""

    @Field
    var appStoreUrl: String = ""

    @Field
    var id: WalletIdentifierRecord = WalletIdentifierRecord()

}

val Wallet.asRecord: WalletRecord
    get() {
        val id = WalletIdentifierRecord()
        id.platform = "android"
        id.packageName = this.packageName

        val record = WalletRecord()
        record.name = this.name
        record.iconUrl = this.iconUrl
        record.url = this.url
        record.id = id
        return record
    }

val WalletRecord.asWallet: Wallet
    get() {
        return Wallet(
            name = this.name,
            iconUrl = this.iconUrl,
            url = this.url,
            packageName = this.id.packageName
        )
    }
