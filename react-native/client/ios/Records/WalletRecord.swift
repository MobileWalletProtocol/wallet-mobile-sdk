import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct WalletIdentifierRecord : Record {
    @Field
    var platform: String = "ios"

    @Field
    var mwpScheme: String
}

struct WalletRecord : Record {
    @Field
    var name: String

    @Field
    var iconUrl: String

    @Field
    var url: String

    @Field
    var appStoreUrl: String

    @Field
    var id: WalletIdentifierRecord
}

extension WalletRecord {
    var asWallet: Wallet {
        return Wallet(
            name: self.name,
            iconUrl: URL(string:  self.iconUrl)!,
            url: URL(string: self.url)!,
            mwpScheme: URL(string: self.id.mwpScheme)!,
            appStoreUrl: URL(string: self.appStoreUrl)!
        )
    }
}

extension Wallet {
    var asRecord: WalletRecord.Dict {
        let id = WalletIdentifierRecord()
        id.mwpScheme = self.mwpScheme.absoluteString

        let record = WalletRecord()
        record.name = self.name
        record.iconUrl = self.iconUrl.absoluteString
        record.url = self.url.absoluteString
        record.appStoreUrl = self.appStoreUrl.absoluteString
        record.id = id
        return record.toDictionary()
    }
}
