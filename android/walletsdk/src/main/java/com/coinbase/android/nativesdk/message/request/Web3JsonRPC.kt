package com.coinbase.android.nativesdk.message.request

import com.coinbase.android.nativesdk.message.JSON
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString

private typealias BigInt = String

const val ETH_REQUEST_ACCOUNTS = "eth_requestAccounts"
const val PERSONAL_SIGN = "personal_sign"
const val ETH_SIGN_TYPED_DATA_V3 = "eth_signTypedData_v3"
const val ETH_SIGN_TYPED_DATA_V4 = "eth_signTypedData_v4"
const val ETH_SIGN_TRANSACTION = "eth_signTransaction"
const val ETH_SEND_TRANSACTION = "eth_sendTransaction"
const val WALLET_SWITCH_ETHEREUM_CHAIN = "wallet_switchEthereumChain"
const val WALLET_ADD_ETHEREUM_CHAIN = "wallet_addEthereumChain"
const val WALLET_WATCH_ASSET = "wallet_watchAsset"

val unsupportedHandshakeActions = listOf(ETH_SEND_TRANSACTION, ETH_SIGN_TRANSACTION)

@Serializable
sealed class Web3JsonRPC {

    @Serializable
    @SerialName(ETH_REQUEST_ACCOUNTS)
    class RequestAccounts : Web3JsonRPC()

    @Serializable
    @SerialName(PERSONAL_SIGN)
    data class PersonalSign(
        val address: String,
        val message: String
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(ETH_SIGN_TYPED_DATA_V3)
    data class SignTypedDataV3(
        val address: String,
        val typedDataJson: String
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(ETH_SIGN_TYPED_DATA_V4)
    data class SignTypedDataV4(
        val address: String,
        val typedDataJson: String
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(ETH_SIGN_TRANSACTION)
    data class SignTransaction(
        val fromAddress: String,
        val toAddress: String?,
        val weiValue: BigInt,
        val data: String,
        val nonce: Int?,
        val gasPriceInWei: BigInt?,
        val maxFeePerGas: BigInt?,
        val maxPriorityFeePerGas: BigInt?,
        val gasLimit: BigInt?,
        val chainId: String
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(ETH_SEND_TRANSACTION)
    data class SendTransaction(
        val fromAddress: String,
        val toAddress: String?,
        val weiValue: BigInt,
        val data: String,
        val nonce: Int?,
        val gasPriceInWei: BigInt?,
        val maxFeePerGas: BigInt?,
        val maxPriorityFeePerGas: BigInt?,
        val gasLimit: BigInt?,
        val chainId: String
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(WALLET_SWITCH_ETHEREUM_CHAIN)
    data class SwitchEthereumChain(val chainId: String) : Web3JsonRPC()

    @Serializable
    @SerialName(WALLET_ADD_ETHEREUM_CHAIN)
    data class AddEthereumChain(
        val chainId: String,
        val blockExplorerUrls: List<String>? = null,
        val chainName: String? = null,
        val iconUrls: List<String>? = null,
        val nativeCurrency: AddChainNativeCurrency? = null,
        val rpcUrls: List<String> = emptyList()
    ) : Web3JsonRPC()

    @Serializable
    @SerialName(WALLET_WATCH_ASSET)
    data class WatchAsset(
        val type: String,
        val options: WatchAssetOptions
    ) : Web3JsonRPC()

    internal val asJson: Pair<String, String>
        get() {
            val json = JSON.encodeToString(this)
            val method = when (this) {
                is RequestAccounts -> ETH_REQUEST_ACCOUNTS
                is SendTransaction -> ETH_SEND_TRANSACTION
                is SignTransaction -> ETH_SIGN_TRANSACTION
                is PersonalSign -> PERSONAL_SIGN
                is SignTypedDataV3 -> ETH_SIGN_TYPED_DATA_V3
                is SignTypedDataV4 -> ETH_SIGN_TYPED_DATA_V4
                is AddEthereumChain -> WALLET_ADD_ETHEREUM_CHAIN
                is SwitchEthereumChain -> WALLET_SWITCH_ETHEREUM_CHAIN
                is WatchAsset -> WALLET_WATCH_ASSET
            }

            return method to json
        }

    fun action(optional: Boolean = false): Action = Action(rpc = this, optional = optional)
}

@Serializable
data class AddChainNativeCurrency(val name: String, val symbol: String, val decimals: Int)

@Serializable
data class WatchAssetOptions(val address: String, val symbol: String?, val decimals: Int?, val image: String?)
