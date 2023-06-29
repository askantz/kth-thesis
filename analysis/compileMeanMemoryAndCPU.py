import subprocess
import calcMeanMemoryAndCPU as cmmc

filenames = [['../results/FannkuchRedux/KMM_FannkuchRedux_2023-05-22T16:38:18.txt','../results/FannkuchRedux/NATIVE_FannkuchRedux_2023-05-22T16:24:52.txt'],
             ['../results/Fasta/KMM_Fasta_2023-05-22T12:39:49.txt','../results/Fasta/NATIVE_Fasta_2023-05-22T12:32:58.txt'],
             ['../results/NBody/KMM_NBody_2023-05-22T14:28:00.txt','../results/NBody/NATIVE_NBody_2023-05-22T14:23:25.txt'],
             ['../results/ReverseComplement/KMM_ReverseComplement_2023-05-22T15:06:24.txt','../results/ReverseComplement/NATIVE_ReverseComplement_2023-05-22T15:20:13.txt'],
             ['../results/HttpRequester/KMM_HttpRequester_2023-05-24T01:57:53.txt','../results/HttpRequester/NATIVE_HttpRequester_2023-05-24T03:15:27.txt'],
             ['../results/JsonParser/KMM_JsonParser_2023-05-22T18:26:52.txt','../results/JsonParser/NATIVE_JsonParser_2023-05-22T18:21:31.txt'],
             ['../results/DatabaseOperator/KMM_DatabaseOperator_2023-05-22T17:12:30.txt','../results/DatabaseOperator/NATIVE_DatabaseOperator_2023-05-22T17:07:14.txt']]
             
filenames_time_only = [['../results/HttpRequester/KMM_HttpRequester_ONE_2023-05-24T01:58:42.txt', '../results/HttpRequester/NATIVE_HttpRequester_ONE_2023-05-24T03:16:36.txt', 'HttpRequester_ONE'],
                       ['../results/DatabaseOperator/KMM_DatabaseOperator_INSERT_ONE_2023-05-22T23:25:18.txt', '../results/DatabaseOperator/NATIVE_DatabaseOperator_INSERT_ONE_2023-05-22T23:25:31.txt', 'INSERT_ONE'],
                       ['../results/DatabaseOperator/KMM_DatabaseOperator_SELECT_ONE_2023-05-22T23:25:48.txt', '../results/DatabaseOperator/NATIVE_DatabaseOperator_SELECT_ONE_2023-05-22T23:26:03.txt', 'SELECT_ONE'],
                       ['../results/DatabaseOperator/KMM_DatabaseOperator_UPDATE_ONE_2023-05-22T23:26:20.txt', '../results/DatabaseOperator/NATIVE_DatabaseOperator_UPDATE_ONE_2023-05-22T23:26:35.txt', 'UPDATE_ONE'],
                       ['../results/DatabaseOperator/KMM_DatabaseOperator_DELETE_ONE_2023-05-22T23:26:51.txt', '../results/DatabaseOperator/NATIVE_DatabaseOperator_DELETE_ONE_2023-05-22T23:27:08.txt', 'DELETE_ONE']]

with open('meanCPUandMemory.txt', 'w') as f:
    for filename in filenames:
        benchName, time_kmm, cpu_kmm, memory_kmm, time_native, cpu_native, memory_native = cmmc.main(filename[0], filename[1])
        
        print(benchName + ':', file=f)
        print(time_kmm, file=f)
        print(time_native, file=f)
        print(cpu_kmm, file=f)
        print(cpu_native, file=f)
        print(memory_kmm, file=f)
        print(memory_native + '\n', file=f)
        
    for filename in filenames_time_only:
        time_kmm, time_native = cmmc.main_only_time_execution(filename[0], filename[1])

        print(filename[2] + ':', file=f)
        print(time_kmm, file=f)
        print(time_native + '\n', file=f)
