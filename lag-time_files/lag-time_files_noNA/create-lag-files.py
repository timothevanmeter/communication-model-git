import numpy as np
import pandas as pd
import sys
from os import system
from scipy.stats.stats import pearsonr


#################
# Print iterations progress
def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 0, length = 100, fill = "=", printEnd = "\r"):
    """
    #Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print('\r%s |%s| %s%% %s' % (prefix, bar, percent, suffix) )#, end = printEnd)
    # Print New Line on Complete
    if iteration == total: 
        print()
#################


title = "# P1 size difference,  P2 size difference, P1 AI difference, P2 AI difference"

# Initialisation of variables
#p1size, p1ai, p2size, p2ai = [0.0 for _ in range(4)]

# The following depends of the number of alphabet categories present:
p1size, p1ai, p2size, p2ai, p1sizedif, p1aidif, p2sizedif, p2aidif = [ [] for _ in range(8)]
tempmeanp1, tempmeanp2, tempcorrp1, tempcorrp2, temp1sd, temp2sd, temp1ad, temp2ad = [ 0.0 for _ in range(8)]

# Specify the range of lag sizes to explore:
lagstep = 10
lagsize = range(10,40,lagstep)


# Creating the empty tables for correlation measures:
p1corr = [ [ 0.0 for _ in range(len(sys.argv[1:])) ] for _ in lagsize]
p2corr = [ [ 0.0 for _ in range(len(sys.argv[1:])) ] for _ in lagsize]


# Print to output:
out = True
#out = False
# Produce graphs:
graph = True
#graph = False
# Print correlations to file:
corrprint = True
#corrprint = False

# Usage for multiple files:
# The script is called with the list of files to use with the following
#       python create-lag-files output-netlogo*

# Counter for the progress bar:
j = 0

# Calling all the files in a loop:
for h in sys.argv[1:]:
    # Read from current file:
    df = pd.read_csv( h , sep=" ")
    ########
    p1size = df.iloc[:,0]
    p1ai = df.iloc[:,1]
    p2size = df.iloc[:,2]
    p2ai = df.iloc[:,3]
    maxl = len(p1size)
    
    #print '###         ', j
    printProgressBar(j, len(sys.argv[1:]), prefix="PROGRESSION")
    # Increment counter
    j = j + 1

    # Range of time lag files created:
    for n in lagsize:
        # Create the new lag-file for the output:
        tempname = h + "_lag-" + str(n)
        name = h + "_lag-" + str(n) + ".txt"
        
        if out == True:
            with open(name, 'w') as f: 
                #if out == True:
                print >> f, title
                for i in range(0, maxl):
                    # Make sure that the value exist:
                    if i+n < maxl:
                        temp1sd = round((p1size[i+n] - p1size[i]), 3)
                        temp2sd = round((p2size[i+n] - p2size[i]), 3) 
                        p1sizedif.append(p1size[i+n] - p1size[i])
                        p2sizedif.append(p2size[i+n] - p2size[i])
                    # Make sure that the value exist:
                    if i-n >= 0:
                        temp1ad = round((p1ai[i] - p1ai[i-n]), 3)
                        temp2ad = round((p2ai[i] - p2ai[i-n]), 3)
                        p1aidif.append(p1ai[i] - p1ai[i-n])
                        p2aidif.append(p2ai[i] - p2ai[i-n]) 
                    #if out == True:
                    print >> f, i, temp1sd, temp2sd, temp1ad, temp2ad
       
        if out == False:
            for i in range(0, maxl):
                # Make sure that the value exist:
                if i+n < maxl:
                    temp1sd = round((p1size[i+n] - p1size[i]), 3)
                    temp2sd = round((p2size[i+n] - p2size[i]), 3) 
                    p1sizedif.append(p1size[i+n] - p1size[i])
                    p2sizedif.append(p2size[i+n] - p2size[i])
                # Make sure that the value exist:
                if i-n >= 0:
                    temp1ad = round((p1ai[i] - p1ai[i-n]), 3)
                    temp2ad = round((p2ai[i] - p2ai[i-n]), 3)
                    p1aidif.append(p1ai[i] - p1ai[i-n])
                    p2aidif.append(p2ai[i] - p2ai[i-n])
                          
        # Calculating the correlation between the two measures:
        tempcorrp1 = round(np.corrcoef(p1sizedif, p1aidif)[1,0], 2)
        tempcorrp2 = round(np.corrcoef(p2sizedif, p2aidif)[1,0], 2)
        #print tempcorrp1
        #print tempcorrp2
        p1corr[int(n/lagstep-1)][int(j-1)] = tempcorrp1
        p2corr[int(n/lagstep-1)][int(j-1)] = tempcorrp2
    
    #print p1corr
    #print p2corr
    #print len(p1corr[:][0])
    #print "################"

    if corrprint == True:
       with open('lag-files_correlation.txt', 'w') as e:
           print >> e, "# Lag_size Mean-correlation_P1 Mean-correlation_P2"

           # For every n files in the table, we calculate the mean correlation
           # through all replications of a (population X Lag-time) combination
           for c in lagsize:
               #print "C = ", c
               tempmeanp1 = tempmeanp2 = 0
               for l in range(len(sys.argv[1:])):
                   #print "L = ", l
                   tempmeanp1 = tempmeanp1 + p1corr[int(c/lagstep-1)][l]
                   #print p1corr[int(c/lagstep-1)][l]
                   #print p2corr[int(c/lagstep-1)][l]
                   tempmeanp2 = tempmeanp2 + p2corr[int(c/lagstep-1)][l]
               tempmeanp1 = round(tempmeanp1 / float(len(sys.argv[1:])),2)
               tempmeanp2 = round(tempmeanp2 / float(len(sys.argv[1:])),2)
               print >> e, c, tempmeanp1, tempmeanp2
             
if graph == True:
    # Plotting the results by calling the gnuplot scripts:
    callp1 = "gnuplot -e \"file=\'"+tempname+"\';cor=\'"+str(corrp1)+"\'\" size-ai-diffp1.gp"
    system( callp1 )
    callp2 = "gnuplot -e \"file=\'"+tempname+"\';cor=\'"+str(corrp2)+"\'\" size-ai-diffp2.gp"
    system( callp2 )

#sys.exit("DEBUGGING ... ")
