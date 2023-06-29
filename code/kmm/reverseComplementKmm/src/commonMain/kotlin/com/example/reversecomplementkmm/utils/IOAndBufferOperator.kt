package com.example.kmm.utils

expect class IOAndBufferOperator() {

    /**
     * Reads up to [len] bytes of data from the standard input stream into [buf] at start offset [off].
     */
    fun read(buf: ByteArray, off: Int, len: Int): Int

    /**
     * Writes [len] bytes from [buf] byte array starting at offset [off] to standard output stream.
     */
    fun writeBytes(buf: ByteArray, off: Int, len:Int)

    /**
     * Flush the standard output stream.
     */
    fun flush()
}