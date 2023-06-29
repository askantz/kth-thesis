import matplotlib.pyplot as plt
import numpy as np
import sys
        
def parse_input(filename, approach, argNum):
    lines = np.genfromtxt(filename, delimiter='\n', dtype=str)

    if not lines[0].startswith(approach):
        print("Usage: python3 plotExecutionTime.py <KMM filename> <NATIVE filename>\n You did not provide a " + approach + " filename at arg = " + str(argNum))
        print("starts with: "  + lines[0])
        sys.exit(1)

    benchName = lines[1].split(" ")[0]
    collectMeasurments = False
    timeIt = 1
    cpu = []
    memory = []
    timestamp = []
    measurements = []
    
    for line in lines:
        if line.startswith("TIME"):
            break
        if line.startswith("---"):
            collectMeasurments = True
        elif line.startswith("Execution time"):
            collectMeasurments = False
            measurements.append([cpu, memory, timestamp])
            cpu = []
            memory = []
            timestamp = []
        elif collectMeasurments == True:
            values = line.split(" | ")
            cpu.append(float(values[0]))
            memory.append(float(values[1]))
            timestamp.append(float(values[2]))
    
    return measurements, benchName
    
def parse_time_input(filename, approach, argNum):
    lines = np.genfromtxt(filename, delimiter='\n', dtype=str)

    benchName = lines[1].split(" ")[0]
    isTimeMeasurements = False
    timeIt = 1
    y = []
    for line in lines:
        if line.startswith("TIME for"):
            isTimeMeasurements = True
        elif isTimeMeasurements == True:
            if timeIt > 10: # we only want measurements 10-110
                y.append(float(line)*1000) # convert to millisseconds
            timeIt += 1
    
    return y
    
def concatenate_measurements_from_iterations(measurements):
    cpu_concatenated = []
    memory_concatenated = []
    # Contacenate all cpu and memory measurements from all iterations 10-110
    for measurement in measurements[10:]:
        cpu_concatenated = cpu_concatenated + measurement[0]
        memory_concatenated = memory_concatenated + measurement[1]
    
    return cpu_concatenated, memory_concatenated
      
# Calculate standard deviation of all measurements (it 10-110)
# std calculates: std = sqrt(mean(x))/(N - ddof), where x = abs(a - a.mean())**2.
# https://numpy.org/doc/stable/reference/generated/numpy.std.html
def calc_stds(time_measurements, cpu_measurements, memory_measurements):
    
    time_std = np.std(time_measurements, ddof = 1)
    cpu_std = np.std(cpu_measurements, ddof = 1)
    memory_std = np.std(memory_measurements, ddof = 1)
    
    return time_std, cpu_std, memory_std
    
def calc_ci(std, n):
    return 1.96 * std/np.sqrt(n)
        
def print_mean_and_ci(title, mean, ci):
    s = title + ': ' + str(mean) + ' ± ' + str(ci)
    print(s)
    return s
    
def main_only_time_execution(filenameKMM, filenameNATIVE):
    time_measurements_kmm = parse_time_input(filenameKMM, "KMM", 1)
    time_measurements_native = parse_time_input(filenameNATIVE, "NATIVE", 2)
    
    # Calculate mean value of the measurements
    mean_time_kmm = np.mean(time_measurements_kmm)
    mean_time_native = np.mean(time_measurements_native)
    
    # Get the standard deviation of the measurements
    time_std_kmm = np.std(time_measurements_kmm, ddof = 1)
    time_std_native = np.std(time_measurements_native, ddof = 1)
    
    # Calculate confidence interval
    ci_time_kmm = calc_ci(time_std_kmm, len(time_measurements_kmm))
    ci_time_native = calc_ci(time_std_native, len(time_measurements_native))
    
    # Print the mean values and confidence interval
    mean_and_ci_time_kmm = print_mean_and_ci('TIME KMM', mean_time_kmm, ci_time_kmm)
    mean_and_ci_time_native = print_mean_and_ci('TIME Native', mean_time_native, ci_time_native)
    
    return mean_and_ci_time_kmm, mean_and_ci_time_native

    
# Sample usage: python3 calcMeanMemoryAndCPU.py '../results/FannkuchRedux/KMM_FannkuchRedux_2023-05-22T16:38:18.txt' '../results/FannkuchRedux/NATIVE_FannkuchRedux_2023-05-22T16:24:52.txt'
def main(filenameKMM, filenameNATIVE):
    # Parse the input files
    time_measurements_kmm = parse_time_input(filenameKMM, "KMM", 1)
    measurements_kmm, benchNameKMM = parse_input(filenameKMM, "KMM", 1)
    
    time_measurements_native = parse_time_input(filenameNATIVE, "NATIVE", 2)
    measurements_native, benchNameNATIVE = parse_input(filenameNATIVE, "NATIVE", 2)
    
    # Check if the benchmark names match
    if benchNameKMM != benchNameNATIVE:
        print("Usage: python3 plotExecutionTime.py <KMM filename> <NATIVE filename>\n You did not provide data from two of the same benchmarks, check the input data.")
        sys.exit(1)
       
    conc_cpu_kmm, conc_memory_kmm = concatenate_measurements_from_iterations(measurements_kmm)
    conc_cpu_native, conc_memory_native = concatenate_measurements_from_iterations(measurements_native)

    # Calculate mean value of the measurements
    mean_time_kmm = np.mean(time_measurements_kmm)
    mean_cpu_kmm = np.mean(conc_cpu_kmm)
    mean_memory_kmm = np.mean(conc_memory_kmm)

    mean_time_native = np.mean(time_measurements_native)
    mean_cpu_native = np.mean(conc_cpu_native)
    mean_memory_native = np.mean(conc_memory_native)

    # Get the total number of measurements
    n_kmm = len(conc_cpu_kmm)
    n_native = len(conc_cpu_native)
       
    # Get the standard deviation of the measurements
    time_std_kmm, std_cpu_kmm, std_memory_kmm = calc_stds(time_measurements_kmm, conc_cpu_kmm, conc_memory_kmm)
    time_std_native, std_cpu_native, std_memory_native = calc_stds(time_measurements_native, conc_cpu_native, conc_memory_native)

    # Calculate confidence interval
    ci_time_kmm = calc_ci(time_std_kmm, len(time_measurements_kmm))
    ci_cpu_kmm = calc_ci(std_cpu_kmm, n_kmm)
    ci_memory_kmm = calc_ci(std_memory_kmm, n_kmm)

    ci_time_native = calc_ci(time_std_native, len(time_measurements_native))
    ci_cpu_native = calc_ci(std_cpu_native, n_native)
    ci_memory_native = calc_ci(std_memory_native, n_native)

    # Print the mean values and confidence interval
    mean_and_ci_time_kmm = print_mean_and_ci('TIME KMM', mean_time_kmm, ci_time_kmm)
    mean_and_ci_cpu_kmm = print_mean_and_ci('CPU KMM', mean_cpu_kmm, ci_cpu_kmm)
    mean_and_ci_memory_kmm = print_mean_and_ci('Memory KMM', mean_memory_kmm, ci_memory_kmm)

    mean_and_ci_time_native = print_mean_and_ci('TIME Native', mean_time_native, ci_time_native)
    mean_and_ci_cpu_native = print_mean_and_ci('CPU Native', mean_cpu_native, ci_cpu_native)
    mean_and_ci_memory_native = print_mean_and_ci('Memory Native', mean_memory_native, ci_memory_native)
    
    return benchNameKMM, mean_and_ci_time_kmm, mean_and_ci_cpu_kmm, mean_and_ci_memory_kmm, mean_and_ci_time_native, mean_and_ci_cpu_native, mean_and_ci_memory_native

if __name__ == '__main__':
    # Check if the correct number of arguments is provided
    if len(sys.argv) != 3:
        print("Usage: python3 calcMeanMemoryAndCPU.py <filename> <filename>")
        sys.exit(1)

    # Get the filename from the command-line argument
    filenameKMM = sys.argv[1]
    filenameNATIVE = sys.argv[2]
    main(filenameKMM, filenameNATIVE)
