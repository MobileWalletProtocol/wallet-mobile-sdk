package expo.modules.coinbasewalletsdkexpo

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import expo.modules.core.interfaces.ReactActivityLifecycleListener

class ActivityLifecycleListener : ReactActivityLifecycleListener {
    private var launcher: ActivityResultLauncher<Intent>? = null

    override fun onCreate(activity: Activity?, savedInstanceState: Bundle?) {
        super.onCreate(activity, savedInstanceState)

        val currentActivity = requireNotNull(activity as? AppCompatActivity) {
            "MobileWalletProtocol: activity must be AppCompatActivity"
        }

        launcher =
            currentActivity.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
                val uri = result.data?.data ?: return@registerForActivityResult
                CoinbaseWalletSDK.handleResponseUrl(uri)
            }

        CoinbaseWalletSDK.openIntent = { it -> launcher?.launch(it) }
    }

    override fun onDestroy(activity: Activity?) {
        super.onDestroy(activity)
        launcher = null
        CoinbaseWalletSDK.openIntent = null
    }
}