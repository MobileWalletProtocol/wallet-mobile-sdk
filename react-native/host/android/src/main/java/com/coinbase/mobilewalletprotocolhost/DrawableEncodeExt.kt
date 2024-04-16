package com.coinbase.mobilewalletprotocolhost

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.util.Base64
import androidx.core.graphics.drawable.toBitmapOrNull
import java.io.ByteArrayOutputStream

fun Drawable.asBase64EncodedString(): String? {
    val bitmap = toBitmapOrNull() ?: return null
    val output = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, output)
    return Base64.encodeToString(output.toByteArray(), Base64.DEFAULT)
}
