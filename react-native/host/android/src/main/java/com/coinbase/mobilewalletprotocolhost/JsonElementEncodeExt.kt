package com.coinbase.mobilewalletprotocolhost

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableMap
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.float
import kotlinx.serialization.json.floatOrNull
import kotlinx.serialization.json.int
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.long
import kotlinx.serialization.json.longOrNull

fun JsonObject.asReadableMap(): WritableMap {
    val map = Arguments.createMap()
    for (key in keys) {
        when (val value = getValue(key)) {
            JsonNull -> map.putNull(key)
            is JsonObject -> map.putMap(key, value.asReadableMap())
            is JsonArray -> map.putArray(key, value.asReadableArray())
            is JsonPrimitive -> {
                value.fold(
                    onInt = { map.putInt(key, it) },
                    onDouble = { map.putDouble(key, it) },
                    onBoolean = { map.putBoolean(key, it) },
                    onString = { map.putString(key, it) }
                )
            }
        }
    }

    return map
}

fun JsonArray.asReadableArray(): WritableArray {
    val array = Arguments.createArray()
    this.forEach { element ->
        when (element) {
            JsonNull -> array.pushNull()
            is JsonObject -> array.pushMap(element.asReadableMap())
            is JsonArray -> array.pushArray(element.asReadableArray())
            is JsonPrimitive -> {
                element.fold(
                    onInt = { array.pushInt(it) },
                    onDouble = { array.pushDouble(it) },
                    onBoolean = { array.pushBoolean(it) },
                    onString = { array.pushString(it) }
                )
            }
        }
    }

    return array
}

private fun JsonPrimitive.fold(
    onInt: (Int) -> Unit,
    onDouble: (Double) -> Unit,
    onBoolean: (Boolean) -> Unit,
    onString: (String) -> Unit
) {
    if (intOrNull != null) {
        onInt(int)
    } else if (longOrNull != null) {
        onDouble(long.toDouble())
    } else if (floatOrNull != null) {
        onDouble(float.toDouble())
    } else if (booleanOrNull != null) {
        onBoolean(boolean)
    } else if (contentOrNull != null) {
        onString(content)
    }
}
