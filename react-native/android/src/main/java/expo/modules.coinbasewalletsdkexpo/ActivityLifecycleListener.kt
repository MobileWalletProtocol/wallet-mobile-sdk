package expo.modules.coinbasewalletsdkexpo

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import expo.modules.core.interfaces.ReactActivityLifecycleListener

object IntentLauncher {
    var launcher: ActivityResultLauncher<Intent>? = null
    var onResult: ((Uri) -> Unit)? = null
}

class ActivityLifecycleListener : ReactActivityLifecycleListener {
    override fun onCreate(activity: Activity?, savedInstanceState: Bundle?) {
        super.onCreate(activity, savedInstanceState)

        val currentActivity = requireNotNull(activity as? AppCompatActivity) {
            "CoinbaseWalletSDK: activity must be AppCompatActivity"
        }

        IntentLauncher.launcher =
            currentActivity.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
                val uri = result.data?.data ?: return@registerForActivityResult
                IntentLauncher.onResult?.invoke(uri)
            }
    }
}