import ExpoModulesCore
import CoinbaseWalletSDK
import Foundation

public class CoinbaseWalletSDKModule: Module {

    var hasConfigured: Bool = false

    public func definition() -> ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { (params: ConfigParamsRecord) in
            guard !self.hasConfigured else {
                return
            }

            var appIconURL: URL? = nil
            if let iconUrl = params.appIconURL {
                appIconURL = URL(string: iconUrl)
            }

            self.hasConfigured = true
            MWPClient.configure(
                callback: URL(string: params.callbackURL)!,
                appId: params.appID,
                name: params.appName,
                iconUrl: appIconURL
            )

            CoinbaseWalletSDK.appendVersionTag("rn")
        }

        Function("handleResponse") { (url: String) -> Bool in
            let responseURL = URL(string: url)!
            if (try? MWPClient.handleResponse(responseURL)) == true {
                return true
            }

            return false
        }

        AsyncFunction("initiateHandshake") { (params: HandshakeParamsRecord, promise: Promise) in
            guard let client = MWPClient.getInstance(to: params.wallet.asWallet) else {
                promise.reject("MWPClient not configured", "Must configure client before making handshake request")
                return
            }

            let actions: [Action] = params.initialActions.map { $0.asAction }

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

        AsyncFunction("makeRequest") { (params: RequestParamsRecord, promise: Promise) in
            guard let client = MWPClient.getInstance(to: params.wallet.asWallet) else {
                promise.reject("MWPClient not configured", "Must configure client before making request")
                return
            }

            client.makeRequest(params.request.asRequest) { result in
                switch result {
                case .success(let response):
                    let results: [ActionResultRecord.Dict] = response.content.map { $0.asRecord }
                    promise.resolve(results)
                case .failure(let error):
                    promise.reject("request-error", error.localizedDescription)
                }
            }
        }

        Function("isInstalled") { (wallet: WalletRecord) -> Bool in
            return wallet.asWallet.isInstalled
        }

        Function("isConnected") { (wallet: WalletRecord) -> Bool in
            if let client = MWPClient.getInstance(to: wallet.asWallet) {
                return client.isConnected()
            } else {
                return false
            }
        }

        Function("resetSession") { (wallet: WalletRecord) in
            if let client = MWPClient.getInstance(to: wallet.asWallet) {
                client.resetSession()
            }
        }

        Function("getWallets") { () -> [WalletRecord.Dict] in
            let wallets = Wallet.defaultWallets()
            return wallets.map { $0.asRecord }
        }
    }
}
