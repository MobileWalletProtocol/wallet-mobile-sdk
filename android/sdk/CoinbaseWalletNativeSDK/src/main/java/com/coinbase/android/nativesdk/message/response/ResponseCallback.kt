package com.coinbase.android.nativesdk.message.response

import com.coinbase.android.nativesdk.message.request.Account

interface SuccessHandshakeResponseCallback {
    fun call(result: List<ReturnValue>, account: Account?)
}

interface SuccessRequestResponseCallback {
    fun call(result: List<ReturnValue>)
}

interface FailureResponseCallback {
    fun call(error: Throwable)
}
