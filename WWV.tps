//  Created by Denis Dubov on 15/09/2019.
//  Copyright © 2019 FreeWay. All rights reserved.

//@version=3
study("Weis Wave Volume", shorttitle="WWV", overlay=false)
method = input(defval="ATR", options=["ATR", "Traditional", "Part of Price"], title="Renko Assignment Method")
methodvalue = input(defval=14.0, type=float, minval=0, title="Value")
pricesource = input(defval="Close", options=["Close", "Open / Close", "High / Low"], title="Price Source")
useClose = pricesource == "Close"
useOpenClose = pricesource == "Open / Close" or useClose
useTrueRange = input(defval="Auto", options=["Always", "Auto", "Never"], title="Use True Range instead of Volume")
isOscillating=input(defval=false, type=bool, title="Oscillating")
normalize=input(defval=false, type=bool, title="Normalize")
vol = useTrueRange == "Always" or (useTrueRange == "Auto" and na(volume))? tr : volume
op = useClose ? close : open
hi = useOpenClose ? close >= op ? close : op : high
lo = useOpenClose ? close <= op ? close : op : low

if method == "ATR"
    methodvalue := atr(round(methodvalue))
if method == "Part of Price"
    methodvalue := close/methodvalue

currclose = na
prevclose = nz(currclose[1])
prevhigh = prevclose + methodvalue
prevlow = prevclose - methodvalue
currclose := hi > prevhigh ? hi : lo < prevlow ? lo : prevclose

direction = na
direction := currclose > prevclose ? 1 : currclose < prevclose ? -1 : nz(direction[1])
directionHasChanged = change(direction) != 0
directionIsUp = direction > 0
directionIsDown = direction < 0

barcount = 1
barcount := not directionHasChanged and normalize ? barcount[1] + barcount : barcount
vol := not directionHasChanged ? vol[1] + vol : vol
res = barcount > 1 ? vol/barcount : vol

plot(isOscillating and directionIsDown ? -res : res, style = columns, color = directionIsUp ? green : red, transp = 75, linewidth=3, title = "Wave Volume")
