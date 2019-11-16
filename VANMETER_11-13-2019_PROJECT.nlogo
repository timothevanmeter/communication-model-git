;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; COMMUNICATION MODEL ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; LAST UPDATED: 11-11-2019
;;;; Timothe Van Meter
;;;; tvanme2@uic.edu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
globals [
  total-turtles
  null
  similarity-ratio ;; A measure of the similarity between two individual's alphabets
  alphabets     ;; A list of all the possible alphabet types in the current simulation scenario
  outputname    ;; Output file's name
  ;; ai is not a global variable anymore
;  ai            ;; Aggregation Index
  k             ;; Tracks the number of neighbors with similar alphabets
]
turtles-own [
  alphabet      ;; the variable storing the alphabet of the individual
  communicated? ;; keeps track of agents that were already involved in a communication event
  interlocutor  ;; the agent with whom you are talking this time step
  reproduce?    ;; keeps track of agents that are to reproduce this time step
  alphabet-type ;; keeps track of the type of alphabet an agent is using
  d             ;; keeps track of agents already counted for the aggregation index
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set null 0
  show-details                                           ;; Shows all the possible alphabets for a given alphabet size
  set alphabets permutations (range alphabet-size)
  new-agents initial-population false null               ;; Creates the number of agents given by the user
  reset-ticks
end

to show-details
  if details [combinations]           ;; if the boolean, set by user is true call the combinations procedure (line ~252)
end


;; The new-agents procedure is called with three arguments:
;;  number      : the number of agents to create
;;  inherited?  : if the agent is created from initialisation of from a reproduction event
;;  inheritance : the alphabet the agent has inherited fromone of his parents
to new-agents [ number inherited? inheritance ]
  create-turtles number [
    setxy random-xcor random-ycor               ;; random position for the new agent
    set d 0                                     ;; Makes sure that d is initialised to 0
    ifelse inherited? [                         ;; if the agent is created by a reproductive event
      set alphabet inheritance                  ;; then use the parent's alphabet
    ][create-alphabet]                          ;; Calls the create-alphabet procedure (line ~64)
    set communicated? false			;; Makes sure the new agent does not communicate if it does not meet the conditions
    set reproduce? false			;; Makes sure the new agent does not reproduce if it does not meet the conditions

    foreach (range (factorial alphabet-size)) [ ;; For all possible alphabets we compare the alphabet of the new agent created
      [i] ->
      if alphabet = (item i alphabets) [	;; and assign the agent to a category depending on the identity of their alphabet
        set alphabet-type i
      ]
    ]
  ]
end

;; Alphabet generating procedure
;; The alphabet is simplified here so that an individual simply has a list of numbers, always from 0 to the alphabet-size value
;; set by the user. The alphabets are made different in the order of the numbers in that list.
;; [0 1] is different than [1 0] in our conception of an alphabet
to create-alphabet
  set alphabet (range alphabet-size)        ;; list all value between 0 and the value of the alphabet-size variable
  set alphabet shuffle alphabet            ;; randomized the order of the numbers in the list
  ;print alphabet
end


to go
  if not any? turtles or ticks = time-limit [
;    if save [save-output]
    stop
  ]
  move-agents
  ;;;;;;
  ;; This assess the status of the agents and assign them a commnuication queue
  ;; if they have the possibility to communicate this time step
  ;;;;;;
  ask turtles with [count turtles-here >= 2] [                    ;; only turtles with other turtles on the same patch can communicate
    ;; We set a designed locutor to be any of the turtles on the pacth that is not the caller
    let locutor (one-of turtles-here with [myself != self and not communicated?])
    if locutor != nobody [
      ask locutor [
        set communicated? true            ;; Add this turtle to the queue for communication
        set interlocutor myself           ;; Set this turtle as the interlocutor so it does not initiate any communication event on its own
      ]
      set communicated? true              ;; Add this turtle to the queue for communication
      set interlocutor locutor            ;; Set the latter turtle as the interlocutor so the caller directs the communication event towards
                                          ;; the proper turtle
    ]
  ]
  ;;;;;;
  communication           ;; Call the communication procedure (line ~116) to resolve all communication events
  reproduction            ;; Call the reproduction procedure (line ~143) for successful communciation events
  death                   ;; Call the death procedure (line ~175), apply background mortality rate
  monitor-turtles         ;; Call the monitor-turtles procedure (line ~183), track the type of alphabets being used by turtles
;  foreach (range (factorial alphabet-size)) [   ;;  For all possible alphabets we compare the alphabet of the new agent created
;    [i] ->
;    print (word "MEASURE FOR ALPHABET " item i alphabets " : ")
;    aggregation-index i      ;; Call the aggregation-index procedure (line ~292), measure aggregation of individuals on the grid
;  ]
  reset-boolean           ;; Call the reset-boolean procedure (line ~232), which resets the boolean that tracks the queue for
                          ;; individual's communication and reproduction
  if save [
    ifelse ticks = 0 [ save-output true ] [ save-output false ] ;;;; call save-output with or without the initialisation command
  ]
  tick
end

;; Move agents procedure
to move-agents
  ask turtles [
    rt random 361
    forward 1
  ]
end


to communication ;[interlocutor]
  ask turtles with [communicated?] [                            ;; Only proceeds for turtles that have been allowed to communicate
    ; print "INTERACTION"
    let sim 0
    set similarity-ratio 0
;    print (word " item chosen = " random alphabet-size)

    ;###########
    let listi (range message-length)                           ;; We evaluate as many positions in both speaker's alphabets as the value of
    foreach listi [                                            ;; the message-length variable
      ;    [i] -> type (word "#" i)
      ;    print (word ": " item i alphabet " VS " item i [alphabet] of interlocutor)
      [i] ->
      let j random alphabet-size                                        ;; We select randomly a position in the locutor's alphabet
      if (item j alphabet) = (item j [alphabet] of interlocutor) [      ;; and compare it to the same position in the interlocutor's alphabet
        set sim (sim + 1)                                               ;; For each position with identical number we increase the sim variable
      ]
    ]
    if sim != 0 [set similarity-ratio (sim / message-length)]           ;; The similarity ratio is the proportion of similar positions in both alphabets
    ;  print (word "Similarity Ratio = " similarity-ratio)              ;; as evaluated by our sample of size message-length
    if similarity-ratio * 100 >= random-float 101 [
      set reproduce? true                                               ;; If the similarity ratio is greater than a random percentage
    ]                                                                   ;; we allow the individuals to reproduce together
  ]
end


to reproduction
  ;print "REPRODUCTION"
  let new-alphabet 0
  let yes? false                                                       ;; What is the yes? boolean for ????? It does not seem to do much
  ask turtles with [reproduce?] [
    ifelse 50 > random-float 101 [                                     ;; There is a 1/2 chance for each parent to transmit their alphabet to the new
      set yes? true                                                    ;; turtle that is to be created
      set new-alphabet [alphabet] of interlocutor
    ] [ set new-alphabet alphabet ]
  ]
;  if yes? [
  new-agents agents-per-reproduction true mutation new-alphabet      ;; Call the new-agents procedure with inherited? = true and have the inherited
;  ]                                                                 ;; alphabet be mutated with the mutation procedure (line ~159)
end

;; This mutation procedure is called with an alphabet list as argument
;; and reports the transformed, or mutated alphabet list
to-report mutation [alphabet-test]
  if mutation-rate > random-float 101 [                              ;; If the mutation-rate is greater than a random value between 0 and 100
    ;print "MUTATION"                                                ;; we allow a mutation to change the alphabet
    let pos1 random alphabet-size                                    ;; We select two positions at random in the alphabet list
    let pos2 random alphabet-size
    ;  print (word "Before: " alphabet-test)
    ;  print (word "pos1=" pos1 "; pos2=" pos2)
    if pos1 != pos2 [
      let temp1 (item pos1 alphabet-test)
      let temp2 (item pos2 alphabet-test)
      set alphabet-test replace-item pos1 alphabet-test temp2        ;; We replace the number in the first position by the number in the second position
      set alphabet-test replace-item pos2 alphabet-test temp1        ;; We replace the number in the second position by the number in the first position
    ]
    ;  print (word "After mutation: " alphabet-test)
  ]
  report alphabet-test                                               ;; Returns the mutated alphabet
end

to death
  ask turtles [
    if lambda > (random-float 101)/ 100 [die]			     ;; If lambda is greater than a random value between 0 and 100
  ]								     ;; Then the individual dies
end


;;;; This procedure ensures that all boolean tracking the status of the agents are reseted after each ticks
to reset-boolean
  ask turtles [
    set communicated? false
    set reproduce? false
    set d 0
  ]
end
;##############################################################

to monitor-turtles
  set total-turtles count turtles

  ask turtles [
    foreach (range (factorial alphabet-size)) [                      ;;  For all possible alphabets we compare the alphabet of the new agent created
      [i] ->
      create-temporary-plot-pen (word "alphabet " item i alphabets)
      ;      set alphabet-type i				     ;; and assign the agent to a category depending on the identity of their alphabet
      if i = alphabet-type [
        set color scale-color red i 0 factorial alphabet-size	     ;; and then plot all similar type of agents
        set-plot-pen-color color
        plot count turtles with [alphabet-type = i]
      ]
    ]
  ]

end

to save-output [init?]
  ; set-current-directory "/home/timothe/communication-project/communication-model-git/"
  ; file-open (word "output-base-model-A2-message-mortality.txt")
  file-open output-path
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;; Write the header of the file
;  if behaviorspace-run-number = 1 [
;    file-type "# "
;;    file-type (word "message-length , lambda, agents-per-reproduction, mutation-rate, initial-population,")
;;    file-type (word "message-length,lambda,")
;    foreach (range (factorial alphabet-size)) [
;      [i] ->
;      file-type item i alphabets
;      file-type " "
;      file-type (word "AI("item i alphabets")" )
;    ]
;    file-print "" ;; Jumps a line
;  ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;; For testing purposes:
  if init? [
    file-type "# "
;    file-type (word "message-length , lambda, agents-per-reproduction, mutation-rate, initial-population,")
;    file-type (word "message-length,lambda,")
    foreach (range (factorial alphabet-size)) [
      [i] ->
      file-type item i alphabets
      file-type " "
      file-type (word "AI("item i alphabets")" )
      file-type " "
    ]
    file-print "" ;; Jumps a line
  ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;; Writing data counts to the file
;  file-type (word message-length "," lambda "," agents-per-reproduction "," mutation-rate "," initial-population ",")
;  file-type (word message-length "," lambda ",")
  foreach (range (factorial alphabet-size)) [
    [i] ->
    file-type (count turtles with [alphabet-type = i])
    file-type " "
    file-type (aggregation-index i)
    file-type " "
  ]
    file-print "" ;; Jumps a line
  file-close
end


;;;; https://stackoverflow.com/questions/33815666/generating-permutations-of-a-list-in-netlogo
;;;;
to-report permutations [#lst] ;Return all permutations of `lst`
  let n length #lst
  if (n = 0) [report #lst]
  if (n = 1) [report (list #lst)]
  if (n = 2) [report (list #lst reverse #lst)]
  let result []
  let idxs range n
  foreach idxs [? ->
    let xi item ? #lst
    foreach (permutations remove-item ? #lst) [?? ->
      set result lput (fput xi ??) result
    ]
  ]
  report result
end


to combinations
  let combinations-total (factorial alphabet-size)
  print (word "The total number of combinations for this alphabet size is: "combinations-total ", The details: ")
  print permutations (range alphabet-size)
end


;;;; This procedure reports the result of the factorial of any number, a feature which is absent in NetLogo
to-report factorial [num]
  let i range num
  let result 1
  foreach i [? ->
    set result (result * (num - ?))
  ]
  report result
end


;##############################################################
;;;; AGRREGATION MEASURE
;##############################################################
to-report aggregation-index [agent-type]
  let ai 0
  let total count turtles with [alphabet-type = agent-type]
  if total != 0 [
;    print "******************************"
;    print (word "total agents = " total)
    let g 0
    ask turtles with [alphabet-type = agent-type] [
      alphabet-neighbors agent-type             ;; Call the procedure for the current agent to count its neighbors with similar alphabet
      set g (g + k - d)		                      ;; Counting all borders shared with same alphabet neighbors
    ]
;    print (word "max g = " max_g total)
    if (max_g total) != 0 [ set ai ((g / max_g total) * 100) ]
;    print (word "g = " g)
;    print (word "AI = (g/max_g)*100 = " precision ai 1)
;    print "******************************"
    report (precision ai 1)
  ]
  report "NA"
end

to alphabet-neighbors [agent-type]
  set k 0             ;; Reset the variable
  ask patch-here [
    ask neighbors4 [
      set k k + count turtles-here with [alphabet-type  = agent-type]          ;; MAKE GENERAL: for all alphabet types!
      ask turtles-here with [alphabet-type = agent-type] [set d (d + 1)]       ;; MAKE GENERAL: for all alphabet types!
    ]
  ]
;  print (word "# Neighbors = " k)
end


;; This reporter sends as a result the size of the most compact shape, a square,
;; for the number of units or patches here considered
to-report max_g [tot]
  let n 0
  let maxg 0
;  print "******************************"
;  print "******************************"
  let i 0
  while [ (remainder sqrt(tot - i) 1) != 0 ] [		;; this iteration finds the size of the corresponding square
;    print (word "iteration " i " successful!!")
;    print (word "tot = " tot)
;    print (word "tot - iteration = " (tot - i))
;    print (word "sqrt (tot - iteration) = " sqrt (tot - i) )
;    print (word "sqrt (tot - iteration) modulo 1 = " (remainder sqrt (tot - i) 1) )
    set i (i + 1)
  ]
  set n (sqrt (tot - i))
;  print (word "n = " n)
  let m (tot - n ^ 2)
;  print (word "tot - n^2 = " m)
  (ifelse
    m = 0 [set maxg (2 * n * (n - 1)) ]
    m <= n [set maxg (2 * n * (n - 1) + 2 * m - 1) ]
    m > n [set maxg (2 * n * (n - 1) + 2 * m - 2) ]
  )
;  print (word "max = " maxg)
  report maxg
end
@#$#@#$#@
GRAPHICS-WINDOW
226
10
663
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
22
10
95
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
65
190
98
lambda
lambda
0
1
0.01
0.01
1
NIL
HORIZONTAL

BUTTON
108
11
171
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
16
107
193
140
initial-population
initial-population
0
1000
200.0
10
1
NIL
HORIZONTAL

SLIDER
20
152
192
185
alphabet-size
alphabet-size
0
10
2.0
1
1
NIL
HORIZONTAL

MONITOR
837
302
925
343
Total Agents
total-turtles
1
1
10

SLIDER
17
191
190
224
message-length
message-length
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
11
230
199
263
agents-per-reproduction
agents-per-reproduction
0
50
4.0
1
1
NIL
HORIZONTAL

PLOT
678
11
1116
290
plot
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS

SLIDER
17
271
189
304
mutation-rate
mutation-rate
0
100
0.0
1
1
NIL
HORIZONTAL

SWITCH
54
323
159
356
details
details
1
1
-1000

SWITCH
585
473
688
506
save
save
0
1
-1000

INPUTBOX
6
462
556
522
output-path
C:\\Users\\tvanme2.AD.000.001.002.003.004.005.006.007\\Desktop\\output-test.txt
1
0
String

INPUTBOX
51
370
155
430
time-limit
100.0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="base-model-A2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>save-output</final>
    <timeLimit steps="500"/>
    <exitCondition>not any? turtles</exitCondition>
    <enumeratedValueSet variable="message-length">
      <value value="1"/>
      <value value="10"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="0.01"/>
      <value value="0.05"/>
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="details">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alphabet-size">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agents-per-reproduction">
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="10"/>
      <value value="50"/>
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="base-model-A2-message-mortality" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>save-output</final>
    <timeLimit steps="500"/>
    <exitCondition>not any? turtles</exitCondition>
    <enumeratedValueSet variable="message-length">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lambda">
      <value value="0.01"/>
      <value value="0.02"/>
      <value value="0.03"/>
      <value value="0.04"/>
      <value value="0.05"/>
      <value value="0.08"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="details">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alphabet-size">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="agents-per-reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
