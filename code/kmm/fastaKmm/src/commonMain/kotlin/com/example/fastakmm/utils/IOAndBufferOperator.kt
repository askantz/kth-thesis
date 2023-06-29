package com.example.fastakmm.utils

expect class IOAndBufferOperator() {

    /**
     * Writes [len] bytes from [buf] byte array starting at offset [off] to standard output stream.
     */
    fun writeBytes(buf: ByteArray, off: Int, len:Int)

}