package com.coinbase.flutter.wallet_sdk

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
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

    private lateinit var coinbase: CoinbaseWalletSDK

    private lateinit var flutterApplicationContext: Context

    private var act: android.app.Activity? = null

    private val successJson = "{ \"success\": true}"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterApplicationContext = flutterPluginBinding.applicationContext
        coinbase = CoinbaseWalletSDK(
            appContext = flutterPluginBinding.applicationContext,
            // TODO: This should be changed, and passed in from client
            domain = Uri.parse("https://www.coinbase.com"),
            openIntent = { intent -> act?.startActivityForResult(intent, 0) }
        )
        coinbase.appendVersionTag("flutter")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "coinbase_wallet_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        try {
            if (call.method == "configure") {
                return configure(call, result)
            }

            if (call.method == "initiateHandshake") {
                return initiateHandshake(call, result)
            }

            if (call.method == "makeRequest") {
                return makeRequest(call, result)
            }

            if (call.method == "resetSession") {
                return resetSession(result)
            }

            if (call.method == "isAppInstalled") {
                return isAppInstalled(result)
            }

            if (call.method == "isConnected") {
                return isConnected(result)
            }
        } catch (e: Throwable) {
            result.error("onMethodCall", e.message, null)
        }

        result.notImplemented()
    }

    private fun isAppInstalled(@NonNull result: Result) {
        result.success(coinbase.isCoinbaseWalletInstalled)
    }

    private fun isConnected(@NonNull result: Result) {
        result.success(coinbase.isConnected)
    }

    private fun configure(@NonNull call: MethodCall, @NonNull result: Result) {
        val args = call.arguments
        if (args !is Map<*, *>) {
            return result.error("configure", "Missing arguments", null)
        }

        val domain = args["domain"] as String
        coinbase = CoinbaseWalletSDK(
            appContext = flutterApplicationContext,
            domain = Uri.parse(domain),
            openIntent = { intent -> act?.startActivityForResult(intent, 0) }
        )

        result.success(successJson)
    }

    private fun initiateHandshake(@NonNull call: MethodCall, @NonNull result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("initiateHandshake", "Missing args", null)
        }

        val actions = Json.decodeFromString<List<Action>>(jsonString)
        coinbase.initiateHandshake(initialActions = actions) { responseResult, account ->
            handleResponse("initiateHandshake", responseResult, account, result)
        }
    }

    private fun makeRequest(@NonNull call: MethodCall, @NonNull result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("makeRequest", "Missing args", null)
        }

        val request = Json.decodeFromString<RequestContent.Request>(jsonString)
        coinbase.makeRequest(request) { responseResult ->
            handleResponse("makeRequest", responseResult, null, result)
        }
    }

    private fun resetSession(@NonNull result: Result) {
        coinbase.resetSession()
        result.success(successJson)
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

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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
        return coinbase.handleResponse(uri)
    }
}
