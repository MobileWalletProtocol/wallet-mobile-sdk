package expo.modules.coinbasewalletsdkexpo

import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.DefaultWallets
import com.coinbase.android.nativesdk.ext.isInstalled
import expo.modules.coinbasewalletsdkexpo.records.ActionRecord
import expo.modules.coinbasewalletsdkexpo.records.ActionResultRecord
import expo.modules.coinbasewalletsdkexpo.records.ConfigParamsRecord
import expo.modules.coinbasewalletsdkexpo.records.RequestRecord
import expo.modules.coinbasewalletsdkexpo.records.asAction
import expo.modules.coinbasewalletsdkexpo.records.asRecord
import expo.modules.coinbasewalletsdkexpo.records.asRequest
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition


class CoinbaseWalletSDKModule : Module() {

    var hasConfigured = false

    override fun definition() = ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { params: ConfigParamsRecord ->
            if (hasConfigured) {
                return@Function
            }

            CoinbaseWalletSDK.openIntent = { IntentLauncher.launcher?.launch(it) }
            IntentLauncher.onResult = { uri -> CoinbaseWalletSDK.handleResponseUrl(uri) }

            val context = requireNotNull(appContext.reactContext?.applicationContext) {
                "Application context must not be null"
            }

            hasConfigured = true
            CoinbaseWalletSDK.configure(
                context = context,
                domain = Uri.parse(params.callbackURL),
                appName = params.appName,
                appIconUrl = params.appIconURL
            )

            CoinbaseWalletSDK.appendVersionTag("rn")
        }

        Function("handleResponse") { url: String ->
            val responseURL = Uri.parse(url)
            return@Function CoinbaseWalletSDK.handleResponseUrl(responseURL)
        }

        AsyncFunction("initiateHandshake") { wallet: WalletRecord, initialActions: List<ActionRecord>, promise: Promise ->
            val client = CoinbaseWalletSDK.getClient(wallet.asWallet)
            val actions = initialActions.map { it.asAction }

            client.initiateHandshake(actions) { result, account ->
                result
                    .onSuccess { responses ->
                        val results: List<ActionResultRecord> = responses.map { it.asRecord }
                        val accountRecord = account?.asRecord
                        promise.resolve(listOf(results, accountRecord))
                    }
                    .onFailure { error ->
                        promise.reject("handshake-error", error.message, error)
                    }
            }
        }

        AsyncFunction("makeRequest") { wallet: WalletRecord, request: RequestRecord, promise: Promise ->
            val client = CoinbaseWalletSDK.getClient(wallet.asWallet)

            client.makeRequest(request.asRequest) { result ->
                result
                    .onSuccess { responses ->
                        val results: List<ActionResultRecord> = responses.map { it.asRecord }
                        promise.resolve(results)
                    }
                    .onFailure { error ->
                        promise.reject("request-error", error.message, error)
                    }
            }
        }

        Function("isInstalled") { wallet: WalletRecord ->
            val context = requireNotNull(appContext.reactContext?.applicationContext) {
                "Application context must not be null"
            }

            return@Function wallet.asWallet.isInstalled(context)
        }

        Function("isConnected") { wallet: WalletRecord ->
            val client = CoinbaseWalletSDK.getClient(wallet.asWallet)
            return@Function client.isConnected
        }

        Function("resetSession") { wallet: WalletRecord ->
            val client = CoinbaseWalletSDK.getClient(wallet.asWallet)
            client.resetSession()
        }

        Function("getWallets") {
            val wallets = DefaultWallets.getWallets()
            return@Function wallets.map { it.asRecord }
        }
    }
}
