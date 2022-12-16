package com.coinbase.android.nativesdk

import kotlinx.serialization.Serializable

@Serializable
data class Wallet(
    val name: String,
    val iconUrl: String,
    val packageName: String,
    val url: String
) {
    val appStoreUrl: String
        get() = "https://play.google.com/store/apps/details?id=$packageName"
}

object DefaultWallets {

    @JvmField
    val coinbaseWallet = Wallet(
        name = "Coinbase Wallet",
        iconUrl = "https://wallet.coinbase.com/assets/images/favicon.ico",
        packageName = "org.toshi",
        url = "cbwallet://wsegue"
    )

    @JvmField
    val coinbaseRetail = Wallet(
        name = "Coinbase",
        iconUrl = "https://www.coinbase.com/img/favicon/favicon-256.png",
        packageName = "org.toshi.debugger",
        // TODO: Replace with proper coinbase url
        url = "cbwallet22://wsegue"
    )

    @JvmStatic
    fun getWallets(): List<Wallet> = listOf(coinbaseWallet, coinbaseRetail)
}
