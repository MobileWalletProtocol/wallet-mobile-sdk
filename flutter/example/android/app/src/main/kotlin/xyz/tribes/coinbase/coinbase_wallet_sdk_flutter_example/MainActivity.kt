package xyz.tribes.coinbase.coinbase_wallet_sdk_flutter_example

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.coinbase.android.nativesdk.CoinbaseWalletSDK
import io.flutter.embedding.android.FlutterActivity
import androidx.activity.result.ActivityResultLauncher

class MainActivity: FlutterActivity() {
    private lateinit var launcher: ActivityResultLauncher<Intent>

    private val client by lazy {
        CoinbaseWalletSDK(
            appContext = applicationContext,
            domain = Uri.parse("https://www.coinbase.com"),
            openIntent = { intent -> launcher.launch(intent) }
        )
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        launcher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
//            val uri = result.data?.data ?: return@registerForActivityResult
//            client.handleResponse(uri)
//        }
    }

}
