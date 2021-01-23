clearScreen.
local cible is LatLng(0.1022222, -74.5683333333).

// initialisation Vitesse
set wheelThrottlePID to 0.
set speedPID to PIDLoop(0.5, 0.1, 0.1, -1, 1).
set speedPID:setPoint to 20.

lock wheelThrottle to wheelThrottlePID.

// initialisation Direction
set wheelDirection to 0.
set turnPID TO PIDLOOP(0.01,0.001,0.01,-0.3,0.3).
set turnPID:setPoint to 0.

until ship:velocity:surface:mag > 7 {
    // MaJ vitesse :
    set myVelocity to ship:velocity:surface:mag.
    set wheelThrottlePID to speedPID:UPDATE(time:seconds, myVelocity).
    // MaJ direction :
    set myHeading to cible:bearing.
    set wheelDirection to turnPID:UPDATE(TIME:SECONDS,myHeading).
    set ship:control:wheelsteer to wheelDirection.
    print round(cible:distance, 0) + ("   ") at (0,1).
    wait 0.1.
}

set turnPID TO PIDLOOP(0.01,0.001,0.01,-0.005,0.005).

until cible:distance < 250 {
    // MaJ vitesse :
    set myVelocity to ship:velocity:surface:mag.
    set wheelThrottlePID to speedPID:UPDATE(time:seconds, myVelocity).
    // MaJ direction :
    set myHeading to cible:bearing.
    set wheelDirection to turnPID:UPDATE(TIME:SECONDS,myHeading).
    set ship:control:wheelsteer to wheelDirection.
    print round(cible:distance, 0) + ("   ") at (0,1).
    wait 0.1.
}

set speedPID:setPoint to 10.

until cible:distance < 50 {
    // MaJ vitesse :
    set myVelocity to ship:velocity:surface:mag.
    set wheelThrottlePID to speedPID:UPDATE(time:seconds, myVelocity).
    // MaJ direction :
    set myHeading to cible:bearing.
    set wheelDirection to turnPID:UPDATE(TIME:SECONDS,myHeading).
    set ship:control:wheelsteer to wheelDirection.
    print round(cible:distance, 0) + ("   ") at (0,1).
    wait 0.1.
}

set speedPID:setPoint to 3.

until cible:distance < 20 {
    // MaJ vitesse :
    set myVelocity to ship:velocity:surface:mag.
    set wheelThrottlePID to speedPID:UPDATE(time:seconds, myVelocity).
    // MaJ direction :
    set myHeading to cible:bearing.
    set wheelDirection to turnPID:UPDATE(TIME:SECONDS,myHeading).
    set ship:control:wheelsteer to wheelDirection.
    print round(cible:distance, 0) + ("   ") at (0,1).
    wait 0.1.
}

until ship:velocity:surface:mag < 0.01 {
    print round(cible:distance, 0) + ("   ") at (0,1).
    lock wheelThrottle to 0.
    brakes on.
}

unlock wheelThrottle.
shutdown.