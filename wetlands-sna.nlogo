globals 
[
  city-patches
  village-1-patches
  village-2-patches
  village-3-patches                      ;; agentset of grey patches - represents home locations
  wetland-patches                   ;; agentset of green patches - represents wetland
  beach-patches                     ;; agentset of yellow patches - represents beach
  boundary-patches                  ;; agentset of black patches - represents boundary between wetlands and city
  average-experience                ;; global variable to capture average experience of tourists for plots 
  average-experience-1
  average-experience-2
  average-experience-3
  average-ecology                   ;; global variable to capture average ecology of wetlands for plots
  average-infrastructure            ;; global variable to capture average infrastructure of wetlands for plots
  average-resources                 ;; global variable to capture average resources of ecologists
]


breed [tourists tourist]
tourists-own 
[
  village
  village-xcor
  village-ycor
  pref-distance
  gossip-weight
  visiting-wetland?
  experience                       ;;  tourist's past experience of wetland
  pref-ecology                     ;;  how highly does the tourist value ecology in experience
  pref-infra                       ;;  how highly does the tourist value infrastructure in experience and pref-infra + pref-ecology = 1
  time-since-wetland-visit         ;;  number of time steps since the tourist last visited a wetland - tourists adopt experience of tourists with more recent visits
]


breed [ecologists ecologist]
ecologists-own 
[
  resources                        ;; resource level of ecologists to repair wetlands
     
]

breed [builders builder]
builders-own 
[
  resources                        ;; resource level of builders to repair wetlands 
]

breed [marketers marketer]
marketers-own
[
]


patches-own
[
  village-here
  infrastructure                   ;; infrastructure level for wetland patch
  ecology                          ;; ecology level for wetland patch
]


to setup
  clear-all
  setup-patches
  setup-people
  setup-networks
  reset-ticks
end
  
to setup-patches
  
  ask patches 
  [ 
    set infrastructure random max-resources-patch  ;;  initialise patch resource levels
    set ecology random max-resources-patch
  ]
    
  ;; create the 'villages'
  set village-3-patches patches with [pycor > 0 and pycor <= 11]
  ask village-3-patches 
  [ 
    set pcolor 38
    set village-here 3
  ]

  set village-2-patches patches with [pycor >= 13 and pycor <= 24]
  ask village-2-patches 
  [ 
    set pcolor 38 
    set village-here 2
  ]

  set village-1-patches patches with [pycor >= 26 and pycor <= 37]
  ask village-1-patches 
  [ 
    set pcolor 38
    set village-here 1
  ]

  ;; create the 'wetland'
  set wetland-patches patches with [pycor >= 39 and pycor <= 50]
  ask wetland-patches [ set pcolor 69 -  int ((ecology / max-resources-patch) * 5) ]     ;; patches with low levels of ecology will be lighter green in color

  ;; create the 'boundaries'
  set boundary-patches patches with [pycor = 12 or pycor = 25 or pycor = 38]
  ask boundary-patches [ set pcolor black ]
  
  ;; create the 'beach'
  set beach-patches patches with [pycor = 0]
  ask beach-patches [ set pcolor yellow ]
  

end    

to setup-people
  set-default-shape tourists "person"
  create-tourists (initial-number-tourists / 3)
  [
    set village 1
    set visiting-wetland? false           ;;  flag for the tourist being inside the wetland
    set experience 80 + (0.2 * random 100)            ;;  initialise the tourist's history of wetland visits
    ifelse (experience > 50) 
    [
      ifelse (experience > 60) [set shape "face happy"][set shape "face neutral"]
    ]
    [set shape "face sad"]
    set color 4 + (experience / 17)
    set pref-infra (random 101) / 100     ;;  random weight for ecology in experience calculation
    set pref-ecology 1 - pref-infra       ;;  random weight for infra in experience calculation
    set time-since-wetland-visit 0        ;;  initialize wetland visit history
    set gossip-weight initial-gossip-weight
    move-to one-of village-1-patches with [pxcor < 30 and pxcor > 20]
    set village-xcor xcor
    set village-ycor ycor
  ]

  create-tourists (initial-number-tourists / 3)
  [
    set village 2
    set visiting-wetland? false           ;;  flag for the tourist being inside the wetland
    set experience 50 + (0.3 * random 100)            ;;  initialise the tourist's history of wetland visits - Village 1 has high exp
    ifelse (experience > 50) 
    [
      ifelse (experience > 60) [set shape "face happy"][set shape "face neutral"]
    ]
    [set shape "face sad"]
    set color 4 + (experience / 17)
    set pref-infra (random 101) / 100     ;;  random weight for ecology in experience calculation
    set pref-ecology 1 - pref-infra       ;;  random weight for infra in experience calculation
    set time-since-wetland-visit 0        ;;  initialize wetland visit history
    set gossip-weight initial-gossip-weight
    move-to one-of village-2-patches with [pxcor < 30 and pxcor > 20]
    set village-xcor xcor
    set village-ycor ycor
  ]

  create-tourists (initial-number-tourists / 3)
  [
    set village 3
    set visiting-wetland? false           ;;  flag for the tourist being inside the wetland
    set experience 10 + 0.3 * random 100            ;;  initialise the tourist's history of wetland visits
    ifelse (experience > 50) 
    [
      ifelse (experience > 60) [set shape "face happy"][set shape "face neutral"]
    ]
    [set shape "face sad"]
    set color 4 + (experience / 17)
    set pref-infra (random 101) / 100     ;;  random weight for ecology in experience calculation
    set pref-ecology 1 - pref-infra       ;;  random weight for infra in experience calculation
    set time-since-wetland-visit 0        ;;  initialize wetland visit history
    set gossip-weight initial-gossip-weight
    move-to one-of village-3-patches with [pxcor < 30 and pxcor > 20]
    set village-xcor xcor
    set village-ycor ycor
  ]

  
  set-default-shape ecologists "person"
  create-ecologists initial-number-ecologists
  [
    set color green - 3
    set resources random max-resources-rangers
    move-to one-of wetland-patches
  ]  
  
  set-default-shape builders "person"
    create-builders initial-number-builders
  [
    set color blue
    set resources random max-resources-rangers
    move-to one-of wetland-patches
  ]
  
    set-default-shape marketers "person"
    create-marketers initial-number-marketers
  [
    set color yellow
    move-to one-of wetland-patches
  ]  
  
end

;;to setup-networks
;;  ask tourists
;;  [
;;   if ((random-float 1) < number-of-links-per-tourist) 
;;    [
;;      ifelse (random-float 1 > prob-long-link) [create-link-with min-one-of other tourists with [village = [village] of myself] (([pref-ecology] - [pref-ecology] of myself) ^ 2) ] [create-link-with one-of tourists with [village != [village] of myself]]
;;    ]
;;  ]
;;end

to setup-networks
  ask tourists
  [
   if ((random-float 1) < number-of-links-per-tourist) 
    [
      ifelse (random-float 1 > prob-long-link) 
      [
        let candidates sort other tourists with [village = [village] of myself]
        foreach sort link-neighbors
        [
          set candidates remove ? candidates
        ]
        set candidates tourists with [member? self candidates]
        ask candidates
        [
          set pref-distance (pref-ecology - [pref-ecology] of myself ) ^ 2 + (pref-infra - [pref-infra] of myself ) ^ 2
        ]
        create-link-with min-one-of candidates [pref-distance]
      ] 
      [
        let candidates other tourists with [village != [village] of myself]
        ask candidates
        [
          set pref-distance (pref-ecology - [pref-ecology] of myself ) ^ 2 + (pref-infra - [pref-infra] of myself ) ^ 2
        ]
        create-link-with min-one-of candidates [pref-distance]
      ]
    ]
  ]  
  
end  



to layout
  wait 0.05
  layout-spring tourists links 0.2 5 1
  ask tourists with [[pcolor] of patch-here != 38]
  [
    move-to one-of neighbors with [village-here = [village] of myself]
  ]

end

to move-tourists
    ask tourists
    [
      ifelse (visiting-wetland? = true)
      [
        set xcor xcor + (random 3) - 1                            ;;  move tourist randomly in x
        set ycor ycor + (random 3) - 1                         ;;  move tourist randomly in y
      ]
      [
        if ((random 100) <= probability-of-recreation)          ;;  probability-of-recreation is the chance of making a recreation choice (either beach or wetland) each time-step                            
          [
          ifelse ((random experience) > 50)                   ;;  if experience is high then tourist is more likely to make the wetland choice when recreating
            [
            set visiting-wetland? true
            move-to one-of wetland-patches
            set gossip-weight 0.5
            ]
            [
            visit-beach
            ]
          ]
       ]      
      
      if (ycor = 38 and visiting-wetland? = true)            ;;  tourist exits the wetland
      [
        set visiting-wetland? false
        set time-since-wetland-visit 0                          ;;  sets counter for wetland visit history to 0
        set xcor village-xcor
        set ycor village-ycor
      ]
      if (ycor = 51)                                         ;;  tourist exits the wetland 
      [
        set visiting-wetland? false
        set time-since-wetland-visit 0                          ;;  sets counter for wetland visit history to 0
        set xcor village-xcor
        set ycor village-ycor
      ]
      
      set time-since-wetland-visit time-since-wetland-visit + 1
       
      ifelse (visiting-wetland? = true)                                                                                                                                            ;;  code for wetland visit
      [                                                                                                                                                                        ;;  wetland experience is a weighted average of all past
        set experience ((1 - experience-decay) * experience) + (experience-decay * (100 / max-resources-patch) * ((pref-ecology * ecology) + (pref-infra * infrastructure)))   ;;  wetland experiences - low weights of decay means that
        if (ecology > 0)                                                                                                                                                       ;;  past experiences matter more - the experience for each
        [                                                                                                                                                                      ;;  time step is a weighted average of the resources levels
          set ecology ecology - 1                                                                                                                                              ;;  of the patch visited where weights are the pref- values 
          set pcolor 69 -  int ((ecology / max-resources-patch) * 5) 
        ]
        if (infrastructure > 0)
        [
          set infrastructure infrastructure - 1
        ]
        
      ]
      [
        if (random 100 < probability-of-sharing-gossip) and (visiting-wetland? = false)
        [
          ask link-neighbors
          [
            set experience (1 - [gossip-weight] of myself) * experience + (([gossip-weight] of myself) * ([experience] of myself))    ;; agents shares gossip with linked agents
          ]   
        ]
    
      ]
    set color 4 + (experience / 17)
    ifelse (experience > 50) 
    [
      ifelse (experience > 60) [set shape "face happy"][set shape "face neutral"]
    ]
      [set shape "face sad"]
    ]


end

to move-ecologists
  ask ecologists
  [
    set xcor xcor + (random 3) - 1
    let newycor ycor + (random 3) - 1
    if newycor = 38 [set newycor 50]
    if newycor = 51 [set newycor 39]
    setxy xcor newycor
    
    set resources resources + ((count tourists-here) * tourist-payment * (ceiling (average-experience / 10) / 10))                      ;;  tourists add tourist-payment resources to rangers they meet 
    
     
    if (ecology < max-resources-patch and resources > 0)
    [
      set resources resources - 1
      set ecology ecology + 1
      set pcolor 69 -  int ((ecology / max-resources-patch) * 5) 
     ]
   ]  
end

to move-builders
  ask builders
  [
    set xcor xcor + (random 3) - 1
    let newycor ycor + (random 3) - 1
    if newycor = 38 [set newycor 50]
    if newycor = 51 [set newycor 39]
    setxy xcor newycor 
    
    
    set resources resources + ((count tourists-here) * tourist-payment * (ceiling (average-experience / 10) / 10))                   ;;  tourists add tourist-payment resources to rangers they meet 

    if (infrastructure < max-resources-patch and resources > 0)
    [
      set resources resources - 1
      set infrastructure infrastructure + 1
     ]
  ]
      
end

to move-marketers
  ask marketers
  [
    set xcor xcor + (random 3) - 1
    let newycor ycor + (random 3) - 1
    if newycor = 38 [set newycor 50]
    if newycor = 51 [set newycor 39]
    setxy xcor newycor 
    
    ask tourists-here
    [
      if gossip-weight < 0.95
      [
        set gossip-weight gossip-weight + 0.5
      ]
    ]
  ]
      
end

to mouse-move
  ;When enable by actived the button allows individual agents to be moved.
  if mouse-down? [
    let candidate min-one-of tourists [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 1 [
      while [mouse-down?] [
        ask candidate [ setxy mouse-xcor mouse-ycor ]
      ]
    ]
  ]  
end

to return-tourists-to-villages
  ask tourists
  [
  set visiting-wetland? false
  set time-since-wetland-visit 0                          ;;  sets counter for wetland visit history to 0
  set xcor village-xcor
  set ycor village-ycor
  ]
end

to visit-beach

end

to wetland-decay

end

;;main routine
to go
  move-tourists
  move-ecologists
  move-builders
  move-marketers
  set average-experience mean [experience] of tourists
  set average-ecology mean [ecology] of wetland-patches
  set average-infrastructure mean [infrastructure] of wetland-patches
  set average-resources mean [resources] of ecologists
  set average-experience-1 mean [experience] of tourists with [village = 1]
  set average-experience-2 mean [experience] of tourists with [village = 2]
  set average-experience-3 mean [experience] of tourists with [village = 3]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
896
717
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
0
1
0
51
0
51
0
0
1
ticks
30.0

BUTTON
7
10
70
43
setup
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
19
62
191
95
initial-number-tourists
initial-number-tourists
0
100
30
1
1
NIL
HORIZONTAL

SLIDER
17
194
189
227
initial-number-builders
initial-number-builders
0
60
20
1
1
NIL
HORIZONTAL

SLIDER
16
148
198
181
initial-number-ecologists
initial-number-ecologists
0
60
20
1
1
NIL
HORIZONTAL

SLIDER
18
234
197
267
max-resources-rangers
max-resources-rangers
0
200
150
1
1
NIL
HORIZONTAL

BUTTON
144
10
207
43
go
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
18
276
190
309
max-resources-patch
max-resources-patch
0
10
10
1
1
NIL
HORIZONTAL

SLIDER
20
325
192
358
experience-decay
experience-decay
0
1
0.1
.1
1
NIL
HORIZONTAL

SLIDER
16
370
205
403
probability-of-recreation
probability-of-recreation
0
100
5
1
1
NIL
HORIZONTAL

MONITOR
14
543
139
588
Average Experience
average-experience
17
1
11

PLOT
895
31
1095
181
Average Experience of Tourists
Time
Average experience of Tourists
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-experience"

SLIDER
15
413
187
446
tourist-payment
tourist-payment
0
100
50
10
1
NIL
HORIZONTAL

MONITOR
15
492
192
537
Average Ecology of Wetlands
average-ecology
17
1
11

PLOT
895
193
1095
343
Average Ecology of Wetland Patches
Time
Ecology
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-ecology"

PLOT
893
507
1093
657
Number of tourists in wetlands
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count tourists with [visiting-wetland? = true]"

SLIDER
15
453
187
486
initial-gossip-weight
initial-gossip-weight
0
1
0.5
0.05
1
NIL
HORIZONTAL

PLOT
892
349
1092
499
Average Infrastructure of Wetlands
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-infrastructure"

SLIDER
19
103
196
136
initial-number-marketers
initial-number-marketers
0
50
0
1
1
NIL
HORIZONTAL

BUTTON
76
10
139
43
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
15
592
209
637
Average Resources of Ecologists
average-resources
17
1
11

MONITOR
17
643
160
688
Average Gossip-Weight
mean [gossip-weight] of tourists
17
1
11

SLIDER
5
694
201
727
number-of-links-per-tourist
number-of-links-per-tourist
0
1
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
4
730
176
763
prob-long-link
prob-long-link
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

BUTTON
4
767
74
800
Layout
layout
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
804
181
837
Use mouse to move agents
mouse-move
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
242
735
450
768
probability-of-sharing-gossip
probability-of-sharing-gossip
0
100
20
1
1
NIL
HORIZONTAL

PLOT
1109
32
1309
182
Village 1 Average Experience
Time
Average Experience
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-experience-1"

PLOT
1109
192
1309
342
Village 2 Average Experience
Time
Average Experience
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-experience-2"

PLOT
1109
352
1309
502
Village 3 Average Experience
Time
Average Experience
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-experience-3"

BUTTON
75
768
248
801
NIL
return-tourists-to-villages
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
