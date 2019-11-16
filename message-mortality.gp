

set terminal pngcairo enhanced font 'Freesans,12'
#unset key
set ylabel "Number of Individuals"

set xlabel 'Background Death Rate'
set output 'mortality-2.png'
plot 'message-mortality.txt' u 2:3 pt 7 t "[0 1]", '' u 2:3 smooth unique lw 2 t "", '' u 2:4 pt 7 t "[1 0]", '' u 2:4 smooth unique lw 2 t ""



