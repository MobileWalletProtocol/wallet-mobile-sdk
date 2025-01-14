import android.app.KeyguardManager
import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import android.util.Log
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys
import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.google.crypto.tink.subtle.Base64
import com.google.crypto.tink.subtle.EllipticCurves
import java.security.KeyPair
import java.security.KeyStore
import java.security.interfaces.ECPublicKey

private const val DEPRECATED_MAIN_KEY_ALIAS = "wallet_segue_main_key"
private const val HAS_MIGRATED_TO_VERSION_120_ALIAS = "has_migrated_to_version_1.2.0"

private const val PUBLIC_KEY_ALIAS = "public_key"
private const val PRIVATE_KEY_ALIAS = "private_key"
private const val PEER_PUBLIC_KEY_ALIAS = "peer_public_key"
private const val OWN_KEY_PAIR_ALIAS = "own_key_pair"

class KeyStore(
    private val fileName: String,
    private val context: Context
) {
    private val storage: SharedPreferences

    var peerPublicKey: ECPublicKey?
        get() {
            val encoded = storage.getString(PEER_PUBLIC_KEY_ALIAS, null) ?: return null
            val bytes = Base64.decode(encoded)
            return EllipticCurves.getEcPublicKey(bytes)
        }
        set(value) {
            if (value != null) {
                val encoded = Base64.encode(value.encoded)
                storage.edit()
                    .putString(PEER_PUBLIC_KEY_ALIAS, encoded)
                    .commit()
            }
        }

    init {
        storage = getSharedPrefs()
    }

    fun getKeyPair(alias: String): KeyPair? {
        val publicKeyAlias = "${alias}-${PUBLIC_KEY_ALIAS}"
        val privateKeyAlias = "${alias}-${PRIVATE_KEY_ALIAS}"

        val publicKeyB64 = storage.getString(publicKeyAlias, null)
        val privateKeyB64 = storage.getString(privateKeyAlias, null)

        return if (publicKeyB64 != null && privateKeyB64 != null) {
            // Already have keys in encrypted storage
            val publicKeyBytes = Base64.decode(publicKeyB64)
            val privateKeyBytes = Base64.decode(privateKeyB64)

            KeyPair(
                EllipticCurves.getEcPublicKey(publicKeyBytes),
                EllipticCurves.getEcPrivateKey(privateKeyBytes)
            )
        } else {
            null
        }
    }

    fun saveKeyPair(alias: String, keyPair: KeyPair) {
        val publicKeyAlias = "${alias}-${PUBLIC_KEY_ALIAS}"
        val privateKeyAlias = "${alias}-${PRIVATE_KEY_ALIAS}"

        storage
            .edit()
            .putString(publicKeyAlias, Base64.encode(keyPair.public.encoded))
            .putString(privateKeyAlias, Base64.encode(keyPair.private.encoded))
            .commit()
    }

    fun deleteKeyPair(alias: String) {
        val publicKeyAlias = "${alias}-${PUBLIC_KEY_ALIAS}"
        val privateKeyAlias = "${alias}-${PRIVATE_KEY_ALIAS}"

        storage.edit()
            .remove(publicKeyAlias)
            .remove(privateKeyAlias)
            .commit()
    }

    fun reset() {
        val publicKeyAlias = "${OWN_KEY_PAIR_ALIAS}-${PUBLIC_KEY_ALIAS}"
        val privateKeyAlias = "${OWN_KEY_PAIR_ALIAS}-${PRIVATE_KEY_ALIAS}"

        storage.edit()
            .remove(publicKeyAlias)
            .remove(privateKeyAlias)
            .remove(PEER_PUBLIC_KEY_ALIAS)
            .commit()
    }

    private fun getSharedPrefs(): SharedPreferences {
        val sharedPrefs = context.getSharedPreferences("${fileName}_raw", Context.MODE_PRIVATE)
        val hasMigratedToVersion120 = sharedPrefs.getBoolean(HAS_MIGRATED_TO_VERSION_120_ALIAS, false)

        if (!hasMigratedToVersion120) {
            try {
                // Perform the migration
                migrateEncryptedPrefs(sharedPrefs)
            } catch (e: Exception) {
                // Clear Shared Prefs State
                sharedPrefs.edit().clear().commit()
            } finally {
                // Mark as migrated
                sharedPrefs.edit().putBoolean(HAS_MIGRATED_TO_VERSION_120_ALIAS, true).commit()
            }
        }

        return sharedPrefs
    }

    private fun migrateEncryptedPrefs(newPrefs: SharedPreferences) {
        // 1. Open the old EncryptedSharedPreferences
        val encryptedPrefs = getEncryptedPrefs()

        // 2. Copy all string typed key-value pairs from encrypted prefs to new prefs in plain text
        val allEntries = encryptedPrefs.all
        for ((key, value) in allEntries) {
            if (value != null) {
                when (value) {
                    is String  -> newPrefs.edit().putString(key, value).commit()
                }
            }
        }

        // 3. Clear the old EncryptedSharedPreferences
        encryptedPrefs.edit().clear().commit()
    }

    private fun getEncryptedPrefs(): SharedPreferences {
        // Create main key that secures encrypted storage
        val purposes = KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT

        val keyGenSpec = with(KeyGenParameterSpec.Builder(DEPRECATED_MAIN_KEY_ALIAS, purposes)) {
            val keyguard = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            if (keyguard.isDeviceSecure) {
                setUserAuthenticationRequired(true)
                setUserAuthenticationValidityDurationSeconds(172_800) // 2 days
            }

            setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            setKeySize(256)
            build()
        }

        val mainKey = MasterKeys.getOrCreate(keyGenSpec)

        return EncryptedSharedPreferences.create(
            fileName,
            mainKey,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }
}