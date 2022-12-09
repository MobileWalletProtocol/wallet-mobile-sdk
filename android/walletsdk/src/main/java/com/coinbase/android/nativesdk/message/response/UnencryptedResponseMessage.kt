package com.coinbase.android.nativesdk.message.response

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.Cipher
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.Message
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.EncodeDefault.Mode.NEVER
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString

typealias UnencryptedResponseMessage = Message<UnencryptedResponseContent>

sealed interface ResponseContent {
    @Serializable
    data class Response(
        val requestId: String,
        val values: List<ActionResult>
    ) : ResponseContent

    @Serializable
    data class Failure(
        val requestId: String,
        val description: String
    ) : ResponseContent
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class UnencryptedResponseContent(
    @EncodeDefault(NEVER) val failure: ResponseContent.Failure? = null,
    @EncodeDefault(NEVER) val response: ResponseContent.Response? = null
) {
    val sealed get() = failure ?: response ?: throw IllegalStateException()
}

fun UnencryptedResponseMessage.encrypt(secret: ByteArray?): EncryptedResponseMessage {
    val encryptedContent: EncryptedResponseContent = when (val content = this.content.sealed) {
        is ResponseContent.Failure -> {
            EncryptedResponseContent(failure = content)
        }
        is ResponseContent.Response -> {
            if (secret == null) throw CoinbaseWalletSDKError.MissingSharedSecret

            val responseJson = JSON.encodeToString(content)
            val encrypted = Cipher.encrypt(secret, responseJson)
            EncryptedResponseContent(
                response = EncryptedResponse(
                    requestId = content.requestId,
                    data = encrypted
                )
            )
        }
    }

    return copy(newContent = encryptedContent)
}