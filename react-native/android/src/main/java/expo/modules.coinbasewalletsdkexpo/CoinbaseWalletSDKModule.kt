package expo.modules.coinbasewalletsdkexpo

import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
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

class AccountRecord : Record {
    @Field
    var chain: String = ""

    @Field
    var networkId: Int = 1

    @Field
    var address: String = ""
}


class CoinbaseWalletSDKModule : Module() {
    private lateinit var sdk: CoinbaseWalletSDK

    override fun definition() = ModuleDefinition {

        Name("CoinbaseWalletSDK")

        Function("configure") { callbackURL: String, _: String?, hostPackageName: String? ->
            IntentLauncher.onResult = { uri -> sdk.handleResponse(uri) }

            sdk = CoinbaseWalletSDK(
                domain = Uri.parse(callbackURL),
                appContext = requireNotNull(appContext.reactContext),
                hostPackageName = hostPackageName ?: "org.toshi",
                openIntent = { IntentLauncher.launcher?.launch(it) }
            )
        }

        AsyncFunction("initiateHandshake") { initialActions: List<ActionRecord>, promise: Promise ->
            val handshakeActions = initialActions.map { record ->
                Action(
                    method = record.method,
                    paramsJson = record.paramsJson,
                    optional = record.optional
                )
            }

            sdk.initiateHandshake(handshakeActions) { result ->
                result
                    .onSuccess { responses ->
                        val results: List<ReturnValueRecord> = responses.map { it.asRecord }
                        promise.resolve(results)
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
            sdk.makeRequest(request) { result ->
                result
                    .onSuccess { responses ->
                        val results: List<ReturnValueRecord> = responses.map { it.asRecord }
                        promise.resolve(results)
                    }
                    .onFailure { error ->
                        promise.reject("request-error", error.message, error)
                    }
            }
        }

        Function("handleResponse") { url: String ->
            val responseURL = Uri.parse(url)

            try {
                return@Function sdk.handleResponse(responseURL)
            } catch (error: Exception) {
                return@Function false
            }
        }

        Function("isCoinbaseWalletInstalled") {
            return@Function sdk.isWalletInstalled
        }

        Function("isConnected") {
            return@Function sdk.hasEstablishedConnection
        }

        Function("resetSession") {
            sdk.resetSession()
        }
    }
}
