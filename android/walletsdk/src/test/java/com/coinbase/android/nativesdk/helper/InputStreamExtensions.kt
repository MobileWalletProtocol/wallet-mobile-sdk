package com.coinbase.android.nativesdk.helper

import java.io.IOException
import java.io.InputStream

@Throws(IOException::class)
fun InputStream?.readFileWithNewLineFromResources(): String {
    return this?.bufferedReader()
        .use { bufferReader ->
            val builder = StringBuilder()
            var str: String? = bufferReader?.readLine()
            while (str != null) {
                builder.append(str)
                str = bufferReader?.readLine()
            }
            builder.toString().replace(" ", "")
        }
}

