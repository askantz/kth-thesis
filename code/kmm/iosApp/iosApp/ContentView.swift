import SwiftUI
import databaseOperatorKmm
import DatabaseOperatorNative

struct ContentView: View {
    
    @State private var displayText = ""
    private var experiments = Experiments()
	
    var body: some View {
        NavigationView{
            
                VStack {
                    Text("Running: " + displayText)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.red)
                        .padding(.bottom, 3)
                    
                    Text("KMM benchmarks:").fontWeight(.semibold)
                    
                    Group {
                        Button("Run FannkuchRedux KMM") {
                            changeText(newText: "FannkuchRedux KMM, n = \(experiments.nFannkuchRedux)")
                            experiments.benchFannkuchReduxKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run NBody KMM") {
                            changeText(newText: "NBody KMM, n = \(experiments.nNBody)")
                            experiments.benchNBodyKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run Fasta KMM") {
                            changeText(newText: "Fasta KMM, n = \(experiments.nFasta)")
                            experiments.benchFastaKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run Reverse Complement KMM") {
                            changeText(newText: "RC KMM, n = \(experiments.inputFileReverseComplement)")
                            experiments.benchReverseComplementKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run HTTP request KMM") {
                            changeText(newText: "HTTP KMM, n = \(experiments.nHttpRequester)")
                            experiments.benchHttpRequesterKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run ONE HTTP request KMM") {
                            changeText(newText: "ONE HTTP KMM")
                            experiments.benchHttpRequesterKmm_ONE()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run parsing KMM") {
                            changeText(newText: "Parsing KMM, n = \(experiments.jsonInputFile)")
                            experiments.benchJsonParserKmm()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run DB KMM") {
                            changeText(newText: "DB KMM, n = \(experiments.nDatabase)")
                            experiments.benchDatabaseOperatorKmm()
                        }.foregroundColor(Color.purple)
                    }
                    
                    Text("NATIVE benchmarks:").fontWeight(.semibold).padding(.top, 3)
                    
                    Group {
                        Button("Run FannkuchRedux Native") {
                            changeText(newText: "FannkuchRedux Native, n = \(experiments.nFannkuchRedux)")
                            experiments.benchFannkuchReduxNative()
                        }
                        
                        Button("Run NBody Native") {
                            changeText(newText: "NBody Native, n = \(experiments.nNBody)")
                            experiments.benchNBodyNative()
                        }
                        
                        Button("Run Fasta Native") {
                            changeText(newText: "Fasta Native, n = \(experiments.nFasta)")
                            experiments.benchFastaNative()
                        }
                        
                        Button("Run Reverse Complement Native") {
                            changeText(newText: "RC Native, n = \(experiments.inputFileReverseComplement)")
                            experiments.benchReverseComplementNative()
                        }
                        
                        Button("Run HTTP request Native") {
                            changeText(newText: "HTTP Native, n = \(experiments.nHttpRequester)")
                            experiments.benchHttpRequesterNative()
                        }
                        
                        Button("Run ONE HTTP request Native") {
                            changeText(newText: "ONE HTTP Native")
                            experiments.benchHttpRequesterNative_ONE()
                        }
                        
                        Button("Run parsing Native") {
                            changeText(newText: "Parsing Native, n = \(experiments.jsonInputFile)")
                            experiments.benchJsonParserNative()
                        }
                        
                        Button("Run DB Native") {
                            changeText(newText: "DB Native, n = \(experiments.nDatabase)")
                            experiments.benchDatabaseOperatorNative()
                        }
                    }
                    
                    Text("Database ONE benchmarks:").fontWeight(.semibold).padding(.top, 3)
                    
                    Group {
                        Button("Run DB INSERT_ONE KMM") {
                            experiments.benchDatabaseOperatorKmm_INSERT_ONE()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run DB SELECT_ONE KMM") {
                            experiments.benchDatabaseOperatorKmm_SELECT_ONE()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run DB UPDATE_ONE KMM") {
                            experiments.benchDatabaseOperatorKmm_UPDATE_ONE()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run DB DELETE_ONE KMM") {
                            experiments.benchDatabaseOperatorKmm_DELETE_ONE()
                        }.foregroundColor(Color.purple)
                        
                        Button("Run DB INSERT_ONE Native") {
                            experiments.benchDatabaseOperatorNative_INSERT_ONE()
                        }
                        
                        Button("Run DB SELECT_ONE Native") {
                            experiments.benchDatabaseOperatorNative_SELECT_ONE()
                        }
                        
                        Button("Run DB UPDATE_ONE Native") {
                            experiments.benchDatabaseOperatorNative_UPDATE_ONE()
                        }
                        
                        Button("Run DB DELETE_ONE Native") {
                            experiments.benchDatabaseOperatorNative_DELETE_ONE()
                        }
                    }/*
                    Text("Miscellaneous functions:").fontWeight(.semibold).padding(.top, 3)
                    Group {
                        Button("Run CLBG Tests") {
                            self.ruBenchmarkTests()
                        }.foregroundColor(Color.orange)
                        
                        Button("Run DB NATIVE tests") { // Remember to remove the comments for these tests in the DatabaseOperatorNative class.
                            //DatabaseOperatorNative().testBenchmark(n: 10)
                        }.foregroundColor(Color.orange)
                        
                        Button("Run DB KMM tests") { // Remember to remove the comments for these tests
                            //DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory()).testBenchmark(n: 10)
                        }.foregroundColor(Color.orange)
                    
                        Button("Clear kmm db") {
                            DatabaseOperatorKmm(driverFactory: DatabaseDriverFactory()).resetDatabaseAfterOneOperationTests()
                        }.foregroundColor(Color.orange)
                    
                        Button("Clear Native db") {
                            do {
                                try DatabaseOperatorNative().resetDatabaseAfterOneOperationTests()
                            } catch {
                                print(error)
                            }
                        }.foregroundColor(Color.orange)
                    }*/
                    
                }.navigationTitle("BenchRunner")
            }
            .padding()
    }

    func ruBenchmarkTests() {
        print("Running CLBG benchmark tests")
        let testObj = kmmTests()
        testObj.testFannkuchRedux()
        testObj.testNBody()
        testObj.testFasta()
        testObj.testReverseComplement()
    }
    
    func changeText(newText: String) {
        displayText = newText
    }
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
