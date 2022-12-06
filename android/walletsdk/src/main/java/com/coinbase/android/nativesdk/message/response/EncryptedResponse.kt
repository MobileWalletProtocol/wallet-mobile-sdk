package com.coinbase.android.nativesdk.message.response

import kotlinx.serialization.Serializable

@Serializable
internal class EncryptedResponse(
    val requestId: String,
    val data: String
)