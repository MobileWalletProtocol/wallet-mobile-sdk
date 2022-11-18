package com.coinbase.android.beta.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.coinbase.android.beta.utils.SharedPrefsManager
import com.coinbase.android.nativesdk.DefaultWallets
import com.coinbase.android.nativesdk.Wallet
import com.coinbase.android.nativesdk.message.request.Account
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class MainActivityViewModel : ViewModel() {

    private val _state = MutableStateFlow<List<Wallet>>(emptyList())
    val state = _state.asStateFlow()

    init {
        refreshWallets()
    }

    private fun refreshWallets() {
        viewModelScope.launch {
            _state.update { DefaultWallets.getWallets() }
        }
    }

    fun persistWalletAccount(account: Account, wallet: Wallet) {
        SharedPrefsManager.setAccount(account.address, wallet.name)
    }
}
