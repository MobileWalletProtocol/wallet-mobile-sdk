package com.coinbase.android.nativesdk.message

import com.coinbase.android.nativesdk.key.PublicKeySerializer
import kotlinx.serialization.Serializable
import java.security.PublicKey
import java.util.Date

@Serializable
data class Message<Content>(
    val uuid: String,
    val version: String,
    @Serializable(with = PublicKeySerializer::class)
    val sender: PublicKey,
    val content: Content,
    @Serializable(with = DateSerializer::class)
    val timestamp: Date,
    val callbackUrl: String?
) {
    fun <T> copy(newContent: T): Message<T> {
        return Message(
            uuid = uuid,
            version = version,
            sender = sender,
            content = newContent,
            timestamp = timestamp,
            callbackUrl = callbackUrl
        )
    }
}