package com.coinbase.android.beta

import android.app.Application
import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK

class ExampleApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        CoinbaseWalletSDK.configure(
            domain = Uri.parse("myappxyz://mycallback"),
            context = this,
            appName = getString(R.string.app_name),
            appIconUrl = null
        )
    }
}