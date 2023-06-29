package com.example.kmm.utils

import kotlinx.cinterop.*
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.*
import platform.Foundation.dataWithBytes

actual class IOAndBufferOperator actual constructor() {

    /**
     * Reads up to [len] bytes of data from the standard input stream into [buf] at start offset [off].
     */
    actual fun read(buf: ByteArray, off: Int, len: Int): Int {
        return read(STDIN_FILENO, buf.refTo(off), len.toULong()).toInt()
    }

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

    /**
     * Flush the standard output stream.
     */
    actual fun flush() {
        fflush(stdout)
    }

}