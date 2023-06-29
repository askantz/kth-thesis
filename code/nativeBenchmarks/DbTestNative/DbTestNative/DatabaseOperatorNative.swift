//
//  DatabaseOperatorNative.swift
//  DatabaseOperatorNative
//
//  Created by Anna Skantz on 2023-04-22.
//

import Foundation
import SQLite

// https://github.com/stephencelis/SQLite.swift
// https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md
// https://blog.canopas.com/ios-persist-data-using-sqlite-swift-library-with-swiftui-example-c5baefc04334
// https://www.appsloveworld.com/swift/100/152/using-transactions-to-insert-is-throwing-errors-sqlite-swift?utm_content=cmp-true

public class DatabaseOperatorNative {
    
    private var path = "db.sqlite"
    private let dirName = "NativeDB"
    
    private let benchTable = Table("BenchTable")
    private let id = Expression<Int64>("Id")
    private let benchText = Expression<String>("BenchText")
    
    private var db: Connection? = nil
    
    public init() {
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = docDir.appendingPathComponent(self.dirName)

            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(self.path).path
                db = try Connection(dbPath)
                createTable()
            } catch {
                db = nil
                print("SQLiteDataStore init error: \(error)")
            }
        } else {
            db = nil
        }
    }
    
    /// Executes the following SQL statement:
    /// CREATE TABLE IF NOT EXISTS "BenchTable" (
    ///     "Id" INTEGER PRIMARY KEY NOT NULL,
    ///     "BenchText" TEXT,
    /// )
    private func createTable() {
        
        do {
           try db!.run(benchTable.create(ifNotExists: true)  { table in
               table.column(id, primaryKey: true)
               table.column(benchText)
           })
        } catch {
           print(error)
        }
    }
    
    /// Executes the following SQL statement:
    /// INSERT INTO BenchTable(Id, BenchText)
    /// VALUES(?, ?);
    private func insert(numberOfInserts: Int) {

        do {
            try db!.transaction {
                for index in 1...numberOfInserts {
                    try db!.run(benchTable.insert(id <- Int64(index),
                                                  benchText <- "dbText"))
                }
                
            }
        } catch {
            print(error)
        }
    }
    
    /// Executes the following SQL statement:
    /// INSERT INTO BenchTable(Id, BenchText)
    /// VALUES(?, ?);
    /*private func insertOne(id: Int) {

        do {
            try db!.run(benchTable.insert(id <- id,
                                          benchText <- "dbText"))
        } catch {
            print(error)
        }
    }*/
    
    /// Executes the following SQL statement: SELECT \* FROM "users"
    private func selectAll() -> AnySequence<Row> {
        
        do {
            return try db!.prepare(benchTable)
        } catch {
            print(error)
            return AnySequence([])
        }
    }
    
    /// UPDATE BenchTable SET BenchText = "newDbText";
    private func updateAll() {
        
        do {
            try db!.run(benchTable.update(benchText <- "newDbText"))
        } catch {
            print(error)
        }
    }
    
    /// Executes the following SQL statement: DELETE FROM BenchTable;
    private func deleteAll() {
        
        do {
            try db!.run(benchTable.delete())
            
        } catch {
            print(error)
        }
    }
    
    public func runBenchmark(n: Int) {
        self.insert(numberOfInserts: n)
        _ = self.selectAll()
        self.updateAll()
        self.deleteAll()
    }
    
    public func testBenchmark(n: Int) {
        do {
            self.insert(numberOfInserts: n)
        
            let rowsBeforeUpdate = Array(self.selectAll())
            print("Contents of rows[0] before update: \(try rowsBeforeUpdate[0].get(benchText))")
            print("Contents of rows[n-1] before update: \(try rowsBeforeUpdate[n-1].get(benchText))")
            print("Nr of rows in table: \(rowsBeforeUpdate.count)\n")
            
            self.updateAll()
            
            let rowsAfterUpdate = Array(self.selectAll())
            print("Contents of rows[0] after update: \(try rowsAfterUpdate[0].get(benchText))")
            print("Contents of rows[n-1] after update: \(try rowsAfterUpdate[n-1].get(benchText))")
            print("Nr of rows in table: \(rowsAfterUpdate.count)\n")
            
            self.deleteAll()
            let rowsAfterDelete = Array(self.selectAll())
            print("Nr of rows in table after all rows deleted: \(rowsAfterDelete.count)")
        } catch {
            print("Error occured")
        }
    }
}
