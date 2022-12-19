package com.coinbase.flutter.wallet_sdk

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.DefaultWallets
import com.coinbase.android.nativesdk.Wallet
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.message.response.ActionResult
import com.coinbase.android.nativesdk.message.response.ResponseResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.encodeToJsonElement

/** CoinbaseWalletSdkFlutterPlugin */
class CoinbaseWalletSdkFlutterPlugin : FlutterPlugin, MethodCallHandler,
    ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var flutterApplicationContext: Context

    private var act: android.app.Activity? = null

    private val successJson = "{ \"success\": true}"
    private val json = Json {
        isLenient = true
        ignoreUnknownKeys = true
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterApplicationContext = flutterPluginBinding.applicationContext
        CoinbaseWalletSDK.configure(
            domain = Uri.parse("https://www.coinbase.com"),
            context = flutterApplicationContext
        )
        CoinbaseWalletSDK.appendVersionTag("flutter")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "coinbase_wallet_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "static_configure" -> return configure(call, result)
                "static_getWallets" -> return getWallets(result)

                "initiateHandshake" -> return initiateHandshake(call, result)
                "makeRequest" -> return makeRequest(call, result)
                "isConnected" -> return isConnected(call, result)
                "resetSession" -> return resetSession(call, result)
            }
        } catch (e: Throwable) {
            result.error("onMethodCall", e.message, null)
        }

        result.notImplemented()
    }

    private fun configure(call: MethodCall, result: Result) {
        val args = call.arguments
        if (args !is Map<*, *>) {
            return result.error("configure", "Missing arguments", null)
        }

        val domain = args["domain"] as String
        CoinbaseWalletSDK.configure(
            domain = Uri.parse(domain),
            context = flutterApplicationContext
        )
        CoinbaseWalletSDK.openIntent = { intent -> act?.startActivityForResult(intent, 0) }
        result.success(successJson)
    }

    private fun initiateHandshake(call: MethodCall, result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("initiateHandshake", "Missing args", null)
        }

        val decoded = Json.decodeFromString<InstanceMethodArgument<List<Action>>>(jsonString)
        val mwpClient = CoinbaseWalletSDK.getClient(decoded.wallet)
        val actions = decoded.argument

        mwpClient?.initiateHandshake(initialActions = actions) { responseResult, account ->
            handleResponse("initiateHandshake", responseResult, account, result)
        }
    }

    private fun makeRequest(call: MethodCall, result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("makeRequest", "Missing args", null)
        }

        val decoded = Json.decodeFromString<InstanceMethodArgument<RequestContent.Request>>(jsonString)
        val mwpClient = CoinbaseWalletSDK.getClient(decoded.wallet)
        val request = decoded.argument

        mwpClient?.makeRequest(request) { responseResult ->
            handleResponse("makeRequest", responseResult, null, result)
        }
    }

    private fun resetSession(call: MethodCall, result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("resetSession", "Missing args", null)
        }

        val decoded = Json.decodeFromString<InstanceMethodArgument<NoArgument>>(jsonString)
        val mwpClient = CoinbaseWalletSDK.getClient(decoded.wallet)

        mwpClient?.resetSession()
        result.success(successJson)
    }

    private fun isConnected(result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("isConnected", "Missing args", null)
        }

        val decoded = Json.decodeFromString<InstanceMethodArgument<NoArgument>>(jsonString)
        val mwpClient = CoinbaseWalletSDK.getClient(decoded.wallet)

        result.success(mwpClient?.isConnected() ?? false)
    }

    private fun handleResponse(
        code: String,
        responseResult: ResponseResult,
        account: Account?,
        result: Result
    ) {
        if (responseResult.isFailure) {
            return result.error(code, responseResult.exceptionOrNull()?.message, null)
        }

        val returnValues = responseResult.getOrNull() ?: emptyList()
        val toFlutter = returnValues.map { actionResult ->
            buildJsonObject {
                if (account != null) {
                    val accountJson = Json.encodeToJsonElement(account)
                    put("account", accountJson)
                }

                when (actionResult) {
                    is ActionResult.Result -> {
                        put("result", JsonPrimitive(actionResult.value))
                    }
                    is ActionResult.Error -> {
                        val errorJson = Json.encodeToJsonElement(actionResult)
                        put("error", errorJson)
                    }
                }
            }
        }

        val jsonString = Json.encodeToString(toFlutter)
        result.success(jsonString)
    }

    private fun getWallets(result: Result) {
        val wallets = DefaultWallets.getWallets().map { wallet ->
            val element = Json.encodeToJsonElement(wallet).jsonObject
            element.entries.associate {
                it.key to ((it.value as? JsonPrimitive)?.content ?: null)
            }.toMutableMap<String, Any?>().apply {
                this["isInstalled"] = wallet.isInstalled(flutterApplicationContext)
            }
        }

        val jsonString = Json.encodeToString(wallets)
        result.success(jsonString)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        act = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        act = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // no-op
    }

    override fun onDetachedFromActivity() {
        // no-op
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val uri = data?.data ?: return false
        // TODO: retrieve appropriate mwp client from uri
        return coinbase?.handleResponse(uri) == true
    }
}
