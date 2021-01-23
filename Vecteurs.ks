// Pour plus d'information, voir :
// https://ksp-kos.github.io/KOS/structures/misc/vecdraw.html

global vecteurFacing is V(0,0,0).
global vecteurSrfPrograde is V(0,0,0).
global vecteurUp is V(0,0,0).
global vecteurSrfVelocity is V(0,0,0).

set vecteurCible to vecDraw(
    V(0,0,0), 25*heading(90, 80):vector, blue,
    "Vecteur Cible",
    1, false, 0.5).

wait until ship:altitude > 100.

until ship:altitude > 70000 {
    set vecteurUp to vecDraw(
        V(0,0,0), 25*up:vector, blue,
        "UP",
        1, true, 0.5).

    set vecteurFacing to vecDraw(
        V(0,0,0), 25*facing:vector, red,
        "Facing",
        1, false, 0.5).
        
    set vecteurSrfPrograde to vecDraw(
        V(0,0,0), 25*SrfPrograde:vector, yellow,
        "Prograde",
        1, true, 0.5).

    set vecteurSrfVelocity to vecDraw(
        V(0,0,0), ship:velocity:surface, green,
        "Vitesse Surface",
        1, false, 1).
}
