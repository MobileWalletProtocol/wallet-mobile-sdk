package com.coinbase.android.beta.utils

import com.coinbase.android.nativesdk.message.request.Web3JsonRPC

object ActionsManager {

    private val requestAccount = Web3JsonRPC.RequestAccounts().action()

    private val personalSign = Web3JsonRPC.PersonalSign("", "Hello world").action()

    private val switchEthereumChain = Web3JsonRPC.SwitchEthereumChain("137").action()

    val addEthereumChain = Web3JsonRPC.AddEthereumChain("172222").action()

    private fun getSignTransaction(fromAddress: String, toAddress: String) = Web3JsonRPC.SignTransaction(
        fromAddress = fromAddress,
        toAddress = toAddress,
        weiValue = "10000000000000",
        data = "0x",
        nonce = null,
        gasPriceInWei = null,
        maxFeePerGas = null,
        maxPriorityFeePerGas = null,
        gasLimit = "1000",
        chainId = "1",
    ).action()

    private fun getSendTransaction(fromAddress: String, toAddress: String) = Web3JsonRPC.SendTransaction(
        fromAddress = fromAddress,
        toAddress = toAddress,
        weiValue = "10000000000000",
        data = "0x",
        nonce = null,
        gasPriceInWei = null,
        maxFeePerGas = null,
        maxPriorityFeePerGas = null,
        gasLimit = "1000",
        chainId = "1",
    ).action()

    val signTypedDataV3 = Web3JsonRPC.SignTypedDataV3("0xabcdefabcdefabcdefabcdefabcdefabcdef", "").action()

    val handShakeActions = listOf(requestAccount, personalSign)

    fun getRequestActions(
        fromAddress: String,
        toAddress: String
    ) = listOf(
        requestAccount,
        personalSign,
        switchEthereumChain,
        getSendTransaction(fromAddress, toAddress)
    )
}
