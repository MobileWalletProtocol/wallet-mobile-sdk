package expo.modules.coinbasewalletsdkexpo

import android.net.Uri
import android.util.Log
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
import expo.modules.coinbasewalletsdkexpo.records.AccountRecord
import expo.modules.coinbasewalletsdkexpo.records.ActionRecord
import expo.modules.coinbasewalletsdkexpo.records.ActionResultRecord
import expo.modules.coinbasewalletsdkexpo.records.ConfigParamsRecord
import expo.modules.coinbasewalletsdkexpo.records.HandshakeParamsRecord
import expo.modules.coinbasewalletsdkexpo.records.RequestParamsRecord
import expo.modules.coinbasewalletsdkexpo.records.asAction
import expo.modules.coinbasewalletsdkexpo.records.asRecord
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class CoinbaseWalletSDKModule : Module() {
    private var sdk: CoinbaseWalletSDK? = null

    override fun definition() = ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { params: ConfigParamsRecord ->
            try {
                IntentLauncher.onResult = { uri -> sdk?.handleResponse(uri) }

                val context = requireNotNull(appContext.reactContext?.applicationContext) {
                    "CoinbaseWalletSDK: Application context must not be null"
                }

                sdk = CoinbaseWalletSDK(
                    domain = Uri.parse(params.callbackURL),
                    appContext = context,
                    hostPackageName = params.hostPackageName ?: "org.toshi",
                    openIntent = { IntentLauncher.launcher?.launch(it) }
                )
                sdk?.appendVersionTag("rn")
            } catch (e: Exception) {
                Log.e("CoinbaseWalletSDK", "Configuration error", e)
            }
        }

        AsyncFunction("initiateHandshake") { params: HandshakeParamsRecord, promise: Promise ->
            val sdk = sdk
            if (sdk == null) {
                promise.reject("configure-error", "configure must be called before handshake can be initiated", null)
                return@AsyncFunction
            }

            val handshakeActions = params.initialActions.map { it.asAction }

            sdk.initiateHandshake(handshakeActions) { result, account ->
                result
                    .onSuccess { responses ->
                        val results: List<ActionResultRecord> = responses.map { it.asRecord }
                        val accountRecord = account?.asRecord
                        promise.resolve(listOf(results, accountRecord))
                    }
                    .onFailure { error ->
                        Log.e("CoinbaseWalletSDK", "Handshake error", error)
                        promise.reject("handshake-error", error.message, error)
                    }
            }
        }

        AsyncFunction("makeRequest") { params: RequestParamsRecord, promise: Promise ->
            val sdk = sdk
            if (sdk == null) {
                promise.reject("configure-error", "configure must be called before request can be initiated", null)
                return@AsyncFunction
            }

            val requestActions = params.actions.map { it.asAction }

            val requestAccount = params.account?.let { record ->
                Account(
                    chain = record.chain,
                    networkId = record.networkId.toLong(),
                    address = record.address
                )
            }

            val request = RequestContent.Request(actions = requestActions, account = requestAccount)
            sdk.makeRequest(request) { result ->
                result
                    .onSuccess { responses ->
                        val results: List<ActionResultRecord> = responses.map { it.asRecord }
                        promise.resolve(results)
                    }
                    .onFailure { error ->
                        Log.e("CoinbaseWalletSDK", "Request error", error)
                        promise.reject("request-error", error.message, error)
                    }
            }
        }

        Function("handleResponse") { url: String ->
            val responseURL = Uri.parse(url)

            try {
                return@Function sdk?.handleResponse(responseURL) ?: false
            } catch (error: Exception) {
                return@Function false
            }
        }

        Function("isCoinbaseWalletInstalled") {
            return@Function sdk?.isCoinbaseWalletInstalled ?: false
        }

        Function("isConnected") {
            return@Function sdk?.isConnected ?: false
        }

        Function("resetSession") {
            sdk?.resetSession()
        }
    }
}
