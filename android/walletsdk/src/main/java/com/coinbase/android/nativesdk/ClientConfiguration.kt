package com.coinbase.android.nativesdk

import android.content.Context
import android.net.Uri

object ClientConfiguration {

    lateinit var config: Configuration

    fun configure(domain: Uri, context: Context, appName: String?, appIconUrl: String?) {
        config = Configuration(
            domain = if (domain.pathSegments.size < 2) {
                domain.buildUpon()
                    .appendPath("wsegue")
                    .build()
            } else {
                domain
            },
            context = context,
            name = appName ?: context.getAppName(),
            iconUrl = appIconUrl
        )
    }

    data class Configuration(
        val domain: Uri,
        val context: Context,
        val name: String,
        val iconUrl: String? = null
    )
}

private fun Context.getAppName(): String = applicationInfo.loadLabel(packageManager).toString()
