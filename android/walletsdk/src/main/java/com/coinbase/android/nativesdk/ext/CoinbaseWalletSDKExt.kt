package com.coinbase.android.nativesdk.ext

import android.content.Context
import com.coinbase.android.nativesdk.Wallet

fun Wallet.isInstalled(context: Context): Boolean {
    return context.packageManager.getLaunchIntentForPackage(packageName) != null
}
