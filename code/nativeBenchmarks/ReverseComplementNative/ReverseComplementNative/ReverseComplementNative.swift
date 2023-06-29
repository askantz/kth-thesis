//
// The Computer Language Benchmarks Game
// http://benchmarksgame.alioth.debian.org/
// contributed by Tao Lei
// mostly auto-converted to Kotlin by Patrik Schwermer
//
// Converted to swift by Anna Skantz
//

import Foundation

public class ReverseComplementNative {
    
    private let transFrom = "ACGTUMRWSYKVHDBN"
    private let transTo = "TGCAAKYWSRMBDHVN"
    private var transMap = [UInt8](repeating: 0, count: 128)

    public init() {
        for i in transMap.indices {
            transMap[i] = UInt8(i)
        }
        for j in 0..<transFrom.count {
            let c = transFrom[transFrom.index(transFrom.startIndex, offsetBy: j)]
            transMap[Int(c.lowercased().utf8.first!)] = String(transTo[transTo.index(transTo.startIndex, offsetBy: j)]).utf8.first!
            transMap[Int(c.utf8.first!)] = transMap[Int(c.lowercased().utf8.first!)]
        }
    }

    private var buffer: [UInt8] = [UInt8](repeating: 0, count: 65536)    // 64*1024
    private var pos: Int = 0
    private var limit: Int = 0
    private var start: Int = 0
    private var end: Int = 0

    private func endPos() -> Int {
        for off in pos..<limit {
            if buffer[off] == "\n".utf8.first! {
                return off
            }
        }
        return -1
    }
    
    /**
     * Reads from standard input to buffer
     */
    private func nextLine() -> Bool {
        while true {
            end = endPos()
            if end >= 0 {
                start = pos
                pos = end + 1
                if buffer[end - 1] == "r".utf8.first! {
                    end -= 1
                }
                while buffer[start] == " ".utf8.first! {
                    start += 1
                }
                while end > start && buffer[end - 1] == " ".utf8.first! {
                    end -= 1
                }
                if end > start {
                    return true
                }
            } else {
                if pos > 0 && limit > pos {
                    limit -= pos
                    buffer[0..<limit] = buffer[pos..<limit + pos]
                    pos = 0
                } else {
                    limit = 0
                    pos = limit
                }
                
                let r = read(STDIN_FILENO, &buffer[limit], buffer.count - limit)
                
                // end of stream was reached
                if r <= 0 {
                    return false
                }
                limit += r
            }
        }
    }
    
    private var LINE_WIDTH = 0
    private var data = [UInt8](repeating: 0, count: 1048576) // 1 shl 20 = 1048576
    private var size: Int = 0
    private var outputBuffer = [UInt8](repeating: 0, count: 65536)
    private var outputPos = 0
    
    /**
    Writes outputBuffer contents from index 0 to outputPos to standard output.
    */
    private func flushData() {
        let data = Data(outputBuffer[0..<outputPos])
        let handle = FileHandle.standardOutput
        handle.write(data)
        outputPos = 0
    }
    
    /**
    If the outputBuffer cannot add [len] bytes without overflowing buffer, flush the
    contents of the buffer to standard output. Otherwise, do nothing.
    */
    private func prepareWrite(len: Int) {
        if (outputPos + len > outputBuffer.count) {
            flushData()
        }
    }
    
    /**
    Writes [b].toByte() into outputBuffer.
    */
    private func write(b: Int) {
        outputBuffer[outputPos] = UInt8(b)
        outputPos += 1
    }
    
    /**
    Writes [len] bytes from [buf] to outputBuffer.
    */
    private func write(buf: [UInt8], off: Int, len: Int) {
        prepareWrite(len: len)
        outputBuffer.insert(contentsOf: buf[off..<(off+len)], at: outputPos)
        outputPos += len
    }
    
    /**
    Writes the remaining contents of data to outputBuffer if size > 0.
    */
    private func finishData() {
        while size > 0 {
            let len = min(LINE_WIDTH, size)
            prepareWrite(len: len + 1)
            for _ in 0..<len {
                write(b: Int(data[size - 1]))
                size -= 1
            }
            write(b: Int("\n".utf8.first!))
        }
        resetData()
    }
    
    private func resetData() {
        LINE_WIDTH = 0
        size = 0
    }
    
    /**
     * Inserts characters encoded to bytes in __data__ from __transmap__ by extracting characters
     * using the __buffer__ contents \[__start__ to __end__] .
     */
    private func appendLine() {
        let len = end - start
        if (LINE_WIDTH == 0) {
            LINE_WIDTH = len
        }
        // Doubles the size of the global data array if size + len > data.count
        if (size + len > data.count) {
            let data0 = data
            data = [UInt8](repeating: 0, count: data.count * 2)
            data.insert(contentsOf: data0[0..<size], at: 0)
        }
        for i in start..<end {
            data[size] = transMap[Int(buffer[i])]
            size += 1
        }
    }

    private func solve() {
        limit = 0
        pos = limit
        outputPos = 0
        resetData()
        while (nextLine()) {
            if buffer[start] == ">".utf8CString[0] {
                finishData()
                write(buf: buffer, off: start, len: pos - start)
            } else {
                appendLine()
            }
        }
        finishData()
        if outputPos > 0 {
            flushData()
        }
        fflush(stdout)
    }
    
    public func runBenchmark(n: Int) {
        solve()
    }
}
