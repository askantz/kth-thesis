//
//  iosAppTests.swift
//  iosAppTests
//
//  Created by Anna Skantz on 2023-04-24.
//

import XCTest

import FannkuchReduxNative
import NBodyNative
import FastaNative
import ReverseComplementNative

final class iosAppTests: XCTestCase {
    
    private var originalStandardOutput: Int32?
    private var pipe: Pipe?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFannkuchReduxNative() throws {
        setupStdoutPipe()

        FannkuchReduxNative().runBenchmark(n: 7)
        
        let output = restoreStdoutAndGetOutput()
        let expected = "228\nPfannkuchen(7) = 16"

        XCTAssertEqual(output, expected)
    }
    
    func testNBodyNative() throws {
        setupStdoutPipe()

        NBodyNative().runBenchmark(n: 1000)
        
        let output = restoreStdoutAndGetOutput()
        let expected = "-0.169075164\n-0.169087605"

        XCTAssertEqual(output, expected)
    }
    
    func testFastaNative() throws {
        setupStdoutPipe()

        FastaNative().runBenchmark(n: 1000)
        
        let output = restoreStdoutAndGetOutput()
        
        let filePath = Bundle.main.path(forResource: "fasta1000", ofType: "txt")
        
        guard let fileContents = try? String(contentsOfFile: filePath!, encoding: .utf8) else {
            XCTFail("Failed to read file contents")
            return
        }

        XCTAssertEqual(output, fileContents.trimmingCharacters(in: .newlines), "File contents do not match expected value")
    }
    
    func testReverseComplementNative() throws {
        writeFromFileToStdin(fileName: "fasta1000")
        
        setupStdoutPipe()

        ReverseComplementNative().runBenchmark(n: 0)
        
        let output = restoreStdoutAndGetOutput()
        
        let filePath = Bundle.main.path(forResource: "RCout", ofType: "txt")
        
        guard let fileContents = try? String(contentsOfFile: filePath!, encoding: .utf8) else {
            XCTFail("Failed to read file contents")
            return
        }

        XCTAssertEqual(output, fileContents.trimmingCharacters(in: .newlines), "File contents do not match expected value")
    }
    
    // HELPER FUNCTIONS
    
    func setupStdoutPipe() {
        pipe = Pipe()
        let fileHandle = pipe!.fileHandleForWriting

        // Save the original standard output
        originalStandardOutput = dup(fileno(stdout))

        // Redirect standard output to the pipe
        dup2(fileHandle.fileDescriptor, fileno(stdout))
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
    
    func restoreStdoutAndGetOutput() -> String {
        //signal that the output is done with the keyword "stop"
        print("stop")

        // Restore standard output
        dup2(originalStandardOutput!, fileno(stdout))
        close(originalStandardOutput!)
        
        return readFromPipe(stopAt: "stop", pipe: pipe!)!
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

}
