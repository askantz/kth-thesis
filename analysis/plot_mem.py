'''import matplotlib.pyplot as plt
import os
import sys
import re

RE = re.compile(r"(\d+.\d+) \| (\d+.\d+) \| (\d+.\d+)")

def getsamples(lines): # addd option to choose to extract memory or cpu
    cpusamples = []
    cpubuffer = []
    memorysamples = []
    memorybuffer = []
    
    for line in lines:
        if line.strip() == "---":
            cpusamples.append(cpubuffer)
            memorysamples.append(memorybuffer)
            
            cpubuffer = []
            memorybuffer = []
        if RE.search(line):
            g =  RE.search(line).groups()
            cpubuffer.append([float(g[0]),float(g[2])])
            memorybuffer.append([float(g[1]),float(g[2])])
            
    return cpusamples[10:], memorysamples[10:]  # We only want the 10-110 samples

def plotDifferential(samples, ax):
    
    for i, k in enumerate(samples):
        timestamp0 = samples[i][0][1]
        #timestampi = samples[i][0][1]
        #time = timestampi - timestamp0
        print(k)
        
        print(timestamp0)
        print(samples[i][1][1])
        print(samples[i][1])
        #newarr = samples[i][1] - timestamp0
        #print(newarr)
        
        print("time 0: " + str(timestamp0))
        print("time i: " + str(timestampi))
        print("time: " + str(time))
        
        prev = 0
        if i > 0:
            #prev = samples[i-1][0][0] # prev before did not take the start timestamp, but the start cpu %
            prev = samples[i-1][0][0]
            timestamp0 = samples[i-1][0][1]
            timestamps = []
            j = 0
            for sample in samples[i-1]:
                timestamps[j] = sample[1] - timestamp0
                j += 1
            #print("prev:" + str(prev)) # TODO: why do he take -prev if it is not the start time (prev will be the same for all values??)
            
        if k:
            #plt.hist([x[0] - prev for x in k],
            #    alpha=0.5, bins=100)
            #print("k[1:]:")
            #print(k[1:])
            
            stepover = [x[0] - prev for x in k[1:]]
            steps = [x[0] - prev for x in k]
            #print("stepover: ")
            #print(stepover)
            #print("steps: ")
            #print(steps)
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            ax.text(0, s[0] - prev, f"{i}")
            

def plotDifferentialOld(samples, ax):
    for i, k in enumerate(samples):

        prev = 0
        if i > 0:
            prev = samples[i-1][0][0]
        if k:
            #plt.hist([x[0] - prev for x in k],
            #    alpha=0.5, bins=100)
            
            stepover = [x[0] - prev for x in k[1:]]
            steps = [x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            ax.text(0, s[0] - prev, f"{i}")

if __name__ == "__main__":
    
    kmm = open(sys.argv[1], 'r').readlines()
    native = open(sys.argv[2], 'r').readlines()

    #print(kmmsamples)
    kmmcpusamples, kmmmemorysamples = getsamples(kmm)
    nativecpusamples, nativememorysamples = getsamples(native)
    
    fig1, ax1 = plt.subplots()
    plotDifferential(kmmcpusamples, ax1)
    
    fig2, ax2 = plt.subplots()
    plotDifferential(nativecpusamples, ax2)
    
    #plt.scatter(kmmts, kmmsamples, alpha=0.1, color='C0')
    #plt.scatter(nativets, nativesamples, alpha=0.5, color='C1')
    # plt.ylim(15)
    # plt.legend()
    plt.show()


# TODO: Check if size of samples are 100? I think we might append an empty array first due to the line "if line.strip() == "---":" ALT: check first array in samples.'''

'''
def getFiles(benchname):
    if benchname == 'Fannkuch-Redux':
        kmmFile = '../results/Fasta/KMM_Fasta_2023-05-22T12:39:49.txt'
        nativeFile = '../results/Fasta/NATIVE_Fasta_2023-05-22T12:32:58.txt'
    elif benchname == 'Fasta':
        kmmFile = '../results/Fasta/KMM_Fasta_2023-05-22T12:39:49.txt'
        nativeFile = '../results/Fasta/NATIVE_Fasta_2023-05-22T12:32:58.txt'
    elif benchname == 'N-body':
        kmmFile = '../results/NBody/KMM_NBody_2023-05-22T14:28:00.txt'
        nativeFile = '../results/NBody/NATIVE_NBody_2023-05-22T14:23:25.txt'
    elif benchname == 'Reverse-Complement':
        kmmFile = '../results/ReverseComplement/KMM_ReverseComplement_2023-05-22T15:06:24.txt'
        nativeFile = '../results/ReverseComplement/NATIVE_ReverseComplement_2023-05-22T15:20:13.txt'
    elif benchname == 'HTTP-Requester':
        kmmFile = '../results/HttpRequester/KMM_HttpRequester_2023-05-24T01:57:53.txt'
        nativeFile = '../results/HttpRequester/NATIVE_HttpRequester_2023-05-24T03:15:27.txt'
    elif benchname == 'JSON-Parser':
        kmmFile = '../results/JsonParser/KMM_JsonParser_2023-05-22T18:26:52.txt'
        nativeFile = '../results/JsonParser/NATIVE_JsonParser_2023-05-22T18:21:31.txt'
    elif benchname == 'DatabaseOperator':
        kmmFile = '../results/DatabaseOperator/KMM_DatabaseOperator_2023-05-22T17:12:30.txt'
        nativeFile = '../results/DatabaseOperator/NATIVE_DatabaseOperator_2023-05-22T17:07:14.txt'
    else:
        print('You did not provide a correct benchmark name')
        sys.exit(1)
        
    return kmmFile, nativeFile
    
    ISSUE IN JSON-Parser file:
    
    142.10000000000002 | 719.5496826171875 | 91635.52423058334
142.10000000000002 | 743.3622436523438 | 91635.54100833334
142.10000000000002 | 766.0653686523438 | 91635.55756533334
142.10000000000002 | 789.5341796875 | 91635.574377875
142.10000000000002 | 794.7529296875 | 91635.59089558334
142.10000000000002 | 796.5966796875 | 91635.60756033334
142.10000000000002 | 599.5494384765625 | 91635.62416062501
142.10000000000002 | 602.9869384765625 | 91635.64090595834
155.7 | 605.0806884765625 | 91635.65754416668
155.7 | 606.1588134765625 | 91635.67432995833
155.7 | 604.3619384765625 | 91635.69098320833


155.7 | 514.1900634765625 | 91635.70750283333
155.7 | 502.5963134765625 | 91635.72428808334
155.7 | 513.8150634765625 | 91635.74079720835
155.7 | 525.4088134765625 | 91635.75760945833
134.4 | 536.3931884765625 | 91635.774265
134.4 | 547.7838134765625 | 91635.790778625
134.4 | 559.2838134765625 | 91635.80743887501
134.4 | 570.0806884765625 | 91635.82408783335
134.4 | 581.4088134765625 | 91635.84074958334

did not change anything when fixing this..
'''

#GOOGLE COLAB

import matplotlib.pyplot as plt
import os
import sys
import re
import pathlib
from brokenaxes import brokenaxes

RE = re.compile(r"(\d+.\d+) \| (\d+.\d+) \| (\d+.\d+)")

def getFiles(benchname):
    if benchname == 'Fannkuch-Redux':
        kmmFile = '../results/FannkuchRedux/KMM_FannkuchRedux_2023-05-22T16:38:18.txt'
        nativeFile = '../results/FannkuchRedux/NATIVE_FannkuchRedux_2023-05-22T16:24:52.txt'
    elif benchname == 'Fasta':
        kmmFile = '../results/Fasta/KMM_Fasta_2023-05-22T12:39:49.txt'
        nativeFile = '../results/Fasta/NATIVE_Fasta_2023-05-22T12:32:58.txt'
    elif benchname == 'N-body':
        kmmFile = '../results/NBody/KMM_NBody_2023-05-22T14:28:00.txt'
        nativeFile = '../results/NBody/NATIVE_NBody_2023-05-22T14:23:25.txt'
    elif benchname == 'Reverse-Complement':
        kmmFile = '../results/ReverseComplement/KMM_ReverseComplement_2023-05-22T15:06:24.txt'
        nativeFile = '../results/ReverseComplement/NATIVE_ReverseComplement_2023-05-22T15:20:13.txt'
    elif benchname == 'HTTP-Requester':
        kmmFile = '../results/HttpRequester/KMM_HttpRequester_2023-05-24T01:57:53.txt'
        nativeFile = '../results/HttpRequester/NATIVE_HttpRequester_2023-05-24T03:15:27.txt'
    elif benchname == 'JSON-Parser':
        kmmFile = '../results/JsonParser/KMM_JsonParser_2023-05-22T18:26:52.txt'
        nativeFile = '../results/JsonParser/NATIVE_JsonParser_2023-05-22T18:21:31.txt'
    elif benchname == 'DatabaseOperator':
        kmmFile = '../results/DatabaseOperator/KMM_DatabaseOperator_2023-05-22T17:12:30.txt'
        nativeFile = '../results/DatabaseOperator/NATIVE_DatabaseOperator_2023-05-22T17:07:14.txt'
    else:
        print('You did not provide a correct benchmark name')
        sys.exit(1)
        
    return kmmFile, nativeFile

def getsamples(lines):
    cpusamples = []
    cpubuffer = []
    memorysamples = []
    memorybuffer = []
    
    for line in lines:
        if line.strip() == "---":
            cpusamples.append(cpubuffer)
            memorysamples.append(memorybuffer)
            
            cpubuffer = []
            memorybuffer = []
        if RE.search(line):
            g =  RE.search(line).groups()
            
            cpubuffer.append([float(g[0]),float(g[2])])
            memorybuffer.append([float(g[1]),float(g[2])])
            
    return cpusamples[10:], memorysamples[10:]  # We only want the 10-110 samples
    
def plotDifferential(samples, ax, benchName, impl, xlabel, ylabel):
    for i, k in enumerate(samples):
        #print(k)

        prev = 0
        #if i > 0:
            #prev = samples[i-1][0][0] # I do not think we need prev. Does not seem to change result.
        if k:
            stepover = [x[0] for x in k[1:]] # [x[0] - prev for x in k[1:]]
            steps = [x[0] for x in k]        #[x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))),
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            #ax.text(0, s[0], f"{i}")
            ax.set_title(benchName + " " + impl)
            ax.set_xlabel(xlabel)
            ax.set_ylabel(ylabel)
            
# Change benchname to generate figures for other benchmarks
benchnames = ['Fannkuch-Redux', 'Fasta', 'N-body', 'Reverse-Complement', 'HTTP-Requester', 'JSON-Parser', 'DatabaseOperator']
benchname = benchnames[5] # issues with nr 3: prev = samples[i-1][0][0] --> "IndexError: list index out of range" - solved by removing prev
kmmFile, nativeFile = getFiles(benchname)

kmm = open(kmmFile, 'r').readlines()
native = open(nativeFile, 'r').readlines()

kmmcpusamples, kmmmemorysamples = getsamples(kmm)
nativecpusamples, nativememorysamples = getsamples(native)

# Plot CPU:
yaxistitle = 'Differential CPU (%)'
fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(6, 8))
plotDifferential(kmmcpusamples, axes[0], benchname, 'KMM', 'Samples over time', yaxistitle)
plotDifferential(nativecpusamples, axes[1], benchname, 'Native', 'Samples over time', yaxistitle)
plt.subplots_adjust(hspace=0.3)
axes[0].set_ylim(-30, 35)
axes[1].set_ylim(-30, 35)

# Plot Memory:
yaxistitle = 'Differential Memory (Mb)'
fig2, axes2 = plt.subplots(nrows=2, ncols=1, figsize=(6, 8))
plotDifferential(kmmmemorysamples, axes2[0], benchname, 'KMM', 'Samples over time', yaxistitle)
plotDifferential(nativememorysamples, axes2[1], benchname, 'Native', 'Samples over time', yaxistitle)
plt.subplots_adjust(hspace=0.3)
axes2[0].set_ylim(-210, 110)
axes2[1].set_ylim(-210, 110)
plt.show()

'''
def plotDifferentialBax(samples, bax, benchName, impl, xlabel, ylabel):
    for i, k in enumerate(samples):
        print(k)

        prev = 0
        #if i > 0:
            #prev = samples[i-1][0][0] # STRUNTAR I PREV
            #print(prev)
        if k:
            stepover = [x[0] for x in k[1:]] # [x[0] - prev for x in k[1:]]
            steps = [x[0] for x in k]        #[x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            bax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            #bax.text(0, s[0], f"{i}")
            bax.set_title(benchName + " " + impl)
            bax.set_xlabel(xlabel)
            bax.set_ylabel(ylabel)

# Plot Memory with broken y-axis:
yaxistitle = 'Differential Memory (Mb)'
fig3 = plt.figure()
bax1 = brokenaxes(ylims=((-210, -90), (-40, 50)))
plotDifferentialBax(kmmmemorysamples, bax1, benchname, 'KMM', 'TODO', yaxistitle)
plt.subplots_adjust(hspace=0.3)

# Plot Memory with broken y-axis:
yaxistitle = 'Differential Memory (Mb)'
fig3 = plt.figure()
bax2 = brokenaxes(ylims=((-120, -90), (-20, 20), (90, 110)))
plotDifferentialBax(nativememorysamples, bax2, benchname, 'Native', 'TODO', yaxistitle)
plt.subplots_adjust(hspace=0.3)
plt.show()
'''

'''
CODE FROM GOOGLE COLAB THAT ENABLES SEPERATE PLOTTING FOR CPU AND MEMORY (SWITCHED 21/6)
def getsamples(lines):
    cpusamples = []
    cpubuffer = []
    memorysamples = []
    memorybuffer = []
    
    for line in lines:
        if line.strip() == "---":
            cpusamples.append(cpubuffer)
            memorysamples.append(memorybuffer)
            
            cpubuffer = []
            memorybuffer = []
        if RE.search(line):
            g =  RE.search(line).groups()
            cpubuffer.append([float(g[0]),float(g[2])])
            memorybuffer.append([float(g[1]),float(g[2])])
            
    return cpusamples[10:], memorysamples[10:]  # We only want the 10-110 samples

def plotDifferential(samples, ax, benchName, impl, xlabel, ylabel):
    for i, k in enumerate(samples):

        prev = 0
        if i > 0:
            prev = samples[i-1][0][0]
        if k:
            #plt.hist([x[0] - prev for x in k],
            #    alpha=0.5, bins=100)
            
            stepover = [x[0] - prev for x in k[1:]]
            steps = [x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            ax.text(0, s[0] - prev, f"{i}")
            ax.set_title(benchName + " " + impl)
            ax.set_xlabel(xlabel)
            ax.set_ylabel(ylabel)

# Plot CPU:
def plotcpu():
    yaxistitle = 'Differential CPU (%)'
    fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(6, 8))
    plotDifferential(kmmcpusamples, axes[0], benchname, 'KMM', 'TODO', yaxistitle)
    plotDifferential(nativecpusamples, axes[1], benchname, 'Native', 'TODO', yaxistitle)
    plt.subplots_adjust(hspace=0.3)

# Plot Memory:
def plotmemory():
    yaxistitle = 'Differential Memory (Mb)'
    fig2, axes2 = plt.subplots(nrows=2, ncols=1, figsize=(6, 8))
    plotDifferential(kmmmemorysamples, axes2[0], benchname, 'KMM', 'TODO', yaxistitle)
    plotDifferential(nativememorysamples, axes2[1], benchname, 'Native', 'TODO', yaxistitle)
    plt.subplots_adjust(hspace=0.3)

# Change benchname to generate figures for other benchmarks
benchnames = ['Fannkuch-Redux', 'Fasta', 'N-body', 'Reverse-Complement', 'HTTP-Requester', 'JSON-Parser', 'DatabaseOperator']
benchname = benchnames[0] # issues with nr 3: prev = samples[i-1][0][0] --> "IndexError: list index out of range" - TODO: find error and generate plot

# Change plotMetric to generate figures for other metric
plotmetrics = ['cpu', 'memory', 'both']
plotmetric = plotmetrics[2]

kmmFile, nativeFile = getFiles(benchname)
kmm = open(kmmFile, 'r').readlines()
native = open(nativeFile, 'r').readlines()

kmmcpusamples, kmmmemorysamples = getsamples(kmm)
nativecpusamples, nativememorysamples = getsamples(native)

if plotmetric == 'cpu':
    plotcpu()
elif plotmetric == 'memory':
    plotmemory()
elif plotmetric == 'both': # Recieves error when running in google colab (due to too large image), works when running locally
    plotcpu()
    plotmemory()

#plt.scatter(kmmts, kmmsamples, alpha=0.1, color='C0')
#plt.scatter(nativets, nativesamples, alpha=0.5, color='C1')
# plt.ylim(15)
# plt.legend()

plt.show()

'''

'''
The old function
# samples = iterations[ measurements[ [mem/cpu, timestmp] ] ]
# prev = first measurement in the iteration before i

def plotDifferentialOLD(samples, ax, benchName, impl, xlabel, ylabel):
    for i, k in enumerate(samples):
        print(k)

        prev = 0
        if i > 0:
            prev = samples[i-1][0][0]
            if prev > 600:
                print("HERE!!!!!!!!!!!!!!!")
                print(samples[i-1])
                print("prev: " + str(prev))
            #print(prev)
        if k:
            #plt.hist([x[0] - prev for x in k],
            #    alpha=0.5, bins=100)
            
            stepover = [x[0] - prev for x in k[1:]]
            steps = [x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                #label=f"{i}"
            )
            s = k[0]
            ax.text(0, s[0] - prev, f"{i}")
            ax.set_title(benchName + " " + impl)
            ax.set_xlabel(xlabel)
            ax.set_ylabel(ylabel)
'''

'''
TEST:
def plotDifferentialTest(samples, ax, benchName, impl, xlabel, ylabel):
    for i, k in enumerate(samples):
        prev = []
        stepover = []
        steps = []
        
        for j, d in enumerate(k):
            prev.append(d[0])
                
        if i > 0:
            
            #stepover = [x[0] - prev for x in k[1:]]
            for j, d in enumerate(k[1:]): # we use k[1:] since we want to do this for all indexes > 0
                stepover.append(d[0] - prev[j])
                steps.append()
            
            
            steps = [x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            ax.plot(
                list(range(len(zz))), # old x: list(range(len(zz)))
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"
            )
            s = k[0]
            ax.text(0, s[0] - prev, f"{i}")
            ax.set_title(benchName + " " + impl)
            ax.set_xlabel(xlabel)
            ax.set_ylabel(ylabel)'''

