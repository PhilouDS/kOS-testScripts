// Liste des parts de tout le craft
function listeComposants {
  list PARTS in myPartsList.
  return myPartsList.
}

// liste des moteurs de tout le craft
function listeMoteurs {
  list ENGINES in myEnginesList.
  return myEnginesList.
}

// liste de tous les réservoirs avec Oxidizer du craft
function listeReservoirs {
  local tkList to list().
  local shipPartList to listeComposants().
  for part in shipPartList {
    for resource in part:resources {
      if (resource:name = "Oxidizer") {
        tkList:add(part).  
      }
    }
  }
  return tkList.
}

// liste des parts d'un seul étage
// numéro de l'étage donné en argument
// Attention aux moteurs pour lesquels les étages ne sont pas comptés pareil.
function listeComposantsEtage {
  parameter theStage.
  local stgPart is list().
  local shipPartsList is listeComposants().
  local shipEnginesList is listeMoteurs().

  for shipPart in shipPartsList {
    if shipEnginesList:contains(shipPart) {
      if shipPart:stage = theStage {
        stgPart:add(shipPart).
      }
    }
    else {
      if shipPart:stage = theStage - 1 {
        stgPart:add(shipPart).
      }
    }
  }
  return stgPart.
}

// liste des moteurs d'un seul étage
// numéro de l'étage donné en argument
function listeMoteursEtage {
  parameter theStage.
  local stgEngine is list().
  local shipEnginesList is listeMoteurs().

  for shipEngine in shipEnginesList {
    if shipEngine:stage = theStage {
      stgEngine:add(shipEngine). 
    }
  }
  return stgEngine.
}

// liste des réservoirs avec oxidizer d'un seul étage
// numéro de l'étage donné en argument
function listeReservoirEtage {
  parameter theStage.
  local stgTanks is list().
  local shipTanksList is listeReservoirs().

  for shipTank in shipTanksList {
    if shipTank:stage = theStage - 1 {
      stgTanks:add(shipTank). 
    }
  }
  return stgTanks.
}

// masse de carburant d'un seul étage
// numéro de l'étage donné en argument
function masseCarburantEtage {
  parameter theStage.
  local fuelMass is 0.
  local tkList to listeReservoirEtage(theStage).
  local enList is listeMoteursEtage(theStage).
  for tank in tkList {
    // Vérifie si le réservoir est aussi un moteur
    local stageModifier is 1.
    for eng in enList {
      if (tank:name = eng:name) {
        set stageModifier to 0.
        BREAK.
      }
    }
    // Ne compte que LiquidFuel et Oxidiser
    if tank:stage = (theStage - stageModifier) {
      for resource in tank:resources {
        if (resource:name = "LiquidFuel" or resource:name = "Oxidizer") {
          set fuelMass to fuelMass + 0.005*resource:amount. // densité de 0.005t / unité pour LF et OX
        }
      }
    }
  }
  return fuelMass.
}


// Masse d'un seul étage.
// Ne compte pas les étages encore restant dans le craft !
// numéro de l'étage donné en argument
function masseEtage {
  parameter theStage.
  local stgMass is 0.
  local stgParts is listeComposantsEtage(theStage).
  for prt in stgParts {
    set stgMass to stgMass + prt:mass.
  }
  return stgMass.
}

// Toutes les caractéristiques d'un seul étage
// numéro de l'étage donné en argument
function caracteristiqueEtage {
  parameter theStage.
  local tmpList is list(
    masseInitiale(theStage),                    // tmpList[0] : masseInitiale
    masseFinale(theStage),                      // tmpList[1] : masseFinale
    pousseeEtage(theStage),                    // tmpList[2] : pousseeEtage
    ispEtage(theStage)                        // tmpList[3] : ispEtage
  ).
  tmpList:add(tmpList[3] * constant:g0).      // tmpList[4] : effective velocity -> Ve = ISP * g0
  tmpList:add(tmpList[2] / tmpList[4]).       // tmpList[5] : fuel Flow in t/s -> q = F / Ve
  tmpList:add(tmpList[4] * LN(tmpList[0] / tmpList[1])). // tmpList[6] : delta-v = Ve * ln(Mi / Mf)
  tmpList:add((tmpList[0] - tmpList[1]) / tmpList[5]).   // tmpList[7] : temps de combustion total = (Mi - Mf) / q
  return tmpList.
}

// Masse initiale d'un étage.
// numéro de l'étage donné en argument
function masseInitiale{
  parameter theStage.
  local initMass is 0.

  from {local cpt is theStage.}
  until cpt = -1
  step {set cpt to cpt - 1.}
  do {
    set initMass to initMass + masseEtage (cpt).  
  }
  return initMass.
}

// Masse Finale d'un étage après que tout le carburant de cet étage ait été consommé.
// numéro de l'étage donné en argument
function masseFinale{
  parameter theStage.
  return masseInitiale(theStage) - masseCarburantEtage(theStage).
}

// Poussée totale d'un étage en prenant en compte tous les moteurs de cet étage.
// numéro de l'étage donné en argument
function pousseeEtage {
  parameter theStage.
  local stgEngine is listeMoteursEtage(theStage).
  local stgThrust is 0.

  for en in stgEngine {
    set stgThrust to stgThrust + en:possibleThrust. 
  }
  return stgThrust.
}

// ISP Totale d'un étage en prenant en compte tous les moteurs de cet étage.
// numéro de l'étage donné en argument
// /!\ Utilisation de vISP donc ISP dans le vide...
// /!\ À peaufiner pour utiliser ISPat qui donne l'ISP en fonction de la pression atmosphérique
function ispEtage {
  parameter theStage.
  local sumThrust is 0.
  local sumFuelCons is 0.
  local stgEngine is listeMoteursEtage(theStage).

  for eng in stgEngine {
    set sumThrust to sumThrust + eng:possibleThrust.
    set sumFuelCons to sumFuelCons + (eng:possibleThrust / eng:vISP).
  }
  return choose sumThrust / sumFuelCons if sumFuelCons > 0 else -1.
}

// Vitesse Effective Ve d'un étage donné en argument
function effectiveVelocityEtage{
  parameter theStage.
  return ispEtage(theStage) * constant:g0.
}

// fuel flow d'un étage /!\ l'unité est tonne/seconde
function consoCarburantEtage{
  parameter theStage.
  return pousseeEtage(theStage) / effectiveVelocityEtage(theStage).
}

// Delta-v disponible dans un étage.
// Numéro de l'étage donné en argument
function dvEtage{
  parameter theStage.
  return effectiveVelocityEtage(theStage) * LN(masseInitiale(theStage) / masseFinale(theStage)).
}

// temps total de combustion pour un étage donné en argument.
function tempsTotalCombustion{
  parameter theStage.
  return (masseInitiale(theStage) - masseFinale(theStage)) / consoCarburantEtage(theStage).
}
