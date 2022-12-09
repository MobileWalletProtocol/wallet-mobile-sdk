package com.coinbase.android.nativesdk.message

import android.net.Uri
import com.google.crypto.tink.subtle.EllipticCurves
import java.security.interfaces.ECPrivateKey
import java.security.interfaces.ECPublicKey

interface MessageConverter<UnencryptedMessageType, EncryptedMessageType> {

    fun encode(
        message: UnencryptedMessageType,
        recipient: Uri,
        ownPrivateKey: ECPrivateKey? = null,
        peerPublicKey: ECPublicKey? = null
    ): Uri

    fun decode(
        url: Uri,
        ownPublicKey: ECPublicKey? = null,
        ownPrivateKey: ECPrivateKey? = null,
        peerPublicKey: ECPublicKey? = null
    ): UnencryptedMessageType

    fun decodeWithoutDecryption(url: Uri): EncryptedMessageType

    fun getSharedSecret(
        ownPublicKey: ECPublicKey? = null,
        ownPrivateKey: ECPrivateKey? = null,
        peerPublicKey: ECPublicKey? = null,
        messageSender: ECPublicKey? = null,
    ): ByteArray? {
        val myPrivateKey = ownPrivateKey ?: return null
        val otherPublicKey = (peerPublicKey ?: messageSender) ?: return null

        if (otherPublicKey == ownPublicKey) {
            return null
        }

        return EllipticCurves.computeSharedSecret(myPrivateKey, otherPublicKey)
    }
}
