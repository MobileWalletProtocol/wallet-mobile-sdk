package com.coinbase.android.nativesdk.key

import android.content.Context
import com.google.crypto.tink.subtle.EllipticCurves
import java.security.KeyPair
import java.security.interfaces.ECPrivateKey
import java.security.interfaces.ECPublicKey

private const val OWN_KEY_PAIR_ALIAS = "own_key_pair"

internal class KeyManager(appContext: Context, host: String) {

    private val encryptedStore: EncryptedStore
    private var ownKeyPair: KeyPair? = null

    val ownPublicKey: ECPublicKey
        get() {
            val own = ownKeyPair ?: getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
            if (ownKeyPair == null) ownKeyPair = own
            return own.public as ECPublicKey
        }

    val ownPrivateKey: ECPrivateKey
        get() {
            val own = ownKeyPair ?: getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
            if (ownKeyPair == null) ownKeyPair = own
            return own.private as ECPrivateKey
        }

    val peerPublicKey: ECPublicKey?
        get() = encryptedStore.peerPublicKey

    init {
        encryptedStore = EncryptedStore(
            fileName = "${host}_wallet_segue_key_store",
            context = appContext
        )
    }

    fun storePeerPublicKey(key: ECPublicKey) {
        encryptedStore.peerPublicKey = key
    }

    fun resetKeys() {
        encryptedStore.reset()

        // Create new KeyPair
        ownKeyPair = getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
    }

    private fun deleteKeyPair(alias: String) {
        encryptedStore.deleteKeyPair(alias)
    }

    private fun getOrCreateKeyPair(alias: String): KeyPair {
        val keyPair = encryptedStore.getKeyPair(alias)
        return if (keyPair != null) {
            // Already have keys in encrypted storage
            keyPair
        } else {
            // Generate new key pair and save to encrypted storage
            val kp = EllipticCurves.generateKeyPair(EllipticCurves.CurveType.NIST_P256)
            encryptedStore.saveKeyPair(alias, kp)
            kp
        }
    }
}