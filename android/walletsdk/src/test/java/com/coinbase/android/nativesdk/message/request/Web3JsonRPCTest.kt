package com.coinbase.android.nativesdk.message.request

import com.coinbase.android.nativesdk.helper.readFileWithNewLineFromResources
import io.kotest.matchers.shouldBe
import org.junit.Test

private const val typedData =
    "{\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"version\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"},{\"name\":\"salt\",\"type\":\"bytes32\"}],\"Bid\":[{\"name\":\"amount\",\"type\":\"uint256\"},{\"name\":\"bidder\",\"type\":\"Identity\"}],\"Identity\":[{\"name\":\"userId\",\"type\":\"uint256\"},{\"name\":\"wallet\",\"type\":\"address\"}]},\"domain\":{\"name\":\"DApp Browser Test DApp\",\"version\":\"1\",\"chainId\":1,\"verifyingContract\":\"0x1C56346CD2A2Bf3202F771f50d3D14a367B48070\",\"salt\":\"0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a558\"},\"primaryType\":\"Bid\",\"message\":{\"amount\":100,\"bidder\":{\"userId\":323,\"wallet\":\"0x3333333333333333333333333333333333333333\"}}}"

class Web3JsonRPCTest {

    @Test
    fun action_Test_Eth_Request_Accounts_Action() {
        val expectedAction = Action(
            method = "eth_requestAccounts",
            paramsJson = "{\"#wsegue_type\":\"eth_requestAccounts\"}",
            optional = false
        )

        val action = Web3JsonRPC.RequestAccounts().action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Personal_Sign_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("personal_sign.json")
        val personalSignJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = "personal_sign",
            paramsJson = personalSignJson,
            optional = false
        )

        val action = Web3JsonRPC.PersonalSign("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", "hello").action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Sign_TypedData_V3_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("sign_typed_data_v3.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = "eth_signTypedData_v3",
            paramsJson = paramsJson.replace("DAppBrowserTestDApp", "DApp Browser Test DApp"),
            optional = false
        )
        val action = Web3JsonRPC.SignTypedDataV3("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", typedData).action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Sign_TypedData_V4_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("sign_typed_data_v4.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = "eth_signTypedData_v4",
            paramsJson = paramsJson.replace("DAppBrowserTestDApp", "DApp Browser Test DApp"),
            optional = false
        )

        val action = Web3JsonRPC.SignTypedDataV4("0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", typedData).action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Sign_Transaction_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("sign_transaction.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = ETH_SIGN_TRANSACTION,
            paramsJson = paramsJson,
            optional = false
        )

        val action = Web3JsonRPC.SignTransaction(
            fromAddress = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            toAddress = "0x571a6a108adb08f9ca54fe8605280f9ee0ed4af6",
            weiValue = "10000000000000",
            data = "0x",
            nonce = null,
            gasPriceInWei = null,
            maxFeePerGas = null,
            maxPriorityFeePerGas = null,
            gasLimit = "1000",
            chainId = "1",
        ).action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Send_Transaction_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("send_transaction.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = ETH_SEND_TRANSACTION,
            paramsJson = paramsJson,
            optional = false
        )

        val action = Web3JsonRPC.SendTransaction(
            fromAddress = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            toAddress = "0x571a6a108adb08f9ca54fe8605280f9ee0ed4af6",
            weiValue = "10000000000000",
            data = "0x",
            nonce = null,
            gasPriceInWei = null,
            maxFeePerGas = null,
            maxPriorityFeePerGas = null,
            gasLimit = "1000",
            chainId = "1",
        ).action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Switch_Chain_Action() {
        val expectedAction = Action(
            method = WALLET_SWITCH_ETHEREUM_CHAIN,
            paramsJson = "{\"#wsegue_type\":\"wallet_switchEthereumChain\",\"chainId\":\"1\"}",
            optional = false
        )

        val action = Web3JsonRPC.SwitchEthereumChain(chainId = "1").action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Add_Chain_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("add_chain.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = WALLET_ADD_ETHEREUM_CHAIN,
            paramsJson = paramsJson,
            optional = false
        )

        val action = Web3JsonRPC.AddEthereumChain(chainId = "137").action()
        action shouldBe expectedAction
    }

    @Test
    fun action_Test_Watch_Asset_Action() {
        val inputStream = javaClass.classLoader?.getResourceAsStream("watch_asset.json")
        val paramsJson = inputStream.readFileWithNewLineFromResources()
        val expectedAction = Action(
            method = WALLET_WATCH_ASSET,
            paramsJson = paramsJson,
            optional = false
        )

        val action = Web3JsonRPC.WatchAsset(
            type = "type",
            options = WatchAssetOptions(
                address = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                symbol = "APE",
                decimals = 3,
                image = "image_site"
            )
        ).action()
        action shouldBe expectedAction
    }
}
