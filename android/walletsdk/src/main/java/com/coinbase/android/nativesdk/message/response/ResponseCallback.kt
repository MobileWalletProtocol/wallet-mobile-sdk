package com.coinbase.android.nativesdk.message.response

import com.coinbase.android.nativesdk.message.request.Account

interface SuccessHandshakeResponseCallback {
    fun call(result: List<ActionResult>, account: Account?)
}

interface SuccessRequestResponseCallback {
    fun call(result: List<ActionResult>)
}

interface FailureResponseCallback {
    fun call(error: Throwable)
}
