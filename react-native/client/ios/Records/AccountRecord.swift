import CoinbaseWalletSDK
import ExpoModulesCore
import Foundation

struct AccountRecord : Record {
    @Field
    var chain: String

    @Field
    var networkId: Int

    @Field
    var address: String
}

extension AccountRecord {
    var asAccount: Account {
        return Account(
            chain: self.chain,
            networkId: UInt(self.networkId),
            address: self.address
        )
    }
}

extension Account {
    var asRecord: AccountRecord.Dict {
        let record = AccountRecord()
        record.chain = self.chain
        record.networkId = Int(self.networkId)
        record.address = self.address

        return record.toDictionary()
    }
}
