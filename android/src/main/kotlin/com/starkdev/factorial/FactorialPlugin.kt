package com.starkdev.factorial

import androidx.annotation.NonNull

import kotlinx.coroutines.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.BinaryMessenger

class FactorialTask {
    private var isCancelled = false
    val cancelled: Boolean
        get() = isCancelled

    fun cancel() {
        isCancelled = true
    }
}

fun calculate(
    number: UByte,
    cancellationToken: FactorialTask,
    onProgress: ((Double) -> Unit)? = null
): Deferred<Long?> {
    require(number <= 20u) { "Big Value" }

    val max = number.toDouble()
    var index = 0.0

    suspend fun factorial(num: ULong): ULong {
        require(!cancellationToken.cancelled) { "cancelled" }

        onProgress?.let {
            index += 1.0
            it.invoke(index / max)
        }

        delay(100) // slow down the execution by 100ms

        return if (num <= 1u) 1u else num * factorial(num - 1u)
    }

    return GlobalScope.async(Dispatchers.Default) {
        try {
            val result = factorial(number.toULong())
            result.toLong()
        } catch (e: Exception) {
            null
        }
    }
}

class MyEventChannelHandler : EventChannel.StreamHandler {
  // The scope for the UI thread
  private val mainScope = CoroutineScope(Dispatchers.Main)

  override fun onListen(p0: Any?, events: EventChannel.EventSink?) {
    try {
      val token = FactorialTask()
      val task = calculate(5u, token) { progress ->
        println("Progress: $progress")
        events?.success(progress)
      }
      
      /*GlobalScope.async(Dispatchers.Default) {
          delay(250)
          token.cancel()
          println("cancel?")
      }*/

      mainScope.launch {
        events?.success(true)
      // runBlocking {
          val result = task.await()
          if (result != null) {
            println("Result: $result")
            println(result.toString())
            events?.success(result.toString())
          } else {
              println("Cancelled")
              events?.success(false)
          }
        }
    } catch (e: Exception) {
        print("Error: $e")
        events?.success(e) // FlutterError
    }


    // mainScope.launch {
    // events?.success(true)
    //   withContext(Dispatchers.Default) {
    //     // mainScope.launch {
    //     events?.success(0.2)
    //     // }
    //   }
    //   events?.success(0.4)
    //   delay(100)
    //   events?.success(1.0)
    //   withContext(Dispatchers.Main) {
    //       println("120")
    //   }
    // }

    //GlobalScope.launch {
    /*runBlocking {
        events?.success(true)

        // Run the background task in a coroutine
        launch(Dispatchers.Default) {

            events?.success(0.2)

            delay(100)

            launch(Dispatchers.Main) {
              events?.success(0.5)
            }

            delay(100)

            launch(Dispatchers.Main) {
              events?.success(1.0)
            }

            launch(Dispatchers.Main) {
                events?.success("120")
            }
        }
    }
    events?.success(false)*/

    /*events?.success(true) // started

    val task = calculate(5u, 
      onProgress = { progress ->
        println("Progress: $progress")
        events?.success(progress) // progress
      },
      completion = { result ->
        if (result != null) {
          println("Result: $result")
          println(result.toString())
          events?.success(result.toString())
        } else {
            println("Cancelled")
            events?.success(false)
        }
    })*/
    //Thread.sleep(200)
    //task.cancel()
    //Thread.sleep(350)
    
    //Thread.sleep(550) - can block the main thread !
    // delay(550)
    // kotlinx.coroutines.delay(550)
    // events?.success(true)

    // events?.success(true) // started
    // Thread.sleep(100)
    // events?.success(0.5) // progress
    // Thread.sleep(100)
    // events?.success(1.0) // progress
    // Thread.sleep(100)
    // events?.success("120") // done
  }

  override fun onCancel(p0: Any?) {
    // Do something when the Flutter plugin stops emitting events.
  }

}

/** FactorialPlugin */
class FactorialPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var binaryMessenger : BinaryMessenger

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
    channel = MethodChannel(binaryMessenger, "com.starkdev.factorial")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "factorial") {
      /*guard let arguments = call.arguments as? [String: Any], let id = arguments["id"] as? String else {
          result(false) // TODO: FlutterErorr (!)
          return
      }*/

      val eventChannel = EventChannel(binaryMessenger, "com.starkdev.factorial.10001")
      eventChannel.setStreamHandler(MyEventChannelHandler())

      result.success(true)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

// https://play.kotlinlang.org/
/*import kotlinx.coroutines.*

class FactorialTask {
    private var isCancelled = false
    val cancelled: Boolean
        get() = isCancelled

    fun cancel() {
        isCancelled = true
    }
}

@Throws(Exception::class)
fun calculate(
    number: UByte,
    onProgress: ((Double) -> Unit)? = null,
    completion: (Long?) -> Unit
): FactorialTask {
    require(number <= 20u) { "Big Value" }

    val task = FactorialTask()
    val max = number.toDouble()
    var index = 0.0

    suspend fun factorial(num: ULong): ULong {
        require(!task.cancelled) { "cancelled" }
        
        onProgress?.let {
            index += 1.0
            it.invoke(index / max)
        }

        delay(100)

        return if (num <= 1u) 1u else num * factorial(num - 1u)
    }

    GlobalScope.launch(Dispatchers.Default) {
        try {
            val result = factorial(number.toULong())
            completion(result.toLong())
        } catch (e: Exception) {
            completion(null)
        }
    }
    
    return task
}

fun calculate2(
    number: UByte,
    cancellationToken: FactorialTask,
    onProgress: ((Double) -> Unit)? = null
): Deferred<Long?> {
    require(number <= 20u) { "Big Value" }

    val max = number.toDouble()
    var index = 0.0

    suspend fun factorial(num: ULong): ULong {
        require(!cancellationToken.cancelled) { "cancelled" }

        onProgress?.let {
            index += 1.0
            it.invoke(index / max)
        }

        delay(100)

        return if (num <= 1u) 1u else num * factorial(num - 1u)
    }

    return GlobalScope.async(Dispatchers.Default) {
        try {
            val result = factorial(number.toULong())
            result.toLong()
        } catch (e: Exception) {
            null
        }
    }
}

fun main() {
    try {
    val token = FactorialTask()
    val task = calculate2(5u, token) { progress ->
    	println("Progress: $progress")
	}
    
    GlobalScope.async(Dispatchers.Default) {
        delay(250)
        token.cancel()
        println("cancel?")
    }

	runBlocking {
    	val result = task.await()
    	println("Result: $result")
	}
    println("exit")
    } catch (e: Exception) {
        print("Error: $e")
    }
}*/