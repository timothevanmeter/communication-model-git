import random
import numpy as np
import pandas as pd

total2 = 0.0
rand2 = 0.0
error2 = 0.0
total4 = 0.0
rand4 = 0.0
error4 = 0.0
total16 = 0.0
rand16 = 0.0
error16 = 0.0
total100 = 0.0
rand100 = 0.0
error100 = 0.0

title = "# Estimation of Similarity (message length=2), Cumulative Error (message length=2), Estimation of Similarity (message length=4), Cumulative Error (message length=4), Estimation of Similarity (message length=16), Cumulative Error (message length=16), Estimation of Similarity (message length=100), Cumulative Error (message length=100)"

with open('trials2-100.txt', 'w') as f:
	print >> f, title

	for i in range(1,100):
		# Message length of 2 		
		rand2 = float(np.random.binomial(n=2, p=0.5))
		val2 = rand2/2
		total2 += rand2/2
		error2 += (round(total2/i, 3) - 0.5)**2
		#print "ML=2 : ",rand/2
		#====================		
		# Message length of 4		
		rand4 = float(np.random.binomial(n=4, p=0.5))
		val4 = rand4/4		
		total4 += val4
		error4 += (round(total4/i, 3) - 0.5)**2
		#print "ML=4 : ",rand/4
		#====================		
		# Message length of 16		
		rand16 = float(np.random.binomial(n=16, p=0.5))
		val16 = rand16/16		
		total16 += val16
		error16 += (round(total16/i, 3) - 0.5)**2
		#print "ML=16 : ",rand/16
		#====================		
		# Message length of 100
		rand100 = float(np.random.binomial(n=100, p=0.5))
		val100 = rand100/100
		total100 += val100
		error100 += (round(total100/i, 3) - 0.5)**2
		#print "ML=100 : ",rand/100
		#====================		
		print >> f, i, round(total2/i, 3), error2, round(total4/i, 3), error4, round(total16/i, 3), error16, round(total100/i, 3), error100






