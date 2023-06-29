package com.example.httprequesterkmm

import io.ktor.client.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.utils.io.errors.*

// https://ktor.io/docs/getting-started-ktor-client-multiplatform-mobile.html#android-internet
// https://kotlinlang.org/docs/multiplatform-mobile-ktor-sqldelight.html#before-you-start
// https://kotlinlang.org/docs/native-objc-interop.html#errors-and-exceptions

class HttpRequesterKmm {

    private val lat = LATITUDE
    private val lon = LONGITUDE
    private val key = API_KEY

    @Throws(Exception::class)
    suspend fun runBenchmark(n: Int): Boolean {
        val client = HttpClient()
        val apiUrlOneCall =
            "https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&appid=${key}"

        try {
            for (i in 0 until n) {
                makeHttpCall(client, apiUrlOneCall)
            }
        } catch (e: Exception){
            throw e
        }

        client.close()
        return true
    }

    @Throws(Exception::class)
    suspend fun makeHttpCall(client: HttpClient, url: String): Boolean {

        try {
            val response: HttpResponse = client.get(url)
            if ((200..299).contains(response.status.value)) {
                return true
            } else {
                throw Exception(response.bodyAsText())
            }
        } catch (e: Exception) {
            throw e
        }
    }
}

