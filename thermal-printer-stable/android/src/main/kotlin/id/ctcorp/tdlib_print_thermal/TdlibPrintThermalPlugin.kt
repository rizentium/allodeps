package id.ctcorp.tdlib_print_thermal

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.zxing.BarcodeFormat
import com.google.zxing.MultiFormatWriter
import com.journeyapps.barcodescanner.BarcodeEncoder
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.io.*
import java.util.*

class TdlibPrintThermalPlugin internal constructor(private val registrar: Registrar) : MethodCallHandler, RequestPermissionsResultListener {
    private var mBluetoothAdapter: BluetoothAdapter? = null
    private var pendingResult: MethodChannel.Result? = null
    private var readSink: EventSink? = null
    private var statusSink: EventSink? = null

    // MethodChannel.Result wrapper that responds on the platform thread.
    private class MethodResultWrapper internal constructor(private val methodResult: MethodChannel.Result) : MethodChannel.Result {
        private val handler: Handler
        override fun success(result: Any?) {
            handler.post { methodResult.success(result) }
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post { methodResult.error(errorCode, errorMessage, errorDetails) }
        }

        override fun notImplemented() {
            handler.post { methodResult.notImplemented() }
        }

        init {
            handler = Handler(Looper.getMainLooper())
        }
    }

    override fun onMethodCall(call: MethodCall, rawResult: MethodChannel.Result) {
        val result: MethodChannel.Result = MethodResultWrapper(rawResult)
        if (mBluetoothAdapter == null && "isAvailable" != call.method) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null)
            return
        }
        val arguments = call.arguments<Map<String, Any?>>()
        when (call.method) {
            "isAvailable" -> result.success(mBluetoothAdapter != null)
            "isOn" -> try {
                assert(mBluetoothAdapter != null)
                result.success(mBluetoothAdapter?.isEnabled)
            } catch (ex: Exception) {
                result.error("Error", ex.message, exceptionToString(ex))
            }
            "getNamePrinter" -> try {
                if (mBluetoothAdapter!!.isEnabled) {
                    result.success(mBluetoothAdapter?.name)
                } else {
                    result.success("Unknown")
                }
            } catch (ex: Exception) {
                result.error("Error", ex.message, exceptionToString(ex))
            }
            "isConnected" -> result.success(THREAD != null)
            "openSettings" -> {
                ContextCompat.startActivity(registrar.activity(), Intent(Settings.ACTION_BLUETOOTH_SETTINGS),
                        null)
                result.success(true)
            }
            "getBondedDevices" -> try {
                if (ContextCompat.checkSelfPermission(registrar.activity(),
                                Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(registrar.activity(), arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION), REQUEST_COARSE_LOCATION_PERMISSIONS)
                    pendingResult = result
                    return
                }
                getBondedDevices(result)
            } catch (ex: Exception) {
                result.error("Error", ex.message, exceptionToString(ex))
            }
            "connect" -> if (arguments.containsKey("address")) {
                val address = arguments["address"] as String?
                connect(result, address)
            } else {
                result.error("invalid_argument", "argument 'address' not found", null)
            }
            "disconnect" -> disconnect(result)
            "write" -> if (arguments.containsKey("message")) {
                val message = arguments["message"] as String?
                write(result, message)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "writeBytes" -> if (arguments.containsKey("message")) {
                val message = arguments["message"] as ByteArray?
                writeBytes(result, message)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printCustom" -> if (arguments.containsKey("message")) {
                val message = arguments["message"] as String?
                val size = arguments["size"] as Int
                val align = arguments["align"] as Int
                printCustom(result, message, size, align)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printNewLine" -> printNewLine(result)
            "paperCut" -> paperCut(result)
            "printImage" -> if (arguments.containsKey("pathImage")) {
                val pathImage = arguments["pathImage"] as String?
                printImage(result, pathImage)
            } else {
                result.error("invalid_argument", "argument 'pathImage' not found", null)
            }
            "printQRcode" -> if (arguments.containsKey("textToQR")) {
                val textToQR = arguments["textToQR"] as String?
                val width = arguments["width"] as Int
                val height = arguments["height"] as Int
                val align = arguments["align"] as Int
                printQRcode(result, textToQR, width, height, align)
            } else {
                result.error("invalid_argument", "argument 'textToQR' not found", null)
            }
            "printLeftRight" -> if (arguments.containsKey("string1")) {
                val string1 = arguments["string1"] as String?
                val string2 = arguments["string2"] as String?
                val size = arguments["size"] as Int
                printLeftRight(result, string1, string2, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printRow3" -> if (arguments.containsKey("string1")) {
                val no = arguments["no"] as Int
                val string1 = arguments["string1"] as String?
                val string2 = arguments["string2"] as String?
                val size = arguments["size"] as Int
                printRow3(result, no, string1, string2, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printRowCustom2" -> if (arguments.containsKey("string1")) {
                val format = arguments["format"] as String?
                val string1 = arguments["string1"] as String?
                val string2 = arguments["string2"] as String?
                val size = arguments["size"] as Int
                printRowCustom2(result, format, string1, string2, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printRowCustom3" -> if (arguments.containsKey("string1")) {
                val format = arguments["format"] as String?
                val string1 = arguments["string1"] as String?
                val string2 = arguments["string2"] as String?
                val string3 = arguments["string3"] as String?
                val size = arguments["size"] as Int
                printRowCustom3(result, format, string1, string2, string3, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printStringContinueNewLine" -> if (arguments.containsKey("string1")) {
                val string1 = arguments["string1"] as String?
                val size = arguments["size"] as Int
                printStringContinueNewLine(result, string1, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            "printTitleHeader" -> if (arguments.containsKey("string1")) {
                val string1 = arguments["string1"] as String?
                val string2 = arguments["string2"] as String?
                val string3 = arguments["string3"] as String?
                val size = arguments["size"] as Int
                printTitleHeader(result, string1, string2, string3, size)
            } else {
                result.error("invalid_argument", "argument 'message' not found", null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * @param requestCode  requestCode
     * @param permissions  permissions
     * @param grantResults grantResults
     * @return boolean
     */
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getBondedDevices(pendingResult)
            } else {
                pendingResult!!.error("no_permissions", "this plugin requires location permissions for scanning", null)
                pendingResult = null
            }
            return true
        }
        return false
    }

    /**
     * @param result result
     */
    private fun getBondedDevices(result: MethodChannel.Result?) {
        val list: MutableList<Map<String, Any>> = ArrayList()
        for (device in mBluetoothAdapter!!.bondedDevices) {
            val ret: MutableMap<String, Any> = HashMap()
            ret["address"] = device.address
            ret["name"] = device.name
            ret["type"] = device.type
            list.add(ret)
        }
        result!!.success(list)
    }

    private fun exceptionToString(ex: Exception): String {
        val sw = StringWriter()
        val pw = PrintWriter(sw)
        ex.printStackTrace(pw)
        return sw.toString()
    }

    /**
     * @param result  result
     * @param address address
     */
    private fun connect(result: MethodChannel.Result, address: String?) {
        if (THREAD != null) {
            result.error("connect_error", "already connected", null)
            return
        }
        AsyncTask.execute {
            try {
                val device = mBluetoothAdapter?.getRemoteDevice(address)
                if (device == null) {
                    result.error("connect_error", "device not found", null)
                    return@execute
                }
                val socket = device.createRfcommSocketToServiceRecord(MY_UUID)
                if (socket == null) {
                    result.error("connect_error", "socket connection not established", null)
                    return@execute
                }
                // Cancel bt discovery, even though we didn't start it
                mBluetoothAdapter?.cancelDiscovery()
                try {
                    socket.connect()
                    THREAD = ConnectedThread(socket)
                    THREAD!!.start()
                    result.success(true)
                } catch (ex: Exception) {
                    Log.e(TAG, ex.message, ex)
                    result.error("connect_error", ex.message, exceptionToString(ex))
                }
            } catch (ex: Exception) {
                Log.e(TAG, ex.message, ex)
                result.error("connect_error", ex.message, exceptionToString(ex))
            }
        }
    }

    /**
     * @param result result
     */
    private fun disconnect(result: MethodChannel.Result) {
        if (THREAD == null) {
            result.error("disconnection_error", "not connected", null)
            return
        }
        AsyncTask.execute {
            try {
                THREAD!!.cancel()
                THREAD = null
                result.success(true)
            } catch (ex: Exception) {
                Log.e(TAG, ex.message, ex)
                result.error("disconnection_error", ex.message, exceptionToString(ex))
            }
        }
    }

    /**
     * @param result  result
     * @param message message
     */
    private fun write(result: MethodChannel.Result, message: String?) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            THREAD!!.write(message!!.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun writeBytes(result: MethodChannel.Result, message: ByteArray?) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            THREAD!!.write(message)
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printCustom(result: MethodChannel.Result, message: String?, size: Int, align: Int) { // Print config "mode"
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text small
        val cc1 = byteArrayOf(0x1B, 0x21, 0x00) // 1- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 2- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x16) // 3- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 4- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 5- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(cc1)
                2 -> THREAD!!.write(bb)
                3 -> THREAD!!.write(bb2)
                4 -> THREAD!!.write(bb3)
                5 -> THREAD!!.write(bb4)
            }
            when (align) {
                0 ->  // left align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_LEFT)
                1 ->  // center align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_CENTER)
                2 ->  // right align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_RIGHT)
            }
            THREAD!!.write(message!!.toByteArray())
            THREAD!!.write(PrinterCommands.FEED_LINE)
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printLeftRight(result: MethodChannel.Result, msg1: String?, msg2: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text
        // byte[] cc1 = new byte[]{0x1B,0x21,0x00}; // 0- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 1- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 2- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 3- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 4- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(bb)
                2 -> THREAD!!.write(bb2)
                3 -> THREAD!!.write(bb3)
                4 -> THREAD!!.write(bb4)
            }
            THREAD!!.write(PrinterCommands.ESC_ALIGN_CENTER)
            val line = String.format("%-15s %15s %n", msg1, msg2)
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printNewLine(result: MethodChannel.Result) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            THREAD!!.write(PrinterCommands.FEED_LINE)
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun paperCut(result: MethodChannel.Result) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            THREAD!!.write(PrinterCommands.FEED_PAPER_AND_CUT)
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printImage(result: MethodChannel.Result, pathImage: String?) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            val bmp = BitmapFactory.decodeFile(pathImage)
            if (bmp != null) {
                val command = Utils.decodeBitmap(bmp)
                THREAD!!.write(PrinterCommands.ESC_ALIGN_CENTER)
                THREAD!!.write(command)
            } else {
                Log.e("Print Photo error", "the file isn't exists")
            }
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printQRcode(result: MethodChannel.Result, textToQR: String?, width: Int, height: Int, align: Int) {
        val multiFormatWriter = MultiFormatWriter()
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (align) {
                0 ->  // left align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_LEFT)
                1 ->  // center align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_CENTER)
                2 ->  // right align
                    THREAD!!.write(PrinterCommands.ESC_ALIGN_RIGHT)
            }
            val bitMatrix = multiFormatWriter.encode(textToQR, BarcodeFormat.QR_CODE, width, height)
            val barcodeEncoder = BarcodeEncoder()
            val bmp = barcodeEncoder.createBitmap(bitMatrix)
            if (bmp != null) {
                val command = Utils.decodeBitmap(bmp)
                THREAD!!.write(command)
            } else {
                Log.e("Print Photo error", "the file isn't exists")
            }
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printRow3(result: MethodChannel.Result, no: Int, msg2: String?, msg3: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 1- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 2- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 3- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 4- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(bb)
                2 -> THREAD!!.write(bb2)
                3 -> THREAD!!.write(bb3)
                4 -> THREAD!!.write(bb4)
            }
            val product: String
            product = if (msg2!!.length > 24) {
                msg2.substring(0, 25)
            } else {
                msg2
            }
            val line = String.format(Locale.ENGLISH, "%-3d %-25s %12s\n", no, product, msg3)
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printRowCustom2(result: MethodChannel.Result, format: String?, msg1: String?, msg2: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text small
        val cc1 = byteArrayOf(0x1B, 0x21, 0x00) // 1- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 2- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 3- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 4- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 5- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(cc1)
                2 -> THREAD!!.write(bb)
                3 -> THREAD!!.write(bb2)
                4 -> THREAD!!.write(bb3)
                5 -> THREAD!!.write(bb4)
            }
            val line = String.format(Locale.ENGLISH, format!!, msg1, msg2)
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printRowCustom3(result: MethodChannel.Result, format: String?, msg1: String?, msg2: String?, msg3: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text small
        val cc1 = byteArrayOf(0x1B, 0x21, 0x00) // 1- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 2- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 3- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 4- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 5- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(cc1)
                2 -> THREAD!!.write(bb)
                3 -> THREAD!!.write(bb2)
                4 -> THREAD!!.write(bb3)
                5 -> THREAD!!.write(bb4)
            }
            val line = String.format(Locale.ENGLISH, format!!, msg1, msg2, msg3)
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printStringContinueNewLine(result: MethodChannel.Result, string1: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 1- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 2- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 3- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 4- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(bb)
                2 -> THREAD!!.write(bb2)
                3 -> THREAD!!.write(bb3)
                4 -> THREAD!!.write(bb4)
            }
            val product: String
            product = if (string1!!.length > 50) {
                string1.substring(25, 47) + "..."
            } else {
                string1.substring(25)
            }
            val line = String.format(Locale.ENGLISH, "%-3s %-25s %12s\n", "", product, "")
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private fun printTitleHeader(result: MethodChannel.Result, msg1: String?, msg2: String?, msg3: String?, size: Int) {
        val cc = byteArrayOf(0x1B, 0x21, 0x03) // 0- normal size text
        val bb = byteArrayOf(0x1B, 0x21, 0x08) // 1- only bold text
        val bb2 = byteArrayOf(0x1B, 0x21, 0x20) // 2- bold with medium text
        val bb3 = byteArrayOf(0x1B, 0x21, 0x10) // 3- bold with large text
        val bb4 = byteArrayOf(0x1B, 0x21, 0x30) // 4- strong text
        if (THREAD == null) {
            result.error("write_error", "not connected", null)
            return
        }
        try {
            when (size) {
                0 -> THREAD!!.write(cc)
                1 -> THREAD!!.write(bb)
                2 -> THREAD!!.write(bb2)
                3 -> THREAD!!.write(bb3)
                4 -> THREAD!!.write(bb4)
            }
            val line = String.format("%-3s %-25s %12s\n", msg1, msg2, msg3)
            THREAD!!.write(line.toByteArray())
            result.success(true)
        } catch (ex: Exception) {
            Log.e(TAG, ex.message, ex)
            result.error("write_error", ex.message, exceptionToString(ex))
        }
    }

    private inner class ConnectedThread internal constructor(private val mmSocket: BluetoothSocket) : Thread() {
        private val inputStream: InputStream?
        private val outputStream: OutputStream?
        override fun run() {
            val buffer = ByteArray(1024)
            //            byte[] buffer = new byte[256];
            var bytes: Int
            while (true) {
                try {
                    bytes = inputStream!!.read(buffer)
                    readSink!!.success(String(buffer, 0, bytes))
                } catch (e: NullPointerException) {
                    break
                } catch (e: IOException) {
                    break
                }
            }
        }

        fun write(bytes: ByteArray?) {
            try {
                outputStream!!.write(bytes)
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }

        fun cancel() {
            try {
                outputStream!!.flush()
                outputStream.close()
                inputStream!!.close()
                mmSocket.close()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }

        init {
            var tmpIn: InputStream? = null
            var tmpOut: OutputStream? = null
            try {
                tmpIn = mmSocket.inputStream
                tmpOut = mmSocket.outputStream
            } catch (e: IOException) {
                e.printStackTrace()
            }
            inputStream = tmpIn
            outputStream = tmpOut
        }
    }

    private val stateStreamHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        private val mReceiver: BroadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val action = intent.action
                Log.d(TAG, action)
                if (BluetoothAdapter.ACTION_STATE_CHANGED == action) {
                    THREAD = null
                    statusSink!!.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1))
                } else if (BluetoothDevice.ACTION_ACL_CONNECTED == action) {
                    statusSink!!.success(1)
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED == action) {
                    THREAD = null
                    statusSink!!.success(0)
                }
            }
        }

        override fun onListen(o: Any, eventSink: EventSink) {
            statusSink = eventSink
            registrar.activity().registerReceiver(mReceiver, IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED))
            registrar.activeContext().registerReceiver(mReceiver, IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED))
            registrar.activeContext().registerReceiver(mReceiver, IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED))
        }

        override fun onCancel(o: Any) {
            statusSink = null
            registrar.activity().unregisterReceiver(mReceiver)
        }
    }
    private val readResultsHandler: EventChannel.StreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(o: Any, eventSink: EventSink) {
            readSink = eventSink
        }

        override fun onCancel(o: Any) {
            readSink = null
        }
    }

    companion object {
        private const val TAG = "TDLibThermalPrinter"
        private const val NAMESPACE = "tdlib_print_thermal"
        private const val REQUEST_COARSE_LOCATION_PERMISSIONS = 1451
        private val MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
        private var THREAD: ConnectedThread? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = TdlibPrintThermalPlugin(registrar)
            registrar.addRequestPermissionsResultListener(instance)
        }
    }

    init {
        val channel = MethodChannel(registrar.messenger(), "$NAMESPACE/methods")
        val stateChannel = EventChannel(registrar.messenger(), "$NAMESPACE/state")
        val readChannel = EventChannel(registrar.messenger(), "$NAMESPACE/read")
        if (registrar.activity() != null) {
            val mBluetoothManager = (registrar.activity()
                    .getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager)
            mBluetoothAdapter = mBluetoothManager.adapter
        }
        channel.setMethodCallHandler(this)
        stateChannel.setStreamHandler(stateStreamHandler)
        readChannel.setStreamHandler(readResultsHandler)
    }
}