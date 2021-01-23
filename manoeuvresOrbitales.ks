// fichier manoeuvresOrbitales.ks

global function vitesseActuelle {
  parameter peri, apo, altitudeVaisseau.
  local RV is body:radius + altitudeVaisseau.
  local RA is body:radius + apo.
  local RP is body:radius + peri.
  local DGA is (RA + RP)/2. // Demi Grand Axe
  local vitesse is sqrt(body:mu * (2/RV - 1/DGA)).
  return vitesse.
}

global function transfertHohmann {
  parameter altitudeVaisseau, altitudeCible.
  local vitesseInitiale is 0.
  local vitesseFinale is 0.
  local deltaVhohmann is 0.

  set vitesseInitiale to vitesseActuelle(orbit:periapsis, orbit:apoapsis, altitudeVaisseau).
  if altitudeVaisseau < altitudeCible {
    set vitesseFinale to vitesseActuelle(altitudeVaisseau, altitudeCible, altitudeVaisseau).
  } 
  else {
    set vitesseFinale to vitesseActuelle(altitudeCible, altitudeVaisseau, altitudeVaisseau).
  }

  set deltaVhohmann to vitesseFinale - vitesseInitiale.

  print ("Vi = ") + round(vitesseInitiale,2) + (" m/s.").
  print ("Vf = ") + round(vitesseFinale,2) + (" m/s.").
  print ("Delta V = ") + round(deltaVhohmann,2) + (" m/s.").

  return deltaVhohmann.
}

global function circularisation {
  parameter ApOuPe.
  local deltaVcirc is 0.
  local noeudMnv is node(0,0,0,0).

  if (ApOuPe = "AP") {
    set deltaVcirc to transfertHohmann (orbit:apoapsis, orbit:apoapsis).
    set noeudMnv to node(time:seconds + ETA:apoapsis, 0, 0, deltaVcirc).
  }
  else {
    set deltaVcirc to transfertHohmann (orbit:periapsis, orbit:periapsis).
    set noeudMnv to node(time:seconds + ETA:periapsis, 0, 0, deltaVcirc).
  }

  print("Calcul de la manoeuvre effectué.").

  add noeudMnv.
}

global function executerManoeuvre {
  parameter deltaBurn.
  if hasNode {
    set noeud to nextNode.
    lock steering to noeud:burnVector.
    set max_acc to ship:maxthrust/ship:mass.
    set burn_duration to noeud:deltav:mag/max_acc.
    set burn_duration to burn_duration + deltaBurn*burn_duration.

    warpTo(time:seconds + noeud:eta - (burn_duration/2 + 20)).

    wait until noeud:eta <= (burn_duration/2).

    set tset to 0.
    lock throttle to tset.

    set done to False.
    set dv0 to noeud:deltav.

    until done
    {
      set max_acc to ship:maxthrust/ship:mass.
      set tset to min(noeud:deltav:mag/max_acc, 1).

      if vdot(dv0, noeud:deltav) < 0 {lock throttle to 0. break.}

      if noeud:deltav:mag < 0.1 {
        wait until vdot(dv0, noeud:deltav) < 0.5.
        lock throttle to 0.
        set done to True.
      }
    }
    unlock steering.
    unlock throttle.
    wait 1.
    remove noeud.
  }
  else {
    print("Pas de noeud de manoeuvre existant.").
  }
  lock steering to prograde.
}