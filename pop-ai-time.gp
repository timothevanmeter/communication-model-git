# Scale font and line width (dpi) by changing the size! It will always display stretched.
set terminal pngcairo size 800,500 enhanced font "FreeSans,12"
set output 'pop-ai-50_01.png'


##################################
# number of points in moving average
n = 50

array A[n]

samples(x) = $0 > (n-1) ? n : int($0+1)
mod(x) = int(x) % n
avg_n(x) = (A[mod($0)+1]=x, (sum [i=1:samples($0)] A[i]) / samples($0))
##################################

# Key means label...
set key inside top right
set xlabel 'Simulation time steps'
#set xrange [0:100]
set ylabel 'Population Size'
set y2label 'Aggregation Index (AI)'
set y2tics
set ytics nomirror


plot "output-test_11-13-2019.txt" u 0:1 t '[0 1]' w l lw 1.5 axis x1y1, '' u 0:(avg_n($2)) w l lw 1.5 t 'AI([0 1])' axis x1y2

#plot "output-test_11-13-2019.txt" u 0:3 title '[1 0]' w l lw 1.5 axis x1y1, '' u 0:(avg_n($4)) w l lw 1.5 title 'AI([1 0])' axis x1y2


