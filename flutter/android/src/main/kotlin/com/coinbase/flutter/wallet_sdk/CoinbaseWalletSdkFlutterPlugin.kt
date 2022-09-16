package com.coinbase.flutter.wallet_sdk

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.message.response.ResponseResult
import com.coinbase.android.nativesdk.message.response.ActionResult
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

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

    private val gson = Gson()

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
        } catch (e: Throwable) {
            result.error("onMethodCall", e.message, null)
        }

        result.notImplemented()
    }

    private fun isAppInstalled(@NonNull result: Result) {
        result.success(coinbase.isCoinbaseWalletInstalled)
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

        val arrayTutorialType = object : TypeToken<List<Action>>() {}.type
        val actions: List<Action> = gson.fromJson(jsonString, arrayTutorialType)

        coinbase.initiateHandshake(initialActions = actions) { responseResult, account ->
            handleResponse("initiateHandshake", responseResult, account, result)
        }
    }

    private fun makeRequest(@NonNull call: MethodCall, @NonNull result: Result) {
        val jsonString = call.arguments
        if (jsonString !is String) {
            return result.error("makeRequest", "Missing args", null)
        }

        val request: RequestContent.Request = gson.fromJson(jsonString, RequestContent.Request::class.java)
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
        val toFlutter = mutableListOf<Map<String, Any>>()

        returnValues.forEach {
            val response = mutableMapOf<String, Any>()

            if (account != null) {
                response["account"] = account.toMap()
            }
            when (it) {
                is ActionResult.Result -> response["result"]= it.value
                is ActionResult.Error -> response["error"] = mapOf("code" to it.code, "message" to it.message)
            }

            toFlutter.add(response)
        }

        val jsonString = gson.toJson(toFlutter)
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

private fun Account.toMap(): Map<String, Any> {
    return mapOf<String, Any>(
        "chain" to chain,
        "networkId" to networkId,
        "address" to address
    )
}