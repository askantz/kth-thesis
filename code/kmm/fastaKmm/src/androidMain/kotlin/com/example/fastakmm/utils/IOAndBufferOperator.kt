package com.example.fastakmm.utils

import java.util.*

actual class IOAndBufferOperator actual constructor() {

    actual fun writeBytes(buf: ByteArray, off: Int, len: Int) {
        System.out.write(buf, off, len)
    }
}