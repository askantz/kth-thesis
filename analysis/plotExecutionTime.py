import matplotlib.pyplot as plt
import numpy as np
import sys
        
def parse_input(filename, approach, argNum):
    lines = np.genfromtxt(filename, delimiter='\n', dtype=str)

    if not lines[0].startswith(approach):
        print("TEST: " + lines[0])
        print("Usage: python3 plotExecutionTime.py <KMM filename> <NATIVE filename>\n You did not provide a " + approach + " filename at arg = " + str(argNum))
        sys.exit(1)

    benchName = lines[1].split(" ")[0]
    isTimeMeasurements = False
    timeIt = 1
    x = []
    y = []
    for line in lines:
        if line.startswith("TIME for"):
            isTimeMeasurements = True
        elif isTimeMeasurements == True:
            if timeIt > 10:
                x.append(timeIt-10) # we only want measurements 10-110
                y.append(float(line))
            timeIt += 1
    
    return x, y, benchName
    
def plot_line_and_ci(ax, x, y, ci, label):
    mean = round(np.mean(y), 6)
    ci_rounded = round(ci, 6)
    
    line, = ax.plot(x, y, label=label + ': ' + str(mean) + ' ± ' + str(ci_rounded))
    color = line.get_color()
    ax.fill_between(x, (y-ci), (y+ci), color=color, alpha=.2)

def plot_line_execution_time(x_kmm, y_kmm, x_native, y_native, ci_kmm, ci_native, benchName):
    fig, ax = plt.subplots(gridspec_kw={'bottom': 0.2})
    
    plot_line_and_ci(ax, x_kmm, y_kmm, ci_kmm, 'KMM')
    plot_line_and_ci(ax, x_native, y_native, ci_native, 'Native')
    
    ax.set_xlabel('Iteration')
    ax.set_ylabel('Execution time [s]')
    ax.set_title(benchNameKMM)

    #plt.legend()
    # Put a legend below current axis
    ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15),
          fancybox=True, shadow=True, ncol=5)
    plt.show()
    
def plot_bars_execution_time(y_kmm, y_native, ci_kmm, ci_native, benchNameKMM):
    mean_kmm = round(np.mean(y_kmm) * 1000, 2) #(s to ms)
    mean_native = round(np.mean(y_native) * 1000, 2)
    ci_kmm = round(ci_kmm * 1000, 2)
    ci_native = round(ci_native * 1000, 2)
    
    y = [mean_kmm, mean_native]
    labels = ['KMM', 'Native']
    
    # Calculate the width for each bar
    bar_width = 0.5
    colors = ['blue', 'orange']
    x_pos = np.arange(len(labels))
    x_pos = [0, 1]
    labels = ['KMM: ' + str(mean_kmm) + ' ± ' + str(ci_kmm),
              'Native: '+ str(mean_native) + ' ± ' + str(ci_kmm)]
    
    fig, ax = plt.subplots()
    ax.bar(x_pos, y, width=bar_width, align='center', color=colors, label=labels)
    # Plot the error bars
    #ax.errorbar(x_pos, y, yerr=[ci_kmm, ci_native], fmt='none', capsize=4, color='black')
    #ax.errorbar(x_pos, y, yerr=[2*ci_kmm, 2*ci_native], xerr=0.2, linestyle='', color='black')
    ax.errorbar(x_pos[0],y[0],yerr=2*ci_kmm, linestyle='', color='black')
    ax.errorbar(x_pos[1],y[1],yerr=2*ci_native, linestyle='', color='black')
    
    ax.set_xlabel('Approach')
    ax.set_ylabel('Execution time [ms]')
    ax.set_title(benchNameKMM)
    plt.xticks(x_pos, labels)
    
        # Put a legend below current axis
    ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15),
          fancybox=True, shadow=True, ncol=5)
    plt.show()
    
# Check if the correct number of arguments is provided
if len(sys.argv) != 3:
    print("Usage: python3 plotExecutionTime.py <filename> <filename>")
    sys.exit(1)

# Get the filename from the command-line argument
filenameKMM = sys.argv[1]
filenameNATIVE = sys.argv[2]

# Parse the input files
x_kmm, y_kmm, benchNameKMM = parse_input(filenameKMM, "KMM", 1)
x_native, y_native, benchNameNATIVE = parse_input(filenameNATIVE, "NATIVE", 2)

# Check if the benchmark names match
if benchNameKMM != benchNameNATIVE:
    print("Usage: python3 plotExecutionTime.py <KMM filename> <NATIVE filename>\n You did not provide data from two of the same benchmarks, check the input data.")
    sys.exit(1)
    
# Calculate standard deviation
# std calculates: std = sqrt(mean(x))/(N - ddof), where x = abs(a - a.mean())**2.
# https://numpy.org/doc/stable/reference/generated/numpy.std.html
std_kmm = np.std(y_kmm, ddof = 1)
std_native = np.std(y_native, ddof = 1)

# Calculate confidence interval
ci_kmm = 1.96 * std_kmm/np.sqrt(len(x_kmm))
ci_native = 1.96 * std_native/np.sqrt(len(x_native))
    
# Plot the execution time in a line chart
# plot_line_execution_time(x_kmm, y_kmm, x_native, y_native, ci_kmm, ci_native, benchNameKMM)

# Plot bar chart of execution time
plot_bars_execution_time(y_kmm, y_native, ci_kmm, ci_native, benchNameKMM)
