import numpy as np
import pandas as pd

title = "# P1 size difference,  P2 size difference, P1 ai difference, P2 ai difference"


# Initialisation of variables
#p1size, p1ai, p2size, p2ai = [0.0 for _ in range(4)]

# The following depends of the number of alphabet categories present:
p1size, p1ai, p2size, p2ai, p1sizedif, p1aidif, p2sizedif, p2aidif = [ [] for _ in range(8)]
temp1sd, temp2sd, temp1ad, temp2ad = [ 0.0 for _ in range(4)]

# Size of time lag:
n = 10
# Print to output:
out = False



# Read from file:
# Population Size,
# Aggregation Index
df = pd.read_csv('output-test_11-13-2019.txt', sep=" ")
p1size = df.iloc[:,0]
p1ai = df.iloc[:,1]
p2size = df.iloc[:,2]
p2ai = df.iloc[:,3]

maxl = len(p1size)

with open('size-ai-diff10.txt', 'w') as f:
    if out = True:
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
            temp1ad = round((p1ai[i] -p1ai[i-n]), 3)
            temp2ad = round((p2ai[i] -p2ai[i-n]), 3)
            p1aidif.append(p1ai[i] -p1ai[i-n])
            p2aidif.append(p2ai[i] -p2ai[i-n])
        
        if out = True:
            print >> f, i, temp1sd, temp2sd, temp1ad, temp2ad


# Calculating the correlation between the two measures:




