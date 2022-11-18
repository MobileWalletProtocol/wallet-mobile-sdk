package com.coinbase.android.nativesdk.task

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.request.RequestMessage
import com.coinbase.android.nativesdk.message.response.ResponseContent
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import com.coinbase.android.nativesdk.message.response.ResponseMessage
import com.coinbase.android.nativesdk.message.response.ResponseResult

internal object TaskManager : ITaskManager {
    private val tasks: MutableMap<String, Task> = mutableMapOf()

    override fun registerResponseHandler(message: RequestMessage, handler: ResponseHandler, host: String) {
        tasks[message.uuid] = Task(
            request = message,
            host = host,
            handler = handler,
            timestamp = message.timestamp
        )
    }

    override fun handleResponse(message: ResponseMessage): Boolean {
        val requestId: String
        val result: ResponseResult = when (val response = message.content) {
            is ResponseContent.Response -> {
                requestId = response.requestId
                Result.success(response.values)
            }
            is ResponseContent.Failure -> {
                requestId = response.requestId
                Result.failure(CoinbaseWalletSDKError.WalletReturnedError(response.description))
            }
        }

        val task = tasks[requestId] ?: return false

        task.handler(result)
        tasks.remove(requestId)
        return true
    }

    override fun findRequestId(requestId: String): String? {
        return tasks[requestId]?.host
    }

    override fun reset(host: String) {
        tasks.forEach { (k, v) ->
            if (v.host == host) tasks.remove(k)
        }
    }
}

interface ITaskManager {
    fun registerResponseHandler(message: RequestMessage, handler: ResponseHandler, host: String)
    fun handleResponse(message: ResponseMessage): Boolean
    fun reset(host: String)
    fun findRequestId(requestId: String): String?
}