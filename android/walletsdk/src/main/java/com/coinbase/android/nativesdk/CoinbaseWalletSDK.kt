package com.coinbase.android.nativesdk

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.coinbase.android.nativesdk.key.KeyManager
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.MessageConverter
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.ETH_REQUEST_ACCOUNTS
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.message.request.RequestMessage
import com.coinbase.android.nativesdk.message.request.nonHandshakeActions
import com.coinbase.android.nativesdk.message.response.FailureResponseCallback
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import com.coinbase.android.nativesdk.message.response.ResponseResult
import com.coinbase.android.nativesdk.message.response.ActionResult
import com.coinbase.android.nativesdk.message.response.SuccessHandshakeResponseCallback
import com.coinbase.android.nativesdk.message.response.SuccessRequestResponseCallback
import com.coinbase.android.nativesdk.task.TaskManager
import kotlinx.serialization.decodeFromString
import java.security.interfaces.ECPublicKey
import java.util.Date
import java.util.UUID

const val CBW_PACKAGE_NAME = "org.toshi"
private const val CBW_SCHEME = "cbwallet://wsegue"

class CoinbaseWalletSDK(
    domain: Uri,
    private val appContext: Context,
    private val hostPackageName: String = CBW_PACKAGE_NAME,
    private val openIntent: (Intent) -> Unit
) {
    private val domain: Uri
    private var sdkVersion = BuildConfig.LIBRARY_VERSION_NAME
    private val keyManager by lazy { KeyManager(appContext, hostPackageName) }
    private val taskManager by lazy { TaskManager() }

    private val launchWalletIntent: Intent?
        get() = appContext.packageManager.getLaunchIntentForPackage(hostPackageName)

    val isCoinbaseWalletInstalled get() = launchWalletIntent != null
    val isConnected: Boolean get() = keyManager.peerPublicKey != null

    init {
        this.domain = if (domain.pathSegments.size < 2) {
            domain.buildUpon()
                .appendPath("wsegue")
                .build()
        } else {
            domain
        }
    }

    constructor(
        domain: Uri,
        appContext: Context,
        hostPackageName: String,
        openIntent: OpenIntentCallback
    ) : this(
        domain,
        appContext,
        hostPackageName,
        { intent -> openIntent.call(intent) }
    )

    fun appendVersionTag(tag: String) {
        sdkVersion += "/$tag"
    }

    /**
     * Make handshake request to get session key from wallet
     * @param initialActions Batch of actions that you'd want to execute after successful handshake. `eth_requestAccounts` by default.
     * @param onResponse Response callback with regular response result and optional parsed [Account] object.
     */
    fun initiateHandshake(
        initialActions: List<Action>? = null,
        onResponse: (ResponseResult, Account?) -> Unit
    ) {
        resetSession()

        val hasIllegalAction = initialActions?.any { nonHandshakeActions.contains(it.method) } == true
        if (hasIllegalAction) {
            onResponse(Result.failure(CoinbaseWalletSDKError.InvalidHandshakeRequest), null)
            return
        }

        val message = RequestMessage(
            uuid = UUID.randomUUID().toString(),
            version = sdkVersion,
            timestamp = Date(),
            sender = keyManager.ownPublicKey,
            content = RequestContent.Handshake(
                appId = appContext.packageName,
                callback = domain.toString(),
                initialActions = initialActions
            ),
            callbackUrl = domain.toString()
        )

        send(message) { result ->
            // Get index of eth_requestAccounts action
            val requestAccountsIndex = initialActions?.indexOfFirst { it.method == ETH_REQUEST_ACCOUNTS } ?: -1
            if (requestAccountsIndex == -1) {
                onResponse(result, null)
                return@send
            }

            // Get response from Wallet at index
            val requestAccountsResult = result.getOrNull()?.getOrNull(requestAccountsIndex)
            if (requestAccountsResult !is ActionResult.Result) {
                onResponse(result, null)
                return@send
            }

            val account = try {
                JSON.decodeFromString<Account>(requestAccountsResult.value)
            } catch (e: Exception) {
                null
            }

            onResponse(result, account)
        }
    }

    fun initiateHandshake(
        initialActions: List<Action>? = null,
        onSuccess: SuccessHandshakeResponseCallback,
        onFailure: FailureResponseCallback
    ) {
        initiateHandshake(initialActions) { result, account ->
            result
                .onSuccess { onSuccess.call(it, account) }
                .onFailure { onFailure.call(it) }
        }
    }

    /**
     * Make regular requests. It requires session key you get after successful handshake.
     */
    fun makeRequest(
        request: RequestContent.Request,
        onResponse: ResponseHandler
    ) {
        val message = RequestMessage(
            uuid = UUID.randomUUID().toString(),
            version = sdkVersion,
            timestamp = Date(),
            sender = keyManager.ownPublicKey,
            content = request,
            callbackUrl = domain.toString()
        )

        send(message, onResponse)
    }

    fun makeRequest(
        request: RequestContent.Request,
        onSuccess: SuccessRequestResponseCallback,
        onFailure: FailureResponseCallback
    ) {
        makeRequest(request) { result ->
            result
                .onSuccess { onSuccess.call(it) }
                .onFailure { onFailure.call(it) }
        }
    }

    /**
     * Handle incoming deep links
     * @param url deep link url
     * @return `false` if the input was not response message type, or `true` if SDK handled the input
     */
    fun handleResponse(url: Uri): Boolean {
        if (!isWalletSegueResponseURL(url)) {
            return false
        }

        val ownPublicKey = keyManager.ownPublicKey
        val peerPublicKey = keyManager.peerPublicKey

        val message = MessageConverter.decodeResponse(
            url = url,
            ownPublicKey = ownPublicKey,
            ownPrivateKey = keyManager.ownPrivateKey,
            peerPublicKey = peerPublicKey
        )

        if (peerPublicKey == null && message.sender != ownPublicKey) {
            keyManager.storePeerPublicKey(message.sender as ECPublicKey)
        }

        return taskManager.handleResponse(message)
    }

    fun resetSession() {
        taskManager.reset()
        keyManager.resetKeys()
    }

    private fun send(message: RequestMessage, onResponse: ResponseHandler) {
        val uri: Uri
        try {
            uri = MessageConverter.encodeRequest(
                message = message,
                recipient = Uri.parse(CBW_SCHEME),
                ownPrivateKey = keyManager.ownPrivateKey,
                peerPublicKey = keyManager.peerPublicKey
            )
        } catch (e: Throwable) {
            when (e) {
                is CoinbaseWalletSDKError -> onResponse(Result.failure(e))
                else -> onResponse(Result.failure(CoinbaseWalletSDKError.EncodingFailed))
            }
            return
        }

        val intent = launchWalletIntent
        if (intent == null) {
            onResponse(Result.failure(CoinbaseWalletSDKError.OpenWalletFailed))
            return
        }

        // Prevent intent from launching app in new window
        intent.type = Intent.ACTION_VIEW
        if (intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK > 0) {
            intent.flags = intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK.inv()
        }

        intent.data = uri

        taskManager.registerResponseHandler(message, onResponse)
        openIntent(intent)
    }

    private fun isWalletSegueResponseURL(uri: Uri): Boolean {
        return uri.host == domain.host && uri.path == domain.path && uri.getQueryParameter("p") != null
    }
}
