//
//  kmmTests.swift
//  iosApp
//
//  Created by Anna Skantz on 2023-03-21.
//

import Foundation
import shared
import fannkuchReduxKmm
import nBodyKmm
import fastaKmm
import reverseComplementKmm

class kmmTests {
    
    func testFannkuchRedux() {
        let pipe = Pipe()
        let fileHandle = pipe.fileHandleForWriting
        
        // Save the original standard output
        let originalStandardOutput = dup(fileno(stdout))
        
        // Redirect standard output to the pipe
        dup2(fileHandle.fileDescriptor, fileno(stdout))
        
        // Call benchmark and signal that the output is done with the keyword "stop"
        FannkuchReduxKmm().runBenchmark(n: 7)
        print("stop")
        
        // Restore standard output
        dup2(originalStandardOutput, fileno(stdout))
        close(originalStandardOutput)
        
        let output = readFromPipe(stopAt: "stop", pipe: pipe)
        let expected = "228\nPfannkuchen(7) = 16"
        
        checkEqual(actual: output!, expected: expected, benchmark: "FannkuchRedux")
    }
        
        
    func testNBody() {
        let pipe = Pipe()
        let fileHandle = pipe.fileHandleForWriting
        
        // Save the original standard output
        let originalStandardOutput = dup(fileno(stdout))
        
        // Redirect standard output to the pipe
        dup2(fileHandle.fileDescriptor, fileno(stdout))
        
        // Call benchmark and signal that the output is done with the keyword "stop"
        NBodyKmm().runBenchmark(n: 1000)
        print("stop")
        
        // Restore standard output
        dup2(originalStandardOutput, fileno(stdout))
        close(originalStandardOutput)
        
        let output = readFromPipe(stopAt: "stop", pipe: pipe)
        
        let expected = "-0.169075164\n-0.169087605"
        
        checkEqual(actual: output!, expected: expected, benchmark: "NBody")
    }
    
    func testFasta() {
        let pipe = Pipe()
        let fileHandle = pipe.fileHandleForWriting
        
        // Save the original standard output
        let originalStandardOutput = dup(fileno(stdout))
        
        // Redirect standard output to the pipe
        dup2(fileHandle.fileDescriptor, fileno(stdout))
        
        // Call benchmark and signal that the output is done with the keyword "stop"
        FastaKmm().runBenchmark(n: 1000)
        print("stop")
        
        // Restore standard output
        dup2(originalStandardOutput, fileno(stdout))
        close(originalStandardOutput)
        
        let output = readFromPipe(stopAt: "stop", pipe: pipe)
        
        let filePath = Bundle.main.path(forResource: "fasta1000", ofType: "txt")
        
        guard let fileContents = try? String(contentsOfFile: filePath!, encoding: .utf8) else {
            print("Failed to read file contents")
            return
        }
        
        checkEqual(actual: output!, expected: fileContents.trimmingCharacters(in: .newlines), benchmark: "Fasta")
    }
    
    func testReverseComplement() {
        writeFromFileToStdin(fileName: "fasta1000")
        
        let pipe = Pipe()
        let fileHandle = pipe.fileHandleForWriting
        
        // Save the original standard output
        let originalStandardOutput = dup(fileno(stdout))
        
        // Redirect standard output to the pipe
        dup2(fileHandle.fileDescriptor, fileno(stdout))
        
        // Call benchmark and signal that the output is done with the keyword "stop"
        ReverseComplementKmm().runBenchmark(n: 0)
        print("stop")
        
        // Restore standard output
        dup2(originalStandardOutput, fileno(stdout))
        close(originalStandardOutput)
        
        let output = readFromPipe(stopAt: "stop", pipe: pipe)
                
        let filePath = Bundle.main.path(forResource: "RCout", ofType: "txt")
        
        guard let fileContents = try? String(contentsOfFile: filePath!, encoding: .utf8) else {
            print("Failed to read file contents")
            return
        }
        
        checkEqual(actual: output!, expected: fileContents.trimmingCharacters(in: .newlines), benchmark: "ReverseComplement")
    }
    
    /// Read from pipe until the keyword _stopAt_
    func readFromPipe(stopAt: String, pipe: Pipe) -> String? {
        // Read the output from the pipe into a string
        var data = Data()
        var doneReading = false
        
        repeat {
            let availableData = pipe.fileHandleForReading.availableData
            if availableData.count > 0 {
                data.append(availableData)
                if String(data: data, encoding: .utf8)?.contains(stopAt) == true {
                    doneReading = true
                }
            } else {
                Thread.sleep(forTimeInterval: 0.01)
            }
        } while !doneReading
        
        let rawOutput = String(data: data, encoding: .utf8)
        return rawOutput?.replacingOccurrences(of: stopAt, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Write the contents of a file to standard input
    func writeFromFileToStdin(fileName: String) {
        // Make sure file is included in the "Copy Bundle Resources" build phase of the xcode project
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            freopen(filePath,"r",stdin) // redirect file to stdin.
        } else {
            fatalError("Unable to access file")
        }
        
    }
    
    func checkEqual(actual: String, expected: String, benchmark: String) {
        if (actual == expected) {
            print("Testing \(benchmark) benchmark: SUCCESS")
        } else {
            print("Testing \(benchmark) benchmark: FAILED")
        }
    }
        
}

