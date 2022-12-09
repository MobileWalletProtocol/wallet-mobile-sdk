package com.coinbase.android.nativesdk.message.request

import kotlinx.serialization.Serializable

@Serializable
data class Account(
    val chain: String,
    val networkId: Long,
    val address: String
)