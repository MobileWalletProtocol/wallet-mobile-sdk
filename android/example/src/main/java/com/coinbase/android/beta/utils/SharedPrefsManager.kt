package com.coinbase.android.beta.utils

import android.content.Context
import android.content.SharedPreferences

object SharedPrefsManager {
    lateinit var sharedPrefs: SharedPreferences

    fun getAccount(walletName: String): String {
        return sharedPrefs.getString("${walletName}_eth_account", "").orEmpty()
    }

    fun setAccount(address: String, walletName: String) {
        with(sharedPrefs.edit()) {
            putString("${walletName}_eth_account", address)
            apply()
        }
    }

    fun init(context: Context) {
        sharedPrefs = context.getSharedPreferences("DEMO_APP", Context.MODE_PRIVATE)
    }

    fun removeAccount(walletName: String) {
        with(sharedPrefs.edit()) {
            remove("${walletName}_eth_account")
            apply()
        }
    }
}