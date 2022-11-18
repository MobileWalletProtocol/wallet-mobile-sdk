package com.coinbase.android.nativesdk.key

import android.content.Context
import com.google.crypto.tink.subtle.EllipticCurves
import java.security.KeyPair
import java.security.interfaces.ECPrivateKey
import java.security.interfaces.ECPublicKey

private const val OWN_KEY_PAIR_ALIAS = "own_key_pair"

internal class KeyManager(appContext: Context, host: String) : IKeyManager {

    private val encryptedStore: EncryptedStore
    private var ownKeyPair: KeyPair? = null

    override val ownPublicKey: ECPublicKey
        get() {
            val own = ownKeyPair ?: getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
            if (ownKeyPair == null) ownKeyPair = own
            return own.public as ECPublicKey
        }

    override val ownPrivateKey: ECPrivateKey
        get() {
            val own = ownKeyPair ?: getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
            if (ownKeyPair == null) ownKeyPair = own
            return own.private as ECPrivateKey
        }

    override val peerPublicKey: ECPublicKey?
        get() = encryptedStore.peerPublicKey

    init {
        encryptedStore = EncryptedStore(
            fileName = "${host}_wallet_segue_key_store",
            context = appContext
        )
    }

    override fun storePeerPublicKey(key: ECPublicKey) {
        encryptedStore.peerPublicKey = key
    }

    override fun resetKeys() {
        encryptedStore.reset()

        // Create new KeyPair
        ownKeyPair = getOrCreateKeyPair(OWN_KEY_PAIR_ALIAS)
    }

    private fun deleteKeyPair(alias: String) {
        encryptedStore.deleteKeyPair(alias)
    }

    private fun getOrCreateKeyPair(alias: String): KeyPair {
        // If no keypair, generate new key pair and save to encrypted storage
        return encryptedStore.getKeyPair(alias) ?: generateKeyPair(alias)
    }

    private fun generateKeyPair(alias: String): KeyPair {
        return EllipticCurves.generateKeyPair(EllipticCurves.CurveType.NIST_P256).also {
            encryptedStore.saveKeyPair(alias, it)
        }
    }
}

interface IKeyManager {
    val ownPublicKey: ECPublicKey
    val ownPrivateKey: ECPrivateKey
    val peerPublicKey: ECPublicKey?

    fun storePeerPublicKey(key: ECPublicKey)
    fun resetKeys()
}
