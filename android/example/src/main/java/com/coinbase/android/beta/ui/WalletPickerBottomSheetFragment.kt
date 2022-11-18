package com.coinbase.android.beta.ui

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.lifecycleScope
import com.coinbase.android.beta.R
import com.coinbase.android.beta.databinding.BottomSheetBinding
import com.coinbase.android.beta.ui.adapter.WalletAdapter
import com.coinbase.android.beta.utils.SpacesItemDecoration
import com.coinbase.android.nativesdk.Wallet
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import kotlinx.coroutines.launch

class WalletPickerBottomSheetFragment : BottomSheetDialogFragment() {

    private val viewModel: MainActivityViewModel by activityViewModels()
    private lateinit var binding: BottomSheetBinding
    private lateinit var type: ModeRequestType
    private lateinit var listener: WalletSelectListener

    private val adapter: WalletAdapter by lazy {
        WalletAdapter { wallet ->
            this@WalletPickerBottomSheetFragment.dismiss()
            listener.onWalletSelected(wallet, type)
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = BottomSheetBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        type = ModeRequestType.valueOf(arguments?.getString(MODE_REQUEST_TYPE).orEmpty())

        val spacingInPixels = resources.getDimensionPixelSize(R.dimen.spacing)
        val marginSpacingInPixels = resources.getDimensionPixelSize(R.dimen.margin_spacing)
        with(binding.walletItems) {
            addItemDecoration(SpacesItemDecoration(spacingInPixels, marginSpacingInPixels))
            adapter = this@WalletPickerBottomSheetFragment.adapter
        }

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.state.collect {
                adapter.submitList(it)
            }
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = checkNotNull(activity as? WalletSelectListener)
    }

    interface WalletSelectListener {
        fun onWalletSelected(wallet: Wallet, type: ModeRequestType)
    }

    companion object {
        private const val MODE_REQUEST_TYPE = "MODE_REQUEST_TYPE"

        fun newInstance(requestType: ModeRequestType): WalletPickerBottomSheetFragment {
            return WalletPickerBottomSheetFragment().apply {
                arguments = bundleOf(MODE_REQUEST_TYPE to requestType.name)
            }
        }
    }
}

enum class ModeRequestType {
    HANDSHAKE,
    REQUEST,
    REMOVE_ACCOUNT
}