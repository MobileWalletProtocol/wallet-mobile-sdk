package com.coinbase.android.nativesdk.message.request

import kotlinx.serialization.Serializable

@Serializable
data class Action(
    val method: String,
    val paramsJson: String,
    val optional: Boolean = false
) {
    companion object {
        operator fun invoke(rpc: Web3JsonRPC, optional: Boolean = false): Action {
            val (method, paramsJson) = rpc.asJson
            return Action(method, paramsJson, optional)
        }
    }
}