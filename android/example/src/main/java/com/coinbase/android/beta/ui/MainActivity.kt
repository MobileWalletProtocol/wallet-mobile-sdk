package com.coinbase.android.beta.ui

import android.content.Intent
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.isVisible
import com.coinbase.android.beta.R
import com.coinbase.android.beta.databinding.ActivityMainBinding
import com.coinbase.android.beta.utils.ActionsManager
import com.coinbase.android.beta.utils.SharedPrefsManager
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import com.coinbase.android.nativesdk.Wallet
import com.coinbase.android.nativesdk.message.request.Account
import com.coinbase.android.nativesdk.message.request.Action
import com.coinbase.android.nativesdk.message.request.RequestContent
import com.coinbase.android.nativesdk.message.response.ActionResult
import com.google.android.material.shape.CornerFamily
import com.google.android.material.shape.MaterialShapeDrawable
import com.google.android.material.shape.ShapeAppearanceModel

class MainActivity : AppCompatActivity(), WalletPickerBottomSheetFragment.WalletSelectListener {

    private lateinit var binding: ActivityMainBinding
    private lateinit var launcher: ActivityResultLauncher<Intent>

    private val viewModel: MainActivityViewModel by viewModels()

    private fun processIntent(): (Intent) -> Unit = { intent: Intent ->
        launcher.launch(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        SharedPrefsManager.init(this)
        launcher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            val uri = result.data?.data ?: return@registerForActivityResult
            CoinbaseWalletSDK.handleResponse(uri)
        }
    }

    override fun onStart() = with(binding) {
        super.onStart()

        setVisibility()
        connectWalletButton.setOnClickListener {
            val walletPicker = WalletPickerBottomSheetFragment.newInstance(ModeRequestType.HANDSHAKE)
            walletPicker.show(supportFragmentManager, WalletPickerBottomSheetFragment::class.simpleName.toString())
        }

        personalSign.setOnClickListener {
            val walletPicker = WalletPickerBottomSheetFragment.newInstance(ModeRequestType.REQUEST)
            walletPicker.show(supportFragmentManager, WalletPickerBottomSheetFragment::class.simpleName.toString())
        }

        removeAccount.setOnClickListener {
            val walletPicker = WalletPickerBottomSheetFragment.newInstance(ModeRequestType.REMOVE_ACCOUNT)
            walletPicker.show(supportFragmentManager, WalletPickerBottomSheetFragment::class.simpleName.toString())
        }

        CoinbaseWalletSDK.openIntent = processIntent()
    }

    override fun onWalletSelected(wallet: Wallet, type: ModeRequestType) {
        val client = CoinbaseWalletSDK.getClient(wallet)
        when (type) {
            ModeRequestType.HANDSHAKE -> handleHandShake(wallet, client)
            ModeRequestType.REQUEST -> handleRequest(wallet, client)
            ModeRequestType.REMOVE_ACCOUNT -> handleRemoveAccount(wallet, client)
        }
    }

    private fun handleHandShake(wallet: Wallet, client: CoinbaseWalletSDK) {
        val handShakeActions = ActionsManager.handShakeActions
        client.initiateHandshake(
            initialActions = handShakeActions
        ) { result: Result<List<ActionResult>>, account: Account? ->
            result.onSuccess { actionResults: List<ActionResult> ->
                actionResults.handleSuccess(handShakeActions, account, wallet)
            }
            result.onFailure { err ->
                err.handleError("HandShake")
            }
        }
    }

    private fun handleRequest(wallet: Wallet, client: CoinbaseWalletSDK) {
        val requestActions = ActionsManager.getRequestActions(
            fromAddress = SharedPrefsManager.getAccount(wallet.name),
            toAddress = "0x571a6a108adb08f9ca54fe8605280f9ee0ed4af6",
        )
        client.makeRequest(request = RequestContent.Request(actions = requestActions)) { result ->
            result.fold(
                onSuccess = { returnValues ->
                    returnValues.handleSuccess(requestActions, wallet = wallet)
                },
                onFailure = { err ->
                    err.handleError("Request")
                }
            )
        }
    }

    private fun handleRemoveAccount(wallet: Wallet, client: CoinbaseWalletSDK) {
        client.resetSession()
        SharedPrefsManager.removeAccount(wallet.name)
        binding.textArea.setText(R.string.connection_removed)
        setVisibility()
    }

    private fun List<ActionResult>.handleSuccess(
        actions: List<Action>,
        account: Account? = null,
        wallet: Wallet? = null,
    ) = with(binding) {
        textArea.text = buildString {
            append("Response From: ")
            appendLine(wallet?.name)
            appendLine()
            if (actions.isEmpty()) {
                append("Handshake successful")
            } else {
                this@handleSuccess.forEachIndexed { index, returnValue ->
                    append(
                        "${actions[index].method} Result: " +
                                "${if (returnValue is ActionResult.Result) "Success" else "Error"}\n"
                    )

                    if (account != null && wallet != null) {
                        viewModel.persistWalletAccount(account, wallet)
                    }

                    val result = when (returnValue) {
                        is ActionResult.Result -> returnValue.value
                        is ActionResult.Error -> returnValue.message
                    }
                    append("${result}\n\n")
                }
            }
        }
        setVisibility()
    }

    private fun Throwable.handleError(requestType: String) = with(binding) {
        textArea.text = buildString {
            append("$requestType Error: \n\n")
            append(message)
        }
    }

    private fun setVisibility() = with(binding) {
        connectContainer.isVisible = true

        with(connectedStatus) {
            val radius = 28f
            val shapeAppearanceModel = ShapeAppearanceModel()
                .toBuilder()
                .setAllCorners(CornerFamily.ROUNDED, radius)
                .build()

            val shapeDrawable = MaterialShapeDrawable(shapeAppearanceModel)
            ViewCompat.setBackground(connectedStatus, shapeDrawable)

            // TODO: Add connected account info
//            if (isConnected) {
//                text = getString(
//                    R.string.connected_state,
//                    "${SharedPrefsManager.account.take(5)}...${SharedPrefsManager.account.takeLast(4)}"
//                )
//                setTextColor(getColor(R.color.teal_200))
//                shapeDrawable.setStroke(2.0f, getColor(R.color.teal_200))
//
//            } else {
//                setText(R.string.unconnected_state)
//                setTextColor(getColor(R.color.red_error))
//                shapeDrawable.setStroke(2.0f, getColor(R.color.red_error))
//            }
        }
    }
}
