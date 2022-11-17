package com.coinbase.mobilewalletprotocolhost

import android.content.Intent
import android.net.Uri
import android.util.Base64
import com.coinbase.android.nativesdk.message.MessageConverter
import com.coinbase.android.nativesdk.message.MessageSerializer
import com.coinbase.android.nativesdk.message.request.RequestSerializer
import com.coinbase.android.nativesdk.message.response.ResponseMessages
import com.facebook.react.ReactActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.google.crypto.tink.subtle.EllipticCurves
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

class MobileWalletProtocolHostModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName(): String = "NativeSdkSupport"

    private val unencryptedMessageSerializer by lazy {
        val requestSerializer = RequestSerializer(sharedSecret = null, encrypted = false)
        MessageSerializer(requestSerializer)
    }

    @ReactMethod
    fun generateKeyPair(promise: Promise) {
        val sessionKeyPair = EllipticCurves.generateKeyPair(EllipticCurves.CurveType.NIST_P256)
        val keyMap = Arguments.createMap().apply {
            putString("publicKey", Base64.encodeToString(sessionKeyPair.public.encoded, Base64.NO_WRAP))
            putString("privateKey", Base64.encodeToString(sessionKeyPair.private.encoded, Base64.NO_WRAP))
        }

        promise.resolve(keyMap)
    }

    @ReactMethod
    fun decodeRequest(
        urlStr: String,
        ownPrivateKeyStr: String?,
        peerPublicKeyStr: String?,
        promise: Promise
    ) {
        try {
            val url = Uri.parse(urlStr)

            val ownPrivateKey = ownPrivateKeyStr?.let { key ->
                val bytes = Base64.decode(key, Base64.NO_WRAP)
                EllipticCurves.getEcPrivateKey(bytes)
            }

            val peerPublicKey = peerPublicKeyStr?.let { key ->
                val bytes = Base64.decode(key, Base64.NO_WRAP)
                EllipticCurves.getEcPublicKey(bytes)
            }

            val request = MessageConverter.decodeRequest(
                url = url,
                ownPrivateKey = ownPrivateKey,
                peerPublicKey = peerPublicKey
            )

            val requestJson = Json.encodeToJsonElement(unencryptedMessageSerializer, request) as JsonObject
            val requestMap = requestJson.asReadableMap()
            promise.resolve(requestMap)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    @ReactMethod
    fun encodeResponse(
        responseStr: String,
        recipientStr: String,
        ownPrivateKeyStr: String?,
        peerPublicKeyStr: String?,
        promise: Promise
    ) {
        try {
            val message = ResponseMessages.decodeFromJson(responseStr)

            val ownPrivateKey = ownPrivateKeyStr?.let { key ->
                val bytes = Base64.decode(key, Base64.NO_WRAP)
                EllipticCurves.getEcPrivateKey(bytes)
            }

            val peerPublicKey = peerPublicKeyStr?.let { key ->
                val bytes = Base64.decode(key, Base64.NO_WRAP)
                EllipticCurves.getEcPublicKey(bytes)
            }

            val responseUri = MessageConverter.encodeResponse(
                message = message,
                recipient = Uri.parse(recipientStr),
                ownPrivateKey = ownPrivateKey,
                peerPublicKey = peerPublicKey
            )

            promise.resolve(responseUri.toString())
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    @ReactMethod
    fun getClientAppMetadata(wellKnownCertificates: ReadableArray, promise: Promise) {
        try {
            val activity = requireNotNull(currentActivity)
            val callingPackage = requireNotNull(activity.callingPackage)
            val certificates = wellKnownCertificates.toArrayList().map { it as String }.toSet()

            val appInfo = activity.packageManager.getApplicationInfo(callingPackage, 0)
            val appIcon = activity.packageManager.getApplicationIcon(appInfo).asBase64EncodedString()
            val appLabel = activity.packageManager.getApplicationLabel(appInfo).toString()
            val appSignatures = activity.packageManager.getApplicationSignatures(callingPackage)

            val metadata = Arguments.createMap().apply {
                putString("appName", appLabel)
                putString("appIconBase64", appIcon.orEmpty())

                val matchedSignatures = appSignatures intersect certificates
                putBoolean("certificateMatch", matchedSignatures.isNotEmpty())
            }

            promise.resolve(metadata)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    fun getClientAppMetadataV2(promise: Promise) {
        try {
            val activity = requireNotNull(currentActivity)
            val callingPackage = requireNotNull(activity.callingPackage)

            val appInfo = activity.packageManager.getApplicationInfo(callingPackage, 0)
            val appIcon = activity.packageManager.getApplicationIcon(appInfo).asBase64EncodedString()
            val appLabel = activity.packageManager.getApplicationLabel(appInfo).toString()

            val metadata = Arguments.createMap().apply {
                putString("appName", appLabel)
                putString("appIconBase64", appIcon.orEmpty())
            }

            promise.resolve(metadata)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    @ReactMethod
    fun getClientAppSignatures(promise: Promise) {
        try {
            val activity = requireNotNull(currentActivity)
            val callingPackage = requireNotNull(activity.callingPackage)

            val signatures = Arguments.createArray()
            activity.packageManager.getApplicationSignatures(callingPackage).forEach { signature ->
                signatures.pushString(signature)
            }

            promise.resolve(signatures)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }

    @ReactMethod
    fun triggerWalletSDKCallback(domain: String, promise: Promise) {
        try {
            val activity = requireNotNull(currentActivity)

            val intent = Intent()
            intent.data = Uri.parse(domain)

            activity.setResult(ReactActivity.RESULT_OK, intent)
            activity.finish()

            promise.resolve(null)
        } catch (e: Throwable) {
            promise.reject(e)
        }
    }
}
