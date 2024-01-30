package de.skycoder42.wearTasks

import android.view.MotionEvent
import androidx.core.view.InputDeviceCompat
import androidx.core.view.MotionEventCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var rotaryInput: RotaryInput? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        rotaryInput = RotaryInput(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        rotaryInput = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        if (rotaryInput == null) {
            return false
        } else if (
            event != null &&
            event.action == MotionEvent.ACTION_SCROLL &&
            event.isFromSource(InputDeviceCompat.SOURCE_ROTARY_ENCODER)
        ) {
            val scrollAxisValue = event.getAxisValue(MotionEventCompat.AXIS_SCROLL)
            rotaryInput!!.handleRotaryEvent(RotaryEvent(scrollAxisValue.toDouble())) {}
            return true
        }

        return super.onGenericMotionEvent(event)
    }
}
