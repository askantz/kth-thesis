package com.example.fastakmm.utils

import kotlinx.cinterop.allocArrayOf
import kotlinx.cinterop.convert
import kotlinx.cinterop.memScoped
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.*

actual class IOAndBufferOperator actual constructor() {

    /**
     * Writes [len] bytes from [buf] byte array starting at offset [off] to standard output stream.
     */
    actual fun writeBytes(buf: ByteArray, off: Int, len: Int) {
        val data = buf.copyOfRange(off, off+len).toNSData()
        val handle = NSFileHandle.fileHandleWithStandardOutput()
        handle.writeData(data)
    }
    //https://stackoverflow.com/questions/58521108/how-to-convert-kotlin-bytearray-to-nsdata-and-viceversa
    //https://ronaldvanduren.medium.com/moving-to-kotlin-multiplatform-part-3-4-ea687333a2cb
    private fun ByteArray.toNSData(): NSData = memScoped {
        NSData.create(bytes = allocArrayOf(this@toNSData), size.toULong())
    }
}