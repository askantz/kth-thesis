//
//  DatabaseOperatorNative.swift
//  DatabaseOperatorNative
//
//  Created by Anna Skantz on 2023-05-11.
//
// https://swiftpackageindex.com/groue/grdb.swift/v6.12.0/documentation/grdb/databaseconnections
// https://github.com/groue/GRDB.swift
//

import Foundation
import GRDB

public class DatabaseOperatorNative {
    let createTableStmt = """
                            CREATE TABLE IF NOT EXISTS BenchTable (
                                Id INTEGER PRIMARY KEY NOT NULL,
                                BenchText TEXT
                            );
                            """
    let insertStmt = """
                        INSERT INTO BenchTable(Id, BenchText)
                        VALUES(?, ?);
                        """
    
    let selectAllStmt = "SELECT * FROM BenchTable"
    
    let selectOneStmt = "SELECT * FROM BenchTable WHERE Id = ?;"
    
    let updateAllStmt = "UPDATE BenchTable SET BenchText = ?;"
    
    let updateOneStmt = "UPDATE BenchTable SET BenchText = ? WHERE Id = ?;"
    
    let deleteAllStmt = "DELETE FROM BenchTable;"
    
    let deleteOneStmt = "DELETE FROM BenchTable WHERE Id = ?;"
    
    private var path = "nativeDB.sqlite"
    var dbQueue: DatabaseQueue?
    
    // https://swiftpackageindex.com/groue/grdb.swift/v6.13.0/documentation/grdb/databaseconnections
    public init() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("NativeDB", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            
            dbQueue = try DatabaseQueue(path: databaseURL.path)
            try createTable()
        } catch {
            print("SQLiteDataStore init error: \(error)")
            dbQueue = nil
        }
    }
    
    public struct BenchTable: Codable, FetchableRecord {
        var Id: Int
        var BenchText: String
    }
    
    private func createTable() throws {
        try dbQueue!.write { db in
            try db.execute(sql: createTableStmt)
        }
    }

    // https://swiftpackageindex.com/groue/grdb.swift/v6.12.0/documentation/grdb/transactions
    // "To profit from database transactions, all you have to do is group related database statements in a single database access method such as write(_:) or read(_:)"
    private func insertN(numberOfInserts: Int) throws {
        try dbQueue!.write { db in
            for index in 1...numberOfInserts {
                try db.execute(sql: insertStmt, arguments: [index, "dbText"])
            }
        }
    }
    
    private func selectAll() throws -> [BenchTable] {
        return try dbQueue!.read { db in
            try BenchTable.fetchAll(db, sql: selectAllStmt)
        }
    }
    
    private func updateAll() throws {
        try dbQueue!.write { db in
            try db.execute(sql: updateAllStmt, arguments: ["newDbText"])
        }
    }
    
    private func deleteAll() throws {
        try dbQueue!.write { db in
            try db.execute(sql: deleteAllStmt)
        }
    }
    
    // Benchmark functions
    public func prepareOneOperationTests(n: Int) throws {
        try insertN(numberOfInserts: n)
    }

    public func resetDatabaseAfterOneOperationTests() throws {
        try deleteAll()
        try dbQueue!.close()
    }
    
    public func insertOne(id: Int) throws {
        try dbQueue!.write { db in
            try db.execute(sql: insertStmt, arguments: [id, "dbText"])
        }
    }
    
    public func selectOne(id: Int) throws -> BenchTable {
        return try dbQueue!.read { db in
            try BenchTable.fetchOne(db, sql: selectOneStmt, arguments: [id])!
        }
    }
    
    public func updateOne(id: Int) throws {
        try dbQueue!.write { db in
            try db.execute(sql: updateOneStmt, arguments: ["newDbText", id])
        }
    }
    
    public func deleteOne(id: Int) throws {
        try dbQueue!.write { db in
            try db.execute(sql: deleteOneStmt, arguments: [id])
        }
    }
    
    public func runBenchmark(n: Int) throws {
        try self.insertN(numberOfInserts: n)
        _ = try self.selectAll()
        try self.updateAll()
        try self.deleteAll()
        try dbQueue!.close()
    }
    
    /* // Manually test the sql operations
    public func testBenchmark(n: Int) {
        do {
            try self.insertN(numberOfInserts: n-1)
            try self.insertOne(id: n)
        
            let rowsBeforeUpdate = try self.selectAll()
            print("Contents of rows[0] before update (expected: dbText): \(rowsBeforeUpdate[0].BenchText)")
            print("Contents of rows[n-1] before update (expected: dbText): \(rowsBeforeUpdate[n-1].BenchText)")
            print("Nr of rows in table (expected: \(n)): \(rowsBeforeUpdate.count)\n")
            
            try self.updateOne(id: 1)
            
            let rowsAfterOneUpdate = try self.selectAll()
            print("Contents of rows[0] after one update (expected: newDbText): \(rowsAfterOneUpdate[0].BenchText)")
            print("Contents of rows[n-1] after one update (expected: dbText): \(rowsAfterOneUpdate[n-1].BenchText)")
            print("Nr of rows in table (expected: \(n)): \(rowsAfterOneUpdate.count)\n")
            
            try self.updateAll()
            
            let rowsAfterUpdate = try self.selectAll()
            print("Contents of rows[0] after update (expected: newDbText): \(rowsAfterUpdate[0].BenchText)")
            print("Contents of rows[n-1] after update (expected: newDbText): \(rowsAfterUpdate[n-1].BenchText)")
            print("Nr of rows in table (expected: \(n)): \(rowsAfterUpdate.count)\n")
            
            try self.deleteOne(id: 1)
            let rowsAfterOneDelete = try self.selectAll()
            print("Nr of rows in table after one row deleted (expected: \(n-1): \(rowsAfterOneDelete.count)")
            
            try self.deleteAll()
            let rowsAfterDelete = try self.selectAll()
            print("Nr of rows in table after all rows deleted (expected: 0): \(rowsAfterDelete.count)")
            try dbQueue!.close()
        } catch {
            print("Error occured \(error)")
        }
    }*/
    
}
