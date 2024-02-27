package com.coinbase.android.nativesdk.message.response

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.Cipher
import com.coinbase.android.nativesdk.message.JSON
import com.coinbase.android.nativesdk.message.Message
import kotlinx.serialization.EncodeDefault
import kotlinx.serialization.EncodeDefault.Mode.NEVER
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString

typealias EncryptedResponseMessage = Message<EncryptedResponseContent>

@Serializable
data class EncryptedResponse(
    val requestId: String? = null,
    val data: String
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
data class EncryptedResponseContent(
    @EncodeDefault(NEVER) val response: EncryptedResponse? = null,
    @EncodeDefault(NEVER) val failure: ResponseContent.Failure? = null
)

fun EncryptedResponseMessage.decrypt(secret: ByteArray?): UnencryptedResponseMessage {
    val content: UnencryptedResponseContent = when {
        this.content.failure != null -> {
            UnencryptedResponseContent(failure = this.content.failure)
        }
        this.content.response != null -> {
            if (secret == null) throw CoinbaseWalletSDKError.MissingSharedSecret

            val responseJson = Cipher.decrypt(secret, this.content.response.data)
            val response: ResponseContent.Response = JSON.decodeFromString(responseJson)
            UnencryptedResponseContent(response = response)
        }
        else -> throw CoinbaseWalletSDKError.DecodingFailed
    }

    return copy(newContent = content)
}
