main().

function main {
  clearscreen.

  when maxThrust = 0 then {
    stage.
    preserve.
  }

  lock steering to heading(90,90).
  lock throttle to 1.
  stage.

  wait until ship:altitude > 300.
  print("--- Gravity Turn ---").
  gravityTurn(86).  
}


global function gravityTurn{
  parameter pitchAngle.
  local directionTilt is heading(90, pitchAngle).
  lock steering to directionTilt.
  wait until vAng(facing:vector, directionTilt:vector) < 1.
  wait until vAng(srfPrograde:vector, facing:vector) < 1.
  lock steering to heading(90, 90 - vAng(up:vector, srfPrograde:vector)).

  set throttlePID to PIDLoop(0.1, 0.05, 0.1, 0.01, 1).
  set throttlePID:SETPOINT to 60.
  set wanted_throttle to 1.
  lock throttle to wanted_throttle.

  until ship:altitude >= 36000 {
    print ("--- Correction of throttle ---") at (0,5).
    set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
    print "Actual apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
    print "   ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
    print "   PID Throttle: " + round(throttle,2) + "   " at (0,6).
    wait 0.
  }
  
  lock steering to heading(90, 90 - vAng(up:vector, Prograde:vector)).
  set throttlePID:SETPOINT to 45.

  until ship:apoapsis > 75000 and ship:periapsis > -100000 {
    set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
    print "Actual apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
    print "   ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
    print "   PID Throttle: " + round(throttle,2) + "   " at (0,6).
    wait 0.
  }

  set throttlePID:SETPOINT to 20.

  until ship:periapsis > -30000 or ETA:apoapsis < 10 {
    set wanted_throttle to throttlePID:UPDATE(time:seconds, ETA:apoapsis).
    print "Actual apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
    print "   ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
    print "   PID Throttle: " + round(throttle,2) + "   " at (0,6).
    wait 0.
  }

  set pitchPID to PIDLoop(1, 0.2, 0.5, -5, 5).
  set pitchPID:SETPOINT to 10.
  lock throttle to 0.2.

  until ship:orbit:eccentricity <= 0.0001 {
    print ("--- Correction of pitch ------") at (0,8).
    set wanted_pitch to pitchPID:UPDATE(time:seconds, ETA:apoapsis).
    print "Actual apoapsis: " + round(ship:apoapsis,2) + " m   " at (0,2).
    lock steering to heading(90, wanted_pitch).
    print "   ETA:Apoapsis: " + round(ETA:apoapsis,2) + " s   " at (0,3).
    print "      PID Pitch: " + round(vAng(ship:facing:vector, Prograde:vector),2) + "°    " at (0,9).
    if ETA:apoapsis < 0.1 {break.}
    wait 0.
  }

  sas on.
  unlock throttle.
  set ship:control:pilotMainThrottle to 0.
}

