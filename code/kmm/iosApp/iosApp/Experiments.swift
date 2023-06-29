//
//  Experiments.swift
//  iosApp
//
//  Created by Anna Skantz on 2023-04-07.
//

// KMM benchmarks
import fannkuchReduxKmm
import nBodyKmm
import fastaKmm
import reverseComplementKmm
import httpRequesterKmm
import jsonParserKmm
import databaseOperatorKmm
// Native benchmarks
import FannkuchReduxNative
import FastaNative
import NBodyNative
import ReverseComplementNative
import HttpRequesterNative
import JsonParserNative
import DatabaseOperatorNative

import Foundation
import AudioToolbox

class Experiments {
    
    private var time: Double?
    private var timeStampBefore: Double?
    private var timeStampAfter: Double?
    private var executionTimeResults: String?
    
    // Set this to true if the results should be uploaded to github
    private var syncToGithub = false // true
    
    // Number of iterations to run each benchmark
    private var it = 100
    
    // Benchmarking workload
    public var nFannkuchRedux = 11
    public var nNBody = 10000000
    public var nFasta = 10000000
    public var inputFileReverseComplement = "fasta10000000"
    public var nDatabase = 400000
    public var nPrepareDatabase = 1000
    public var nHttpRequester = 10
    public var jsonInputFile = "large-file-fourfold"
    
    /* Simulator workload
    public var nFannkuchRedux = 10//11 //11: 2.5 sec
    public var nNBody = 350000 //350000 before
    public var nFasta = 350000
    public var inputFileReverseComplement = "fasta10000000"
    public var nDatabase = 100000
    public var nPrepareDatabase = 1000
    public var nHttpRequester = 10
    public var jsonInputFile = "large-file"*/
    
    private var jsonInput: String?
    private let performanceCalculator = PerformanceCalculator()
    
    
    func benchFannkuchReduxKmm() {
        let n = self.nFannkuchRedux
        let benchmarkName = "FannkuchRedux"
        let approach = "KMM"
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)

    }
    
    func benchFannkuchReduxNative() {
        let n = self.nFannkuchRedux
        let benchmarkName = "FannkuchRedux"
        let approach = "NATIVE"
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchNBodyKmm() {
        let n = self.nNBody
        let benchmarkName = "NBody"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchNBodyNative() {
        let n = self.nNBody
        let benchmarkName = "NBody"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }

    func benchFastaKmm() {
        let n = self.nFasta
        let benchmarkName = "Fasta"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchFastaNative() {
        let n = self.nFasta
        let benchmarkName = "Fasta"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchReverseComplementKmm() {
        let benchmarkName = "ReverseComplement"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: inputFileReverseComplement)
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: 0, benchConfigs: benchConfigs)
    }
    
    func benchReverseComplementNative() {
        let benchmarkName = "ReverseComplement"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: inputFileReverseComplement)
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: 0, benchConfigs: benchConfigs)
    }
    
    func benchHttpRequesterKmm() {
        let n = self.nHttpRequester
        let benchmarkName = "HttpRequester"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        HTTPbenchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchHttpRequesterNative() {
        let n = self.nHttpRequester
        let benchmarkName = "HttpRequester"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        HTTPbenchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchHttpRequesterKmm_ONE() {
        let benchmarkName = "HttpRequester_ONE"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "1")
        
        // The benchmark is exeuted in the globalQueue as to not run the async network calls on the main thread
        DispatchQueue.global().async {
            // BENCHMARK: TIME MEASUREMENTS
            if let timeFileURL = self.benchHttpRequesterTime(benchName: "HttpRequester_KMM", n: 1, benchConfigs: benchConfigs) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
                self.playSound()
            }
        }
    }
    
    func benchHttpRequesterNative_ONE() {
        let benchmarkName = "HttpRequester_ONE"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "1")
        
        DispatchQueue.global().async {
            // BENCHMARK: TIME MEASUREMENTS
            if let timeFileURL = self.benchHttpRequesterTime(benchName: "HttpRequester_NATIVE", n: 1, benchConfigs: benchConfigs) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
                self.playSound()
            }
        }
    }
    
    func benchJsonParserKmm() {
        let benchmarkName = "JsonParser"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        jsonInput = getJson()
        
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: jsonInputFile)
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: 0, benchConfigs: benchConfigs)
    }
    
    func benchJsonParserNative() {
        let benchmarkName = "JsonParser"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        
        jsonInput = getJson()
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: jsonInputFile)
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: 0, benchConfigs: benchConfigs)
    }
    
    func benchDatabaseOperatorKmm() {
        let n = self.nDatabase
        let benchmarkName = "DatabaseOperator"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    func benchDatabaseOperatorNative() {
        let n = self.nDatabase
        let benchmarkName = "DatabaseOperator"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "\(n)")
        
        benchmarkRunner(benchName: benchmarkName + "_" + approach, n: n, benchConfigs: benchConfigs)
    }
    
    // Only time execution are measured for these ONE operation benchmarks
    func benchDatabaseOperatorKmm_INSERT_ONE() {
        let benchmarkName = "DatabaseOperator_INSERT_ONE"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        let dbOperator = DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory())
        if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: dbOperator, dbOperatorNative: nil) {
            GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
        }
        dbOperator.resetDatabaseAfterOneOperationTests()
        self.playSound()
    }
    
    func benchDatabaseOperatorNative_INSERT_ONE() {
        let benchmarkName = "DatabaseOperator_INSERT_ONE"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        do {
            let dbOperator = DatabaseOperatorNative()
            if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: nil, dbOperatorNative: dbOperator) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
            }
            try dbOperator.resetDatabaseAfterOneOperationTests()
            self.playSound()
        } catch {
            print(error)
        }
    }
    
    func benchDatabaseOperatorKmm_SELECT_ONE() {
        let benchmarkName = "DatabaseOperator_SELECT_ONE"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        let dbOperator = DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory())
        dbOperator.prepareOneOperationTests(n: Int32(self.nPrepareDatabase)) // Prepare for benchmark by inserting n entries in the table
        
        if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: dbOperator, dbOperatorNative: nil) {
            GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
        }
        dbOperator.resetDatabaseAfterOneOperationTests()
        self.playSound()
    }
    
    func benchDatabaseOperatorNative_SELECT_ONE() {
        let benchmarkName = "DatabaseOperator_SELECT_ONE"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        do {
            let dbOperator = DatabaseOperatorNative()
            try dbOperator.prepareOneOperationTests(n: self.nPrepareDatabase) // Prepare for benchmark by inserting n entries in the table
            
            if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: nil, dbOperatorNative: dbOperator) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
            }
            try dbOperator.resetDatabaseAfterOneOperationTests()
            self.playSound()
        } catch {
            print(error)
        }
    }
    
    func benchDatabaseOperatorKmm_UPDATE_ONE() {
        let benchmarkName = "DatabaseOperator_UPDATE_ONE"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        let dbOperator = DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory())
        dbOperator.prepareOneOperationTests(n: Int32(self.nPrepareDatabase)) // Prepare for benchmark by inserting n entries in the table
        
        if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: dbOperator, dbOperatorNative: nil) {
            GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
        }
        dbOperator.resetDatabaseAfterOneOperationTests()
        self.playSound()
    }
    
    func benchDatabaseOperatorNative_UPDATE_ONE() {
        let benchmarkName = "DatabaseOperator_UPDATE_ONE"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        do {
            let dbOperator = DatabaseOperatorNative()
            try dbOperator.prepareOneOperationTests(n: self.nPrepareDatabase) // Prepare for benchmark by inserting n entries in the table
            
            if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: nil, dbOperatorNative: dbOperator) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
            }
            try dbOperator.resetDatabaseAfterOneOperationTests()
            self.playSound()
        } catch {
            print(error)
        }
    }
    
    func benchDatabaseOperatorKmm_DELETE_ONE() {
        let benchmarkName = "DatabaseOperator_DELETE_ONE"
        let approach = "KMM"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        let dbOperator = DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory())
        dbOperator.prepareOneOperationTests(n: Int32(self.nPrepareDatabase)) // Prepare for benchmark by inserting n entries in the table
        
        if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: dbOperator, dbOperatorNative: nil) {
            GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
        }
        dbOperator.resetDatabaseAfterOneOperationTests()
        self.playSound()
    }
    
    func benchDatabaseOperatorNative_DELETE_ONE() {
        let benchmarkName = "DatabaseOperator_DELETE_ONE"
        let approach = "NATIVE"
        
        print("Benchmarking \(benchmarkName) \(approach)")
        let benchConfigs = configureBenchmark(benchmarkName: benchmarkName, approach: approach, n: "-1")
        
        // BENCHMARK: TIME MEASUREMENTS
        do {
            let dbOperator = DatabaseOperatorNative()
            try dbOperator.prepareOneOperationTests(n: self.nPrepareDatabase) // Prepare for benchmark by inserting n entries in the table
            
            if let timeFileURL = self.databaseOperator_ONE_BenchTime(benchName: benchmarkName + "_" + approach, benchConfigs: benchConfigs, dbOperatorKmm: nil, dbOperatorNative: dbOperator) {
                GithubHandler().syncToGithub(fileURL: timeFileURL, configs: benchConfigs)
            }
            try dbOperator.resetDatabaseAfterOneOperationTests()
            self.playSound()
        } catch {
            print(error)
        }
    }

    //MARK: BENCHMARK RUNNERS///////////////////////////
    func benchmarkRunner(benchName: String, n: Int, benchConfigs: BenchConfigs) {
        
        if let fileURL = createFile(fileName: benchConfigs.localFilename) {
            let metricHandler = startMeasurements(fileURL: fileURL, configs: benchConfigs)

            DispatchQueue.global().async {
                
                for i in 1...self.it {
                    if (benchName == "ReverseComplement_NATIVE" || benchName == "ReverseComplement_KMM") {
                        // Prepare input from file to standard input stream
                        self.writeFromFileToStdin(fileName: self.inputFileReverseComplement)
                    }
                    
                    self.timeStampBefore = ProcessInfo.processInfo.systemUptime
                    self.runBenchmark(benchName: benchName, n: n)
                    self.timeStampAfter = ProcessInfo.processInfo.systemUptime

                    // Record end of benchmark by writing execution time results to file
                    DispatchQueue.main.sync {
                        metricHandler.addMeasurement(self.getTimeElapsed(iteration: i))
                    }
                }
                
                DispatchQueue.main.sync {
                    self.stopMeasurements(metricHandler: metricHandler)
                }
                
                // BENCHMARK: TIME MEASUREMENTS
                if let timeFileURL = self.benchTime(benchName: benchName, benchConfigs: benchConfigs, n: n) {
                    self.combineFileResults(from: timeFileURL, to: fileURL)
                }
                GithubHandler().syncToGithub(fileURL: fileURL, configs: benchConfigs)
                self.playSound()
            }
        }
    }
    
    func HTTPbenchmarkRunner(benchName: String, n: Int, benchConfigs: BenchConfigs) {
        let group = DispatchGroup()
        
        // BENCHMARK: METRIC MEASUREMENTS
        if let fileURL = createFile(fileName: benchConfigs.localFilename) {
            let metricHandler = startMeasurements(fileURL: fileURL, configs: benchConfigs)
            
            DispatchQueue.global().async {
                for i in 1...self.it {
                    group.enter()
                    self.timeStampBefore = ProcessInfo.processInfo.systemUptime
                    self.HTTPrunBenchmark(benchName: benchName, n: n, metricHandler: metricHandler, group: group, i: i)
                    group.wait()
                }
                
                DispatchQueue.main.sync {
                    self.stopMeasurements(metricHandler: metricHandler)
                }
                
                // BENCHMARK: TIME MEASUREMENTS
                if let timeFileURL = self.benchHttpRequesterTime(benchName: benchName, n: n, benchConfigs: benchConfigs) {
                    self.combineFileResults(from: timeFileURL, to: fileURL)
                }
                
                GithubHandler().syncToGithub(fileURL: fileURL, configs: benchConfigs)
                self.playSound()
            }
        }
    }
    
    //MARK: BENCHMARK TIME EXECUTION ///////////////////////////
    func benchTime(benchName: String, benchConfigs: BenchConfigs, n: Int) -> URL? {
        print("Starting time measurements")
        
        if let fileURL = self.createFile(fileName: "\(benchConfigs.localFilename)_ExecutionTime") {
            self.writeToFile(fileURL: fileURL, input: "TIME for \(benchName):")
            
            for _ in 1...self.it {
                
                if (benchName == "ReverseComplement_NATIVE" || benchName == "ReverseComplement_KMM") {
                    // Prepare input from file to standard input stream
                    self.writeFromFileToStdin(fileName: self.inputFileReverseComplement)
                }
                
                self.timeStampBefore = ProcessInfo.processInfo.systemUptime
                self.runBenchmark(benchName: benchName, n: n)
                self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                // Write results to file
                self.writeToFile(fileURL: fileURL, input: "\(self.timeStampAfter! - self.timeStampBefore!)")
            }
            return fileURL
        }
        return nil
    }
    
    /// Used for measuring execution time on ONE operations for the DatabaseOperator sub-benchmarks
    func databaseOperator_ONE_BenchTime(benchName: String, benchConfigs: BenchConfigs, dbOperatorKmm: DatabaseOperatorKmm?, dbOperatorNative: DatabaseOperatorNative?) -> URL? {
        
        print("Starting time measurements")
        
        if let fileURL = self.createFile(fileName: "\(benchConfigs.localFilename)_ExecutionTime") {
            self.writeToFile(fileURL: fileURL, input: "TIME for \(benchName):")
            
            for index in 1...self.it {
                self.timeStampBefore = ProcessInfo.processInfo.systemUptime
                if dbOperatorKmm != nil {
                    self.databaseOperator_ONE_RunBenchmark(benchName: benchName, id: index, dbOperatorKmm: dbOperatorKmm, dbOperatorNative: nil)
                } else {
                    self.databaseOperator_ONE_RunBenchmark(benchName: benchName, id: index, dbOperatorKmm: nil, dbOperatorNative: dbOperatorNative)
                }
                self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                // Write results to file
                self.writeToFile(fileURL: fileURL, input: "\(self.timeStampAfter! - self.timeStampBefore!)")
            }
            return fileURL
        }
        return nil
    }
    
    func benchHttpRequesterTime(benchName: String, n: Int, benchConfigs: BenchConfigs) -> URL? {
        print("Starting time measurements")
        let group = DispatchGroup()
        
        if let fileURL = self.createFile(fileName: "\(benchConfigs.localFilename)_ExecutionTime") {
            self.writeToFile(fileURL: fileURL, input: "TIME for \(benchName):")
            
            for _ in 1...self.it {
                group.enter()
                self.timeStampBefore = ProcessInfo.processInfo.systemUptime
                
                HTTPrunBenchmarkTime(benchName: benchName, n: n, fileURL: fileURL, group: group)
                
                group.wait()
            }
            return fileURL
        }
        return nil
    }
    
    //MARK: RUN BENCHMARKS ///////////////////////////
    /// Run benchmark (either FannkuchRedux, Fasta, NBody, ReverseComplement, JsonParser, or DatabaseOperator)
    func runBenchmark(benchName: String, n: Int) {
        do {
            switch benchName {
            case "FannkuchRedux_KMM":
                FannkuchReduxKmm().runBenchmark(n: Int32(n))
            case "FannkuchRedux_NATIVE":
                FannkuchReduxNative().runBenchmark(n: n)
            
            case "Fasta_KMM":
                FastaKmm().runBenchmark(n: Int32(n))
            case "Fasta_NATIVE":
                FastaNative().runBenchmark(n: n)
            
            case "NBody_KMM":
                NBodyKmm().runBenchmark(n: Int32(n))
            case "NBody_NATIVE":
                NBodyNative().runBenchmark(n: n)
            
            case "ReverseComplement_KMM":
                ReverseComplementKmm().runBenchmark(n: Int32(n))
            case "ReverseComplement_NATIVE":
                ReverseComplementNative().runBenchmark(n: n)
            
            case "JsonParser_KMM":
                JsonParserKmm().runBenchmark(mockResponse: jsonInput!)
            case "JsonParser_NATIVE":
                JsonParserNative().runBenchmark(mockResponse: jsonInput!)
            
            case "DatabaseOperator_KMM":
                DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory()).runBenchmark(n: Int32(n))
            case "DatabaseOperator_NATIVE":
                try DatabaseOperatorNative().runBenchmark(n: n)
                
            default:
                print("No matching benchName = \(benchName) in switch case")
            }
        } catch {
            print("Error occured while running benchmark \(benchName): \(error)")
        }
    }
    
    /// Run DatabaseOperator ONE benchmarks
    func databaseOperator_ONE_RunBenchmark(benchName: String, id: Int, dbOperatorKmm: DatabaseOperatorKmm?, dbOperatorNative: DatabaseOperatorNative?) {
        do {
            if dbOperatorKmm != nil {
                switch benchName {
                case "DatabaseOperator_INSERT_ONE_KMM":
                    dbOperatorKmm!.insertOne(id: Int32(id)) // Inserting by index id
                    
                case "DatabaseOperator_SELECT_ONE_KMM":
                    dbOperatorKmm!.selectOne(id: Int32(id)) // selecting with same id
                    
                case "DatabaseOperator_UPDATE_ONE_KMM":
                    dbOperatorKmm!.updateOne(id: Int32(id)) // updating with same id
                    
                case "DatabaseOperator_DELETE_ONE_KMM":
                    dbOperatorKmm!.deleteOne(id: Int32(id)) // deleting with same id
                    
                default:
                    print("No matching benchName = \(benchName) in switch case")
                }
            }
            
            if dbOperatorNative != nil {
                switch benchName {
                case "DatabaseOperator_INSERT_ONE_NATIVE":
                    try dbOperatorNative!.insertOne(id: id)
                
                case "DatabaseOperator_SELECT_ONE_NATIVE":
                    try dbOperatorNative!.selectOne(id: id)
                
                case "DatabaseOperator_UPDATE_ONE_NATIVE":
                    try dbOperatorNative!.updateOne(id: id)
                    
                case "DatabaseOperator_DELETE_ONE_NATIVE":
                    try dbOperatorNative!.deleteOne(id: id)
                    
                default:
                    print("No matching benchName = \(benchName) in switch case")
                }
            }
        } catch {
            print("Error occured while running benchmark \(benchName): \(error)")
        }
    }
    
    /// Run HTTP benchmark
    func HTTPrunBenchmark(benchName: String, n: Int, metricHandler: MetricHandler, group: DispatchGroup, i: Int) {
        switch benchName {
            case "HttpRequester_KMM":
            // suspend functions in Kotlin have Error parameter in completion handler https://kotlinlang.org/docs/native-objc-interop.html#errors-and-exceptions
            HttpRequesterKmm().runBenchmark(n: Int32(n)) { result, error in
                    DispatchQueue.main.sync {
                        // Record end of benchmark by writing execution time results to file
                        self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                        metricHandler.addMeasurement(self.getTimeElapsed(iteration: i))
                    }
                    
                    if let error = error {
                        print("Error making api call: \(error)")
                    }
                    
                    group.leave()
                }
            case "HttpRequester_NATIVE":
                HttpRequesterNative().runBenchmark(n: n) { result, error in
                    DispatchQueue.main.sync {
                        // Record end of benchmark by writing execution time results to file
                        self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                        metricHandler.addMeasurement(self.getTimeElapsed(iteration: i))
                    }
                    
                    if let error = error {
                        print("Error making api call: \(error)")
                    }
                    
                    group.leave()
                }
            default:
                print("No matching benchName = \(benchName) in switch case")
        }
    }
    
    /// Run HTTP benchmark, only measure execution time
    func HTTPrunBenchmarkTime(benchName: String, n: Int, fileURL: URL, group: DispatchGroup) {
        
        switch benchName {
            case "HttpRequester_KMM":
            HttpRequesterKmm().runBenchmark(n: Int32(n)) { result, error in
                    self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                    // Write results to file
                    self.writeToFile(fileURL: fileURL, input: "\(self.timeStampAfter! - self.timeStampBefore!)")
                    
                    if let error = error {
                        print("Error making api call: \(error)")
                    }
                    group.leave()
                }
            case "HttpRequester_NATIVE":
            HttpRequesterNative().runBenchmark(n: n) { result, error in
                    self.timeStampAfter = ProcessInfo.processInfo.systemUptime
                    // Write results to file
                    self.writeToFile(fileURL: fileURL, input: "\(self.timeStampAfter! - self.timeStampBefore!)")
                    
                    if let error = error {
                        print("Error making api call: \(error)")
                    }
                
                    group.leave()
                }
            default:
                print("No matching benchName = \(benchName) in switch case")
            }
    }
    
    //MARK: HELPER FUNCTIONS ///////////////////////////
    /// Write contents of one file to the end of the other
    func combineFileResults(from: URL, to: URL) {
        do {
            let fromFileHandle = try FileHandle(forReadingFrom: from)
            let toFileHandle = try FileHandle(forWritingTo: to)
            
            // Move to the end of the file2 file
            toFileHandle.seekToEndOfFile()
            
            // Read the contents of the file1 file and write them to the destination file
            while true {
                let data = fromFileHandle.readData(ofLength: 1024)
                if data.count == 0 { break }
                toFileHandle.write(data)
            }
            
            // Clean up
            fromFileHandle.closeFile()
            toFileHandle.closeFile()
        } catch {
            print("Error ocurred when combining files")
        }
    }
   
    func writeFromFileToStdin(fileName: String) {
        // Make sure file is included in the "Copy Bundle Resources" build phase of the xcode project
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            freopen(filePath,"r",stdin) // redirect file to stdin.
            
        } else {
            fatalError("Unable to access file")
        }
    }
    
    func createFile(fileName: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName + ".txt")
            print("\nMeasurement file can be found here: \n\(fileURL)\n")
            // write to file
            do {
                // creates the file by writing to it
                try "".write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("Error creating file: \(error)")
            }
            return fileURL
        }
        print("Could not create file")
        return nil
    }
    
    func writeToFile(fileURL: URL, input: String) {
        // Open file for appending
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            handle.seekToEndOfFile()
            
            handle.write((input + "\n").data(using: .utf8)!)
            
            // closing the file
            handle.closeFile()
        }
    }
    
    func getTimeElapsed(iteration: Int) -> String {
        return "Execution time (it=\(iteration)): \(self.timeStampAfter! - self.timeStampBefore!) \n---"
    }
    
    func startMeasurements(fileURL: URL, configs: BenchConfigs) -> MetricHandler {
        let metricHandler = MetricHandler(fileURL: fileURL, configs: configs)
        performanceCalculator.start(metricHandler: metricHandler)
        return metricHandler
    }
    
    func stopMeasurements(metricHandler: MetricHandler) {
        performanceCalculator.pause()
        usleep(1000) // Make sure the execution time of the last iteration is added to the queue before stopping OBS!! needed to extend?
        metricHandler.stop()
    }
    
    func configureBenchmark(benchmarkName: String, approach: String, n: String) -> BenchConfigs {
    
        return BenchConfigs(localFilename: "ExperimentResults",
                            githubPath: "results/\(approach)_\(benchmarkName)", // without the ".txt", this is added later
                            commitMessage: "Experiment results for \(benchmarkName) with approach \(approach)", // Commit message that will be connected to this file upload
                            headerText: "\(approach):\n\(benchmarkName) results (\(self.it) iterations, n = \(n)):", // Text to write at top of file
                            headerDescription: "\nCPU | used memory | timestamp \n---",
                            shouldUploadToGithub: self.syncToGithub)
    }
    
    func getJson() -> String {
        // Make sure file is included in the "Copy Bundle Resources" build phase of the xcode project
        let filePath = Bundle.main.path(forResource: jsonInputFile, ofType: "txt") // https://github.com/json-iterator/test-data/blob/master/large-file.json
        
        guard let fileContents = try? String(contentsOfFile: filePath!, encoding: .utf8) else {
            print("Failed to read file contents")
            return "Error"
        }
        return fileContents
    }
    
    func playSound() {
        let soundID: SystemSoundID = 1054
        AudioServicesPlaySystemSound(soundID)
    }
}


