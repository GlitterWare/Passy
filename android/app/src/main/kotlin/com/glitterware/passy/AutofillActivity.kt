package com.glitterware.passy

import io.flutter.embedding.android.FlutterActivity

class AutofillActivity: FlutterActivity() {

    override fun getDartEntrypointFunctionName(): String {
        return "autofillEntryPoint"
    }
}
