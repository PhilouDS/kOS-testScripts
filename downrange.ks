clearScreen.

set KSClng to ship:geoposition:LNG.

lock longueurUnDegre to (body:radius + ship:altitude) * 2 * constant:pi / 360.

lock shipLng to ship:geoposition:LNG.

lock difference to abs(shipLng - KSClng).

lock distance to difference * longueurUnDegre.

print round(KSClng,2) at (0,2).

wait until ship:altitude > 1000.

until ship:velocity:orbit:mag > 3000 {
  print round(shiplng,2) + ("    ") at (0,3).
  if distance > 1000 {
    print round(distance/1000,2) + ("   ") at (0,5).
    print ("(km)") at (0,6).}
  else  {
    print round(distance,2) + ("   ") at (0,5).
    print ("(m)") at (0,6).}
  wait 0.05.
  if difference <= 180 {lock distance to difference * longueurUnDegre.}
  if difference > 180 {lock distance to (360 - difference) * longueurUnDegre.}
}
