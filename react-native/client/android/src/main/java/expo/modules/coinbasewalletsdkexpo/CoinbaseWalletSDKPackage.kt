package expo.modules.coinbasewalletsdkexpo

import android.content.Context
import expo.modules.core.interfaces.Package
import expo.modules.core.interfaces.ReactActivityLifecycleListener

class CoinbaseWalletSDKPackage : Package {
    override fun createReactActivityLifecycleListeners(activityContext: Context?): List<ReactActivityLifecycleListener> {
        return listOf(ActivityLifecycleListener())
    }
}