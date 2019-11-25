set terminal pngcairo enhanced font "FreeSans, 12" size 800,500

outname = sprintf("%s%s", file, "-p2.png")
set output outname
filename = sprintf("%s%s", file, ".txt")

set datafile missing "nan"

set key inside top right title sprintf("%s%s", "⍴ = ", cor)
set xlabel 'Simulation time steps'
#set xrange [0:100]
set ylabel 'Δ(P2[t+𝜏] , P2[t])'
set y2label 'Δ(AI[t] , AI[t-𝜏])'
set y2tics
set ytics nomirror
set encoding utf8

plot filename u 1:3 t 'ΔP2' axis x1y1, filename u 1:5 t 'ΔAI' axis x1y2
