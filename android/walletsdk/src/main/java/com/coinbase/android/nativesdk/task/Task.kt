package com.coinbase.android.nativesdk.task

import com.coinbase.android.nativesdk.message.request.UnencryptedRequestMessage
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import java.util.Date

internal class Task(
    val request: UnencryptedRequestMessage,
    val handler: ResponseHandler,
    val timestamp: Date
)