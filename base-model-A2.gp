

set terminal pngcairo enhanced font 'Freesans,12'
unset key
set ylabel "Number of Individuals"

set xlabel 'Message Length (language units)'
set output 'message.png'
plot 'output-base-model-A2-new.txt' u 1:6 pt 7 t "[0 1]", '' u 1:6 smooth unique lw 2, '' u 1:7 pt 7 t "[1 0]", '' u 1:7 smooth unique lw 2

set t pop
set terminal pngcairo enhanced font 'Freesans,12'

set xlabel "Background Mortality Rate"
set output "mortality.png"
plot 'output-base-model-A2-new.txt' u 2:6 pt 7 t "[0 1]", '' u 2:6 smooth unique lw 2, '' u 2:7 pt 7 t "[1 0]", '' u 2:7 smooth unique lw 2

set t pop
set terminal pngcairo enhanced font 'Freesans,12'

set xlabel 'Mutation Rate'
set output 'mutation.png'
plot 'output-base-model-A2-new.txt' u 4:6 pt 7 t "[0 1]", '' u 4:6 smooth unique lw 2, '' u 4:7 pt 7 t "[1 0]", '' u 4:7 smooth unique lw 2



