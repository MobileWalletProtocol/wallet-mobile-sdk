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

struct ReturnValueRecord : Record {
    @Field
    var result: String? = nil

    @Field
    var errorMessage: String? = nil

    @Field
    var errorCode: Int? = nil
}

public class CoinbaseWalletSDKModule: Module {

    var hasConfigured: Bool = false

    public func definition() -> ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { (callbackURL: String, hostURL: String?, _: String?) in
            guard #available(iOS 13.0, *), !self.hasConfigured else {
                return
            }

            let host: URL
            if let hostURLStr = hostURL {
                host = URL(string: hostURLStr)!
            } else {
                host = URL(string: "https://wallet.coinbase.com/wsegue")!
            }

            self.hasConfigured = true
            CoinbaseWalletSDK.configure(
                host: host,
                callback: URL(string: callbackURL)!
            )
        }

        AsyncFunction("initiateHandshake") { (initialActions: [ActionRecord], promise: Promise) in
            guard #available(iOS 13.0, *) else {
                return
            }

            let actions: [Action] = initialActions.map { record in
                let paramsJson = record.paramsJson.data(using: .utf8)!
                let params = try! JSONSerialization.jsonObject(with: paramsJson) as! [String: Any]
                return Action(method: record.method, params: params)
            }

            CoinbaseWalletSDK.shared.initiateHandshake(initialActions: actions) { result in
                switch result {
                case .success(let response):
                    let results: [ReturnValueRecord.Dict] = response.content.map { $0.asRecord }
                    promise.resolve(results)
                case .failure(let error):
                    promise.reject("handshake-error", error.localizedDescription)
                }
            }
        }

        AsyncFunction("makeRequest") { (actions: [ActionRecord], account: AccountRecord?, promise: Promise) in
            guard #available(iOS 13.0, *) else {
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

            CoinbaseWalletSDK.shared.makeRequest(
                Request(actions: requestActions, account: requestAccount)
            ) { result in
                switch result {
                case .success(let response):
                    let results: [ReturnValueRecord.Dict] = response.content.map { $0.asRecord }
                    promise.resolve(results)
                case .failure(let error):
                    promise.reject("request-error", error.localizedDescription)
                }
            }
        }

        Function("handleResponse") { (url: String) -> Bool in
            guard #available(iOS 13.0, *) else {
                return false
            }

            let responseURL = URL(string: url)!
            if (try? CoinbaseWalletSDK.shared.handleResponse(responseURL)) == true {
                return true
            }

            return false
        }

        Function("isCoinbaseWalletInstalled") { () -> Bool in
            guard #available(iOS 13.0, *) else {
                return false
            }

            return CoinbaseWalletSDK.isCoinbaseWalletInstalled()
        }

        Function("isConnected") { () -> Bool in
            guard #available(iOS 13.0, *) else {
                return false
            }

            return CoinbaseWalletSDK.shared.isConnected()
        }

        Function("resetSession") {
            guard #available(iOS 13.0, *) else {
                return
            }

            CoinbaseWalletSDK.shared.resetSession()
        }
    }
}

extension ReturnValue {
    var asRecord: ReturnValueRecord.Dict {
        let record = ReturnValueRecord()

        switch self {
        case .result(let value):
            record.result = value
        case .error(let code, let message):
            record.errorCode = code
            record.errorMessage = message
        }

        return record.toDictionary()
    }
}
