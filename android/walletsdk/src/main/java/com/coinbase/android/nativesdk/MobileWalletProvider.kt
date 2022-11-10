package com.coinbase.android.nativesdk

import android.content.Context
import kotlinx.serialization.Serializable

object MobileWalletProvider : MobileWalletProviderInterface {

    private val wallets = listOf(DefaultWallets.coinbaseWallet, DefaultWallets.coinbaseRetail)

    override suspend fun getWallets(): List<Wallet> = wallets
}

internal interface MobileWalletProviderInterface {
    suspend fun getWallets(): List<Wallet>
}

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
    val coinbaseWallet = Wallet(
        name = "Coinbase Wallet",
        iconUrl = "https://play-lh.googleusercontent.com/wrgUujbq5kbn4Wd4tzyhQnxOXkjiGqq39N4zBvCHmxpIiKcZw_Pb065KTWWlnoejsg",
        packageName = "org.toshi",
        url = "cbwallet://wsegue"
    )

    val coinbaseRetail = Wallet(
        name = "Coinbase",
        iconUrl = "https://play-lh.googleusercontent.com/PjoJoG27miSglVBXoXrxBSLveV6e3EeBPpNY55aiUUBM9Q1RCETKCOqdOkX2ZydqVf0",
        packageName = "org.toshi.debugger",
        // TODO: Replace with proper coinbase url
        url = "cbwallet22://wsegue"
    )
}
