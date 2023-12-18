import ExpoModulesCore
import CoinbaseWalletSDK
import Foundation

public class CoinbaseWalletSDKModule: Module {

    public func definition() -> ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { (params: ConfigParamsRecord) in
            guard #available(iOS 13.0, *), !CoinbaseWalletSDK.isConfigured else {
                return
            }

            let host: URL
            if let hostURLStr = params.hostURL {
                host = URL(string: hostURLStr)!
            } else {
                host = URL(string: "https://wallet.coinbase.com/wsegue")!
            }

            CoinbaseWalletSDK.configure(
                host: host,
                callback: URL(string: params.callbackURL)!
            )
            CoinbaseWalletSDK.appendVersionTag("rn")
        }

        AsyncFunction("initiateHandshake") { (params: HandshakeParamsRecord, promise: Promise) in
            guard #available(iOS 13.0, *) else {
                return
            }

            let actions: [Action] = params.initialActions.map { $0.asAction }

            CoinbaseWalletSDK.shared.initiateHandshake(initialActions: actions) { result, account in
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

        AsyncFunction("makeRequest") { (params: RequestParamsRecord, promise: Promise) in
            guard #available(iOS 13.0, *) else {
                return
            }

            let requestActions: [Action] = params.actions.map { $0.asAction }

            let requestAccount: Account?
            if let account = params.account {
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
                    let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                    promise.resolve(results)
                case .failure(let error):
                    promise.reject("request-error", error.localizedDescription)
                }
            }
        }

        Function("handleResponse") { (url: String) -> Bool in
            guard #available(iOS 13.0, *), CoinbaseWalletSDK.isConfigured else {
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
