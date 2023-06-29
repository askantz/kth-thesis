package com.example.databaseoperatorkmm.cache

// https://kotlinlang.org/docs/multiplatform-mobile-ktor-sqldelight.html
// https://cashapp.github.io/sqldelight/2.0.0-alpha05/native_sqlite/
// https://github.com/cashapp/sqldelight/tree/master/sample

class DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory) {
    val driver = driverFactory.createDriver()
    val database = KmmDatabase(driver)
    private val dbQuery = database.kmmDatabaseQueries

    private fun insertN(numberOfInserts: Int) {
        dbQuery.transaction {
            for (index in 0 until numberOfInserts) {
                dbQuery.insert((index + 1).toLong(), "dbText") // type INTEGER in database is retrieved as long
            }
        }
    }

    private fun selectAll(): List<BenchTable> {
        return dbQuery.selectAll().executeAsList()
    }

    private fun updateAll() {
        dbQuery.updateAll("newDbText")
    }

    private fun deleteAll() {
        dbQuery.removeAll()
    }

    // Benchmark functions
    public fun prepareOneOperationTests(n: Int) {
        insertN(n)
    }

    public fun resetDatabaseAfterOneOperationTests() {
        deleteAll()
        driver.close()
    }

    public fun insertOne(id: Int) {
        dbQuery.insert((id).toLong(), "dbText")
    }

    public fun selectOne(id: Int): BenchTable {
        return dbQuery.selectOne((id).toLong()).executeAsOne()
    }

    public fun updateOne(id: Int) {
        dbQuery.updateOne("newDbText", (id).toLong())
    }

    public fun deleteOne(id: Int) {
       dbQuery.removeOne(Id = (id).toLong())
   }

    public fun runBenchmark(n: Int) {
        insertN(n)
        selectAll()
        updateAll()
        deleteAll()
        driver.close()
    }

    /* // Uncomment this to manually test the sql operations
    public fun testBenchmark(n: Int) {
        insertN(n-1)
        insertOne(n)

        val rowsBeforeUpdate = selectAll()
        println("Contents of rows[0] before update (expected: dbText): " + rowsBeforeUpdate[0].BenchText)
        println("Contents of rows[n-1] before update (expected: dbText): " + rowsBeforeUpdate[n-1].BenchText)
        println("Nr of rows in table (expected: "+ n + "): " + rowsBeforeUpdate.size + "\n")

        updateOne(1)

        val rowsAfterOneUpdate = selectAll()
        println("Contents of rows[0] after one update (expected: newDbText): " + rowsAfterOneUpdate[0].BenchText)
        println("Contents of rows[n-1] after one update (expected: dbText): " + rowsAfterOneUpdate[n-1].BenchText)
        println("Nr of rows in table (expected: "+ n + "): " + rowsAfterOneUpdate.size + "\n")

        updateAll()

        val rowsAfterUpdate = selectAll()
        println("Contents of rows[0] after update (expected: newDbText): " + rowsAfterUpdate[0].BenchText)
        println("Contents of rows[n-1] after update (expected: newDbText): " + rowsAfterUpdate[n-1].BenchText)
        println("Nr of rows in table (expected: "+ n + "): " + rowsAfterUpdate.size + "\n")

        deleteOne(1)
        val rowsAfterOneDelete = selectAll()
        println("Nr of rows in table after all rows deleted (expected: "+ (n-1) + "): " + rowsAfterOneDelete.size)

        deleteAll()
        val rowsAfterDelete = selectAll()
        println("Nr of rows in table after all rows deleted (expected: 0): " + rowsAfterDelete.size)
        driver.close()
    }*/
}