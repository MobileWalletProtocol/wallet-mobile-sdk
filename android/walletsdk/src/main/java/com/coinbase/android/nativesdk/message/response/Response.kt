package com.coinbase.android.nativesdk.message.response

typealias ResponseResult = Result<List<ActionResult>>
typealias ResponseHandler = (ResponseResult) -> Unit