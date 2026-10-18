-- Shared clock for playback, contact, and parry. Effect durations stay real seconds.
local M = {}
function M.Build(duration, speed, frontMultiplier, frontFraction)
 assert(duration>0 and speed>0 and frontMultiplier>0,"Invalid animation timing")
 assert(frontFraction>=0 and frontFraction<=1,"Invalid front fraction")
 local split=duration*frontFraction
 local frontSpeed=speed*frontMultiplier
 local frontDuration=split/frontSpeed
 local timeline={FrontSpeed=frontSpeed,BackSpeed=speed,Split=split,FrontDuration=frontDuration}
 function timeline.ToElapsed(sourceTime)
  sourceTime=math.clamp(sourceTime,0,duration)
  return math.min(sourceTime,split)/frontSpeed+math.max(0,sourceTime-split)/speed
 end
 function timeline.ToSource(elapsed)
  elapsed=math.max(0,elapsed)
  return math.min(duration,math.min(elapsed,frontDuration)*frontSpeed+math.max(0,elapsed-frontDuration)*speed)
 end
 function timeline.SpeedAt(elapsed)
  return elapsed<frontDuration and frontSpeed or speed
 end
 timeline.Duration=timeline.ToElapsed(duration)
 return table.freeze(timeline)
end
return M
