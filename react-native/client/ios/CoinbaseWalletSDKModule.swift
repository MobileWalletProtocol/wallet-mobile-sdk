import ExpoModulesCore
import CoinbaseWalletSDK
import Foundation

struct ActionRecord : Record {
    @Field
    var method: String

    @Field
    var paramsJson: String

    @Field
    var optional: Bool
}

struct AccountRecord : Record {
    @Field
    var chain: String

    @Field
    var networkId: Int

    @Field
    var address: String
}

struct ActionResultRecord : Record {
    @Field
    var result: String? = nil

    @Field
    var errorMessage: String? = nil

    @Field
    var errorCode: Int? = nil
}

struct WalletRecord : Record {
    @Field
    var name: String = ""

    @Field
    var iconUrl: String = ""

    @Field
    var url: String = ""

    @Field
    var mwpScheme: String = ""

    @Field
    var appStoreUrl: String = ""

    @Field
    var packageName: String? = nil
}

public class CoinbaseWalletSDKModule: Module {

    var hasConfigured: Bool = false

    private var mwpClient: MWPClient? = nil

    public func definition() -> ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { (callbackURL: String) in
            guard !self.hasConfigured else {
                return
            }

            self.hasConfigured = true
            MWPClient.configure(callback: URL(string: callbackURL)!)
            CoinbaseWalletSDK.appendVersionTag("rn")
        }

        Function("connectWallet") { (walletRecord: WalletRecord) in
            let wallet = Wallet(
                name: walletRecord.name,
                iconUrl: URL(string:  walletRecord.iconUrl)!,
                url: URL(string: walletRecord.url)!,
                mwpScheme: URL(string: walletRecord.mwpScheme)!,
                appStoreUrl: URL(string: walletRecord.appStoreUrl)!
            )
            self.mwpClient = MWPClient.getInstance(to: wallet)
        }

        AsyncFunction("initiateHandshake") { (initialActions: [ActionRecord], promise: Promise) in
            guard let client = self.mwpClient else {
                promise.reject("Client not initialized", "Must Initialize client before making request")
                return
            }

            let actions: [Action] = initialActions.map { record in
                let paramsJson = record.paramsJson.data(using: .utf8)!
                let params = try! JSONSerialization.jsonObject(with: paramsJson) as! [String: Any]
                return Action(method: record.method, params: params)
            }

            client.initiateHandshake(initialActions: actions) { result, account in
                switch result {
                case .success(let response):
                    let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                    let accountRecord = account?.asRecord
                    promise.resolve([results, accountRecord])
                case .failure(let error):
                    promise.reject("handshake-error", error.localizedDescription)
                }
            }
        }

        AsyncFunction("makeRequest") { (actions: [ActionRecord], account: AccountRecord?, promise: Promise) in
            guard let client = self.mwpClient else {
                promise.reject("Client not initialized", "Must Initialize client before making request")
                return
            }

            let requestActions: [Action] = actions.map { record in
                let paramsJson = record.paramsJson.data(using: .utf8)!
                let params = try! JSONSerialization.jsonObject(with: paramsJson) as! [String: Any]
                return Action(method: record.method, params: params)
            }

            let requestAccount: Account?
            if let account = account {
                requestAccount = Account(
                    chain: account.chain,
                    networkId: UInt(account.networkId),
                    address: account.address
                )
            } else {
                requestAccount = nil
            }

            client.makeRequest(
                Request(actions: requestActions, account: requestAccount)
            ) { result in
                switch result {
                case .success(let response):
                    let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                    promise.resolve(results)
                case .failure(let error):
                    promise.reject("request-error", error.localizedDescription)
                }
            }
        }

        Function("handleResponse") { (url: String) -> Bool in
            let responseURL = URL(string: url)!
            if (try? MWPClient.handleResponse(responseURL)) == true {
                return true
            }

            return false
        }

        Function("isCoinbaseWalletInstalled") { () -> Bool in
            return CoinbaseWalletSDK.isCoinbaseWalletInstalled()
        }

        Function("isConnected") { () -> Bool in
            guard let client = self.mwpClient else {
                return false
            }

            return client.isConnected()
        }

        Function("resetSession") {
            guard let client = self.mwpClient else {
                return
            }

            client.resetSession()
        }

        Function("getWallets") { () -> [WalletRecord.Dict] in
            let wallets = Wallet.defaultWallets()
            let results: [WalletRecord.Dict] = wallets.map { $0.asRecord }
            return results
        }
    }
}

extension ActionResult {
    var asRecord: ActionResultRecord.Dict {
        let record = ActionResultRecord()

        switch self {
        case .success(let value):
            record.result = value.rawValue
        case .failure(let error):
            record.errorCode = error.code
            record.errorMessage = error.message
        }

        return record.toDictionary()
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

extension Wallet {
    var asRecord: WalletRecord.Dict {
        let record = WalletRecord()
        record.name = self.name
        record.iconUrl = self.iconUrl.absoluteString
        record.url = self.url.absoluteString
        record.mwpScheme = self.mwpScheme.absoluteString
        record.appStoreUrl = self.appStoreUrl.absoluteString
        return record.toDictionary()
    }
}
