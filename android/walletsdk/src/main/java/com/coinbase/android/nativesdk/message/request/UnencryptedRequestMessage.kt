package com.coinbase.android.nativesdk.message.request

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.Cipher
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.Message
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.EncodeDefault.Mode.NEVER
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString

typealias UnencryptedRequestMessage = Message<UnencryptedRequestContent>

sealed interface RequestContent {
    @Serializable
    data class Handshake(
        val appId: String,
        val callback: String,
        val appName: String?,
        val appIconUrl: String?,
        val initialActions: List<Action>? = null
    ) : RequestContent

    @Serializable
    data class Request(
        val actions: List<Action>,
        val account: Account? = null
    ) : RequestContent
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class UnencryptedRequestContent(
    @EncodeDefault(NEVER) val handshake: RequestContent.Handshake? = null,
    @EncodeDefault(NEVER) val request: RequestContent.Request? = null
) {
    val sealed get() = handshake ?: request ?: throw IllegalStateException()
}

fun UnencryptedRequestMessage.encrypt(secret: ByteArray?): EncryptedRequestMessage {
    val encryptedContent = when (val content = this.content.sealed) {
        is RequestContent.Handshake -> {
            EncryptedRequestContent(handshake = content)
        }
        is RequestContent.Request -> {
            if (secret == null) throw CoinbaseWalletSDKError.MissingSharedSecret

            val requestJson = JSON.encodeToString(content)
            val encrypted = Cipher.encrypt(secret, requestJson)
            EncryptedRequestContent(request = EncryptedRequest(encrypted))
        }
    }

    return copy(newContent = encryptedContent)
}
