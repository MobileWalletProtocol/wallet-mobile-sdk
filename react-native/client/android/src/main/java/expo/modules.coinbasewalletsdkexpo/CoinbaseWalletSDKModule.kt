package expo.modules.coinbasewalletsdkexpo

import android.app.Application
import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.DefaultWallets
import com.coinbase.android.nativesdk.Wallet
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class ActionRecord : Record {
    @Field
    var method: String = ""

    @Field
    var paramsJson: String = "{}"

    @Field
    var optional: Boolean = false
}

class CoinbaseWalletSDKModule : Module() {
    private var sdk: CoinbaseWalletSDK? = null

    override fun definition() = ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { callbackURL: String ->
            CoinbaseWalletSDK.configure(
                domain = Uri.parse(callbackURL),
                context = requireNotNull(appContext.reactContext?.applicationContext)
            )
            CoinbaseWalletSDK.openIntent = { IntentLauncher.launcher?.launch(it) }
            IntentLauncher.onResult = { uri -> sdk?.handleResponse(uri) }
        }

        Function("connectWallet") { walletRecord: WalletRecord ->
            val wallet = walletRecord.asWallet
            sdk = CoinbaseWalletSDK.getClient(wallet)
            sdk?.appendVersionTag("rn")
        }

        AsyncFunction("initiateHandshake") { initialActions: List<ActionRecord>, promise: Promise ->
            val handshakeActions = initialActions.map { record ->
                Action(
                    method = record.method,
                    paramsJson = record.paramsJson,
                    optional = record.optional
                )
            }

            sdk?.initiateHandshake(handshakeActions) { result, account ->
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

        AsyncFunction("makeRequest") { actions: List<ActionRecord>, account: AccountRecord?, promise: Promise ->
            val requestActions = actions.map { record ->
                Action(
                    method = record.method,
                    paramsJson = record.paramsJson,
                    optional = record.optional
                )
            }

            val requestAccount = account?.let { record ->
                Account(
                    chain = record.chain,
                    networkId = record.networkId.toLong(),
                    address = record.address
                )
            }

            val request = RequestContent.Request(actions = requestActions, account = requestAccount)
            sdk?.makeRequest(request) { result ->
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

        Function("handleResponse") { url: String ->
            return@Function runCatching {
                val responseURL = Uri.parse(url)
                sdk?.handleResponse(responseURL)
            }.getOrDefault(false)
        }

        Function("isCoinbaseWalletInstalled") {
            return@Function sdk?.isCoinbaseWalletInstalled == true
        }

        Function("isConnected") {
            return@Function sdk?.isConnected
        }

        Function("resetSession") {
            sdk?.resetSession()
        }

        Function("getWallets") {
            val wallets = DefaultWallets.getWallets()
            return@Function wallets.map { it.asRecord }
        }
    }
}
