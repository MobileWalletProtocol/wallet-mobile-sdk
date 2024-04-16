package com.coinbase.android.beta

import android.app.Application
import android.net.Uri
import com.coinbase.android.nativesdk.CoinbaseWalletSDK

class ExampleApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        CoinbaseWalletSDK.configure(Uri.parse("myappxyz://mycallback"), this)
    }
}