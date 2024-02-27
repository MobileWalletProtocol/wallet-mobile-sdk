package com.coinbase.android.nativesdk.message.request

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.Cipher
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.Message
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.EncodeDefault.Mode.NEVER
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString

typealias EncryptedRequestMessage = Message<EncryptedRequestContent>

@Serializable
data class EncryptedRequest(val data: String)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class EncryptedRequestContent(
    @EncodeDefault(NEVER) val handshake: RequestContent.Handshake? = null,
    @EncodeDefault(NEVER) val request: EncryptedRequest? = null
)

fun EncryptedRequestMessage.decrypt(secret: ByteArray?): UnencryptedRequestMessage {
    val content = when {
        this.content.handshake != null -> {
            UnencryptedRequestContent(handshake = this.content.handshake)
        }
        this.content.request != null -> {
            if (secret == null) throw CoinbaseWalletSDKError.MissingSharedSecret

            val requestJson = Cipher.decrypt(secret, this.content.request.data)
            val request: RequestContent.Request = JSON.decodeFromString(requestJson)
            UnencryptedRequestContent(request = request)
        }
        else -> throw CoinbaseWalletSDKError.DecodingFailed
    }

    return copy(newContent = content)
}