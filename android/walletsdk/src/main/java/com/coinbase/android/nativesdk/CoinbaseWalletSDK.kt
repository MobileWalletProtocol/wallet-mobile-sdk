package com.coinbase.android.nativesdk

import android.app.Application
import android.content.Intent
import android.net.Uri
import com.coinbase.android.nativesdk.key.IKeyManager
import com.coinbase.android.nativesdk.key.KeyManager
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.MessageConverter
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.ETH_REQUEST_ACCOUNTS
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.message.request.RequestMessage
import com.coinbase.android.nativesdk.message.request.nonHandshakeActions
import com.coinbase.android.nativesdk.message.response.ActionResult
import com.coinbase.android.nativesdk.message.response.FailureResponseCallback
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import com.coinbase.android.nativesdk.message.response.ResponseResult
import com.coinbase.android.nativesdk.message.response.SuccessHandshakeResponseCallback
import com.coinbase.android.nativesdk.message.response.SuccessRequestResponseCallback
import com.coinbase.android.nativesdk.task.TaskManager
import kotlinx.serialization.decodeFromString
import java.security.interfaces.ECPublicKey
import java.util.Date
import java.util.UUID

const val CBW_PACKAGE_NAME = "org.toshi"

class CoinbaseWalletSDK internal constructor(
    private val hostPackageName: String,
    private val scheme: String,
    private val keyManager: IKeyManager
) {

    private var sdkVersion = BuildConfig.LIBRARY_VERSION_NAME

    private val launchWalletIntent: Intent?
        get() = context.packageManager.getLaunchIntentForPackage(hostPackageName)

    val isConnected: Boolean get() = keyManager.peerPublicKey != null

    init {
        instances[scheme] = this
    }

    constructor(
        hostPackageName: String,
        scheme: String,
    ) : this(
        hostPackageName,
        scheme,
        KeyManager(context, hostPackageName),
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
                appId = context.packageName,
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

            val account = runCatching {
                JSON.decodeFromString<Account>(requestAccountsResult.value)
            }.getOrNull()

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

        return TaskManager.handleResponse(message)
    }

    fun resetSession() {
        TaskManager.reset(scheme)
        keyManager.resetKeys()
    }

    private fun send(message: RequestMessage, onResponse: ResponseHandler) {
        val uri: Uri
        try {
            uri = MessageConverter.encodeRequest(
                message = message,
                recipient = Uri.parse(scheme),
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

        TaskManager.registerResponseHandler(message, onResponse, scheme)
        openIntent(intent)
    }

    private fun isWalletSegueResponseURL(uri: Uri): Boolean {
        return uri.host == domain.host && uri.path == domain.path && uri.getQueryParameter("p") != null
    }

    companion object {
        private val instances: MutableMap<String, CoinbaseWalletSDK> = mutableMapOf()

        private lateinit var domain: Uri

        private lateinit var context: Application

        lateinit var openIntent: (Intent) -> Unit

        fun configure(domain: Uri, context: Application) {
            this.domain = if (domain.pathSegments.size < 2) {
                domain.buildUpon()
                    .appendPath("wsegue")
                    .build()
            } else {
                domain
            }
            this.context = context
        }

        fun getClient(wallet: Wallet): CoinbaseWalletSDK {
            if (!this::openIntent.isInitialized) {
                throw CoinbaseWalletSDKError.WalletReturnedError(
                    "Must initialize open intent callback before getting CoinbaseWalletSDK instance"
                )
            }
            return instances[wallet.url] ?: CoinbaseWalletSDK(
                hostPackageName = wallet.packageName,
                scheme = wallet.url,
                keyManager = KeyManager(context, wallet.packageName)
            )
        }

        fun handleResponse(uri: Uri): Boolean {
            val requestId = checkNotNull(MessageConverter.getRequestIdFromResponse(uri)) { "Callback not found" }
            val host = TaskManager.findRequestId(requestId) ?: return false
            return instances[host]?.handleResponse(uri) == true
        }
    }
}
