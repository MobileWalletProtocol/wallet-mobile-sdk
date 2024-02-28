import ExpoModulesCore
import CoinbaseWalletSDK
import Foundation

public class CoinbaseWalletSDKModule: Module {

    public func definition() -> ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { (params: ConfigParamsRecord) in
            guard !CoinbaseWalletSDK.isConfigured else {
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
            let actions: [Action] = params.initialActions.map { $0.asAction }

            DispatchQueue.main.async {
                CoinbaseWalletSDK.shared.initiateHandshake(initialActions: actions) { result, account in
                    switch result {
                    case .success(let response):
                        let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                        let accountRecord = account?.asRecord
                        promise.resolve([results, accountRecord])
                    case .failure(let error):
                        promise.reject("handshake-error", "\(error)");
                    }
                }
            }
        }

        AsyncFunction("makeRequest") { (params: RequestParamsRecord, promise: Promise) in
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
            
            DispatchQueue.main.async {
                CoinbaseWalletSDK.shared.makeRequest(
                    Request(actions: requestActions, account: requestAccount)
                ) { result in
                    switch result {
                    case .success(let response):
                        let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                        promise.resolve(results)
                    case .failure(let error):
                        promise.reject("request-error", "\(error)")
                    }
                }
            }
        }

        Function("handleResponse") { (url: String) -> Bool in
            guard CoinbaseWalletSDK.isConfigured else {
                return false
            }

            let responseURL = URL(string: url)!
            if (try? CoinbaseWalletSDK.shared.handleResponse(responseURL)) == true {
                return true
            }

            return false
        }

        AsyncFunction("isCoinbaseWalletInstalled") { (promise: Promise) in
            DispatchQueue.main.async {
                promise.resolve(CoinbaseWalletSDK.isCoinbaseWalletInstalled())
            }
        }
        
        AsyncFunction("getCoinbaseWalletMWPVersion") { (promise: Promise) in
            DispatchQueue.main.async {
                promise.resolve(CoinbaseWalletSDK.getCoinbaseWalletMWPVersion())
            }
        }

        Function("isConnected") { () -> Bool in
            return CoinbaseWalletSDK.shared.isConnected()
        }

        Function("resetSession") {
            CoinbaseWalletSDK.shared.resetSession()
        }
    }
}
