package com.coinbase.android.nativesdk.task

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.request.UnencryptedRequestMessage
import com.coinbase.android.nativesdk.message.response.ResponseContent
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import com.coinbase.android.nativesdk.message.response.ResponseResult
import com.coinbase.android.nativesdk.message.response.UnencryptedResponseMessage

internal object TaskManager : ITaskManager {
    private val tasks: MutableMap<String, Task> = mutableMapOf()

    override fun registerResponseHandler(message: UnencryptedRequestMessage, handler: ResponseHandler, host: String) {
        tasks[message.uuid] = Task(
            request = message,
            host = host,
            handler = handler,
            timestamp = message.timestamp
        )
    }

    override fun handleResponse(message: UnencryptedResponseMessage): Boolean {
        val requestId: String
        val result: ResponseResult = when (val response = message.content.sealed) {
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

    override fun findTask(requestId: String): Task? {
        return tasks[requestId]
    }

    override fun reset(host: String) {
        tasks.forEach { (k, v) ->
            if (v.host == host) tasks.remove(k)
        }
    }
}

internal interface ITaskManager {
    fun registerResponseHandler(message: UnencryptedRequestMessage, handler: ResponseHandler, host: String)
    fun handleResponse(message: UnencryptedResponseMessage): Boolean
    fun findTask(requestId: String): Task?
    fun reset(host: String)
}