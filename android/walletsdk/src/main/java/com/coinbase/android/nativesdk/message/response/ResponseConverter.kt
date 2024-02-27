package com.coinbase.android.nativesdk.message.response

import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.MessageConverter
import com.coinbase.android.nativesdk.message.JSON
import com.google.crypto.tink.subtle.Base64
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import java.security.interfaces.ECPrivateKey
import java.security.interfaces.ECPublicKey

object ResponseConverter : MessageConverter<UnencryptedResponseMessage, EncryptedResponseMessage> {

    override fun encode(
        message: UnencryptedResponseMessage,
        recipient: Uri,
        ownPrivateKey: ECPrivateKey?,
        peerPublicKey: ECPublicKey?
    ): Uri {
        val secret = getSharedSecret(ownPrivateKey = ownPrivateKey, peerPublicKey = peerPublicKey)
        val encrypted = message.encrypt(secret)
        val json = JSON.encodeToString(encrypted)

        return recipient.buildUpon()
            .appendQueryParameter("p", Base64.encode(json.toByteArray()))
            .build()
    }

    override fun decode(
        url: Uri,
        ownPublicKey: ECPublicKey?,
        ownPrivateKey: ECPrivateKey?,
        peerPublicKey: ECPublicKey?
    ): UnencryptedResponseMessage {
        val decoded = decodeWithoutDecryption(url)
        val secret = getSharedSecret(
            ownPublicKey = ownPublicKey,
            ownPrivateKey = ownPrivateKey,
            peerPublicKey = peerPublicKey,
            messageSender = decoded.sender as ECPublicKey
        )

        return decoded.decrypt(secret)
    }

    override fun decodeWithoutDecryption(url: Uri): EncryptedResponseMessage {
        val encoded = url.getQueryParameter("p") ?: throw CoinbaseWalletSDKError.DecodingFailed
        val messageJsonString = String(Base64.decode(encoded))
        return JSON.decodeFromString(messageJsonString)
    }
}