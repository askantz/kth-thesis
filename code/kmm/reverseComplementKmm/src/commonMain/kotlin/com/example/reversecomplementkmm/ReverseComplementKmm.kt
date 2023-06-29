package com.example.reversecomplementkmm

import com.example.kmm.utils.IOAndBufferOperator
import kotlin.math.min

/*
 * The Computer Language Benchmarks Game
 * http://benchmarksgame.alioth.debian.org/
 * contributed by Tao Lei
 * mostly auto-converted to Kotlin by Patrik Schwermer
 *
 * modified by Anna Skantz
 */

class ReverseComplementKmm {

    private val transFrom = "ACGTUMRWSYKVHDBN"
    private val transTo = "TGCAAKYWSRMBDHVN"
    private val transMap = ByteArray(128)

    init {
        for (i in transMap.indices) transMap[i] = i.toByte()
        for (j in 0 until transFrom.length) {
            val c = transFrom[j]
            transMap[c.lowercase().single().code] = transTo[j].code.toByte()
            transMap[c.code] = transMap[c.lowercase().single().code]
        }
    }

    private var buffer = ByteArray(65536)   // 64*1024

    val operator = IOAndBufferOperator()
    private var pos: Int = 0
    private var limit: Int = 0
    private var start: Int = 0
    private var end: Int = 0

    private fun endPos(): Int {
        for (off in pos until limit) {
            if (buffer[off] == '\n'.code.toByte())
                return off
        }
        return -1
    }

    /**
     * Reads from standard input to buffer
     */
    private fun nextLine(): Boolean {
        while (true) {
            end = endPos()
            if (end >= 0) {
                start = pos
                pos = end + 1
                if (buffer[end - 1] == '\r'.code.toByte())
                    end--
                while (buffer[start] == ' '.code.toByte()) start++
                while (end > start && buffer[end - 1] == ' '.code.toByte()) end--
                if (end > start)
                    return true
            } else {
                if (pos > 0 && limit > pos) {
                    limit -= pos
                    // copy contents of buffer after index pos to the beginning of buffer
                    buffer.copyInto(buffer, 0, pos, pos+limit)
                    pos = 0
                } else {
                    limit = 0
                    pos = limit
                }
                val r = operator.read(buffer, limit, buffer.size - limit)

                if (r <= 0)
                    return false
                limit += r
            }
        }
    }

    private var LINE_WIDTH = 0
    private var data = ByteArray(1 shl 20) // 1 shl 20 = 1048576
    private var size: Int = 0
    private var outputBuffer = ByteArray(65536)
    private var outputPos = 0

    /**
     * Writes __outputBuffer__ contents from index 0 to __outputPos__ to standard output.
     */
    private fun flushData() {
        operator.writeBytes(outputBuffer, 0, outputPos)
        outputPos = 0
    }

    /**
     * If the __outputBuffer__ cannot add [len] bytes without overflowing buffer, flush the
     * contents of the buffer to standard output. Otherwise, do nothing.
     */
    private fun prepareWrite(len: Int) {
        if (outputPos + len > outputBuffer.size)
            flushData()
    }

    /**
     * Writes [b].toByte() into __outputBuffer__.
     */
    private fun write(b: Int) {
        outputBuffer[outputPos++] = b.toByte()
    }

    /**
     * Writes [len] bytes from [buf] starting at [off] to __outputBuffer__.
     */
    private fun write(buf: ByteArray, off: Int, len: Int) {
        prepareWrite(len)
        buf.copyInto(outputBuffer, outputPos, off, off+len)
        outputPos += len
    }

    /**
     * Writes the remaining contents of __data__ to __outputBuffer__ if __size__ > 0.
     */
    private fun finishData() {
        while (size > 0) {
            var len = min(LINE_WIDTH, size)
            prepareWrite(len + 1)
            while (len-- != 0) {
                write(data[--size].toInt())
            }
            write('\n'.code)
        }
        resetData()
    }

    private fun resetData() {
        LINE_WIDTH = 0
        size = 0
    }

    /**
     * Inserts characters encoded to bytes in __data__ from __transmap__ by extracting characters
     * using the __buffer__ contents \[__start__ to __end__] .
     */
    private fun appendLine() {
        val len = end - start
        if (LINE_WIDTH == 0) LINE_WIDTH = len
        // Doubles the size of the global data array if size + len > data.size
        if (size + len > data.size) {
            val data0 = data
            data = ByteArray(data.size * 2)
            data0.copyInto(data, 0, 0, size)
        }
        for (i in start until end) {
            data[size++] = transMap[buffer[i].toInt()]
        }
    }

    private fun solve() {
        limit = 0
        pos = limit
        outputPos = 0
        resetData()
        while (nextLine()) {
            if (buffer[start] == '>'.code.toByte()) {
                finishData()
                write(buffer, start, pos - start)
            } else {
                appendLine()
            }
        }
        finishData()
        if (outputPos > 0) flushData()
        operator.flush()
    }

    fun runBenchmark(n: Int) {
        solve()
    }
}