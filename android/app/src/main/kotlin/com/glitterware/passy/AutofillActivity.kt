package com.glitterware.passy

import io.flutter.embedding.android.FlutterFragmentActivity
import co.infinum.goldfinger.Goldfinger
import android.os.Bundle
import android.content.SharedPreferences

class AutofillActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Goldfinger.Builder(this).build()
    }

    override fun getDartEntrypointFunctionName(): String {
        return "autofillEntryPoint"
    }

    override fun getPreferences(mode : Int) : SharedPreferences {
        return getSharedPreferences("MainActivity", MODE_PRIVATE);
    }
}
