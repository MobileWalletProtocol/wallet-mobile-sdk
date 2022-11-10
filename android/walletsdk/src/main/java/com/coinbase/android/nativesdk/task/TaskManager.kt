package com.coinbase.android.nativesdk.task

import com.coinbase.android.nativesdk.CoinbaseWalletSDKError
import com.coinbase.android.nativesdk.message.request.RequestMessage
import com.coinbase.android.nativesdk.message.response.ResponseContent
import com.coinbase.android.nativesdk.message.response.ResponseHandler
import com.coinbase.android.nativesdk.message.response.ResponseMessage
import com.coinbase.android.nativesdk.message.response.ResponseResult

internal class TaskManager : ITaskManager {
    private val tasks = HashMap<String, Task>()

    override fun registerResponseHandler(message: RequestMessage, handler: ResponseHandler) {
        tasks[message.uuid] = Task(
            request = message,
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

    override fun reset() {
        tasks.clear()
    }
}

interface ITaskManager {
    fun registerResponseHandler(message: RequestMessage, handler: ResponseHandler)
    fun handleResponse(message: ResponseMessage): Boolean
    fun reset()
}