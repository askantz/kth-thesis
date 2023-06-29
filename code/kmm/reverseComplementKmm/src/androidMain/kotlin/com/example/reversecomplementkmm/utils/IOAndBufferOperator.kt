package com.example.kmm.utils

import java.util.*

actual class IOAndBufferOperator actual constructor() {

    private val `in` = System.`in`

    actual fun read(buf: ByteArray, off: Int, len: Int): Int {
        return `in`.read(buf, off, len)
    }

    actual fun writeBytes(buf: ByteArray, off: Int, len: Int) {
        System.out.write(buf, off, len)
    }

    actual fun flush() {
        System.out.flush()
    }
}