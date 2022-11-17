package com.coinbase.mobilewalletprotocolhost

import android.content.pm.PackageManager
import android.os.Build
import java.security.MessageDigest

fun PackageManager.getApplicationSignatures(packageName: String): List<String> {
    try {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signingInfo = getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo
            if (signingInfo.hasMultipleSigners()) {
                // Send all with apkContentSigners
                signingInfo.apkContentsSigners.map { sha256(it.toByteArray()) }
            } else {
                // Send one with signingCertificateHistory
                signingInfo.signingCertificateHistory.map { sha256(it.toByteArray()) }
            }
        } else {
            val signatures = getPackageInfo(packageName, PackageManager.GET_SIGNATURES).signatures
            signatures.map { sha256(it.toByteArray()) }
        }
    } catch (e: Throwable) {
        return emptyList()
    }
}

private fun sha256(bytes: ByteArray): String {
    val digest = MessageDigest.getInstance("SHA-256")
    digest.update(bytes)
    return digest.digest().bytesToHex()
}

private fun ByteArray.bytesToHex(): String {
    val hexArray = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F')
    val hexChars = CharArray((size * 3) - 1)
    var v: Int
    for (j in indices) {
        v = this[j].toInt() and 0xFF
        hexChars[j * 3] = hexArray[v.ushr(4)]
        hexChars[j * 3 + 1] = hexArray[v and 0x0F]
        if (j < lastIndex) {
            hexChars[j * 3 + 2] = ':'
        }
    }
    return String(hexChars)
}
