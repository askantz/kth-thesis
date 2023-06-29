/* The Computer Language Benchmarks Game
 https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
 contributed by Ralph Ganszky
 converted to Swift 3 by Sergo Beruashvili
 
 CLBG version: Swift https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/fasta-swift-1.html
 modified by Anna Skantz
 */

import Foundation

public class FastaNative {
    
    public init() {}
    
    struct AminoAcid {
        var prob: Double
        var sym: UInt8
    }
    
    let IM = 139968
    let IA = 3877
    let IC = 29573
    var seed = 42
        
    let bufferSize = 61*1024 // buffer size used in kotlin version
    let width = 60
    
    let aluString = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG" +
    "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" +
    "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT" +
    "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" +
    "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG" +
    "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" +
    "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"
    
    var iub = [
        AminoAcid(prob: 0.27, sym: 97), // "a"),
        AminoAcid(prob: 0.12, sym: 99), // "c"),
        AminoAcid(prob: 0.12, sym: 103), // "g"),
        AminoAcid(prob: 0.27, sym: 116), // "t"),
        AminoAcid(prob: 0.02, sym: 66), // "B"),
        AminoAcid(prob: 0.02, sym: 68), // "D"),
        AminoAcid(prob: 0.02, sym: 72), // "H"),
        AminoAcid(prob: 0.02, sym: 75), // "K"),
        AminoAcid(prob: 0.02, sym: 77), // "M"),
        AminoAcid(prob: 0.02, sym: 78), // "N"),
        AminoAcid(prob: 0.02, sym: 82), // "R"),
        AminoAcid(prob: 0.02, sym: 83), // "S"),
        AminoAcid(prob: 0.02, sym: 86), // "V"),
        AminoAcid(prob: 0.02, sym: 87), // "W"),
        AminoAcid(prob: 0.02, sym: 89), // "Y"),
    ]
    
    var homosapiens = [
        AminoAcid(prob: 0.3029549426680, sym: 97), // "a"),
        AminoAcid(prob: 0.1979883004921, sym: 99), // "c"),
        AminoAcid(prob: 0.1975473066391, sym: 103), // "g"),
        AminoAcid(prob: 0.3015094502008, sym: 116), // "t"),
    ]
    
    /**
    Writes buf contents from index 0 to len to standard output.
    */
    func write(buf: [UInt8], len: Int) {
        let data = Data(buf[0..<len])
        let handle = FileHandle.standardOutput
        handle.write(data)
    }
    
    func repeatFasta(id: String, desc: String, gene: [UInt8], n: Int) {
        let gene2 = gene + gene
        var buffer = [UInt8](repeating: 10, count: bufferSize)
        
        // Write the id and description to standard out
        let descStr = String(">" + id + " " + desc + "\n")
        let descByteArray = [UInt8](descStr.utf8)
        write(buf: descByteArray, len: descByteArray.count)
        
        var pos = 0
        var rpos = 0
        var cnt = n
        var lwidth = width
        while cnt > 0 {
            if pos + lwidth > buffer.count {
                write(buf: buffer, len: pos)
                pos = 0
            }
            if rpos + lwidth > gene.count {
                rpos = rpos % gene.count
            }
            if cnt < lwidth {
                lwidth = cnt
            }
            buffer[pos..<pos+lwidth] = gene2[rpos..<rpos+lwidth]
            buffer[pos+lwidth] = 10
            pos += lwidth + 1
            rpos += lwidth
            cnt -= lwidth
        }
        if pos > 0 && pos < buffer.count {
            buffer[pos] = 10
            write(buf: buffer, len: pos)
        } else if pos == buffer.count {
            write(buf: buffer, len: pos)
            buffer[0] = 10
            write(buf: buffer, len: 1)
        }
    }
    
    func search(rnd: Double, within arr: [AminoAcid]) -> UInt8 {
        var low = 0
        var high = arr.count - 1
        while low <= high {
            let mid = low + (high - low) / 2
            if arr[mid].prob >= rnd {
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        return arr[high+1].sym
    }
    
    func accumulateProbabilities( acid: inout [AminoAcid]) {
        for i in 1..<acid.count {
            acid[i].prob += acid[i-1].prob
        }
    }
    
    func randomFasta(id: String, desc: String, acid: inout [AminoAcid], _ n: Int) {
        var cnt = n
        accumulateProbabilities(acid: &acid)
        var buffer = [UInt8](repeating: 10, count: bufferSize)
        
        // Write the id and description to standard out
        let descStr = String(">" + id + " " + desc + "\n")
        let descByteArray = [UInt8](descStr.utf8)
        write(buf: descByteArray, len: descByteArray.count)
        
        var pos = 0
        while cnt > 0 {
            var m = cnt
            if m > width {
                m = width
            }
            let f = 1.0 / Double(IM)
            var myrand = seed
            // Generate [m] elements into buffer by pseudo-random selection and using binary search
            for _ in 0..<m {
                myrand = (myrand * IA + IC) % IM
                let r = Double(myrand) * f
                buffer[pos] = search(rnd: r, within: acid)
                pos += 1
                if pos == buffer.count {
                    write(buf: buffer, len: pos)
                    pos = 0
                }
            }
            seed = myrand
            buffer[pos] = 10
            pos += 1
            if pos == buffer.count {
                write(buf: buffer, len: pos)
                pos = 0
            }
            cnt -= m
        }
        if pos > 0 {
            write(buf: buffer, len: pos)
        }
    }
    
    public func runBenchmark( n: Int) {
        var alu = aluString.utf8CString.map({ UInt8($0) }) // Converts String to byte array
        var _ = alu.popLast()
        
        repeatFasta(id: "ONE", desc: "Homo sapiens alu", gene: alu, n: 2*n)
        randomFasta(id: "TWO", desc: "IUB ambiguity codes", acid: &iub, 3*n)
        randomFasta(id: "THREE", desc: "Homo sapiens frequency", acid: &homosapiens, 5*n)
    }
    
}
