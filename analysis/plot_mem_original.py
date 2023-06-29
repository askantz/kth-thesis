
import matplotlib.pyplot as plt
import os
import sys
import re

RE = re.compile(r"(\d+.\d+) \| (\d+.\d+) \| (\d+.\d+)")

if __name__ == "__main__":
    
    kmm = open(sys.argv[1], 'r').readlines()
    native = open(sys.argv[2], 'r').readlines()

    kmmsamples = []
    buffer = []
    for k in kmm:
        if k.strip() == "---":
            kmmsamples.append(buffer)
            buffer = []
        if RE.search(k):
            g =  RE.search(k).groups()
            buffer.append([float(g[0]),float(g[2])]) # changed from g[0] to g[1] to collect memory plots


    print(kmmsamples)
    kmmsamples = kmmsamples[10:]
    for i, k in enumerate(kmmsamples):

        prev = 0
        if i > 0:
            prev = kmmsamples[i-1][0][0]
        if k:
            #plt.hist([x[0] - prev for x in k],
            #    alpha=0.5, bins=100)
            
            stepover = [x[0] - prev for x in k[1:]]
            steps = [x[0] - prev for x in k]
            zz = zip(stepover, steps)
            zz = list(zz)
            plt.plot(
                list(range(len(zz))),
                #[x[1] - k[0][1] for x in k],
                [x[0] - x[1] for x in zz],
                '.--',
                alpha=0.5,
                label=f"{i}"

            )
            s = k[0]
            plt.text(0, s[0] - prev, f"{i}")
    #plt.scatter(kmmts, kmmsamples, alpha=0.1, color='C0')
    #plt.scatter(nativets, nativesamples, alpha=0.5, color='C1')
    # plt.ylim(15)
    # plt.legend()
    plt.show()
