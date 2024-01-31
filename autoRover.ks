//-----------------------------------------------------------
//  ALGORITHME A* POUR DÉTERMINER LE PLUS COURT CHEMIN
//  ENTRE UN ROVER ET UN DRAPEAU
//
//  CODE INITIAL : BOBIX
//  CONVERSION KOS : PHILIPPEDS et BOBIX
//-----------------------------------------------------------

// cd("0:/A-star").
// run autoRover.

//###########################################################
//--- Initialisation de kOS
//###########################################################
wait until ship:body = BODY("mun").
set config:suppressAutoPilot to false.
core:part:getModule("kosProcessor"):doEvent("open terminal").
set terminal:height to 20.
set terminal:width to 45.
clearScreen.

//###########################################################
//--- Définition des unités de longueur
//###########################################################
global unMetre is 360 / (2 * constant:pi() * ship:body:radius).
global uniteLongueur is 75. // unité de la "grille" en mètre 
                            // utile aussi pour calculer le coût de g pour les voisins horiz. ou vert.
global deltaVoisin is uniteLongueur * unMetre. // unité de recherche des voisins en degré
global coutDiagonal is floor(uniteLongueur * sqrt(2)). // pour calculer le coût de g pour les voisins en diagonale.

//###########################################################
//--- objectif :
//###########################################################
global drapeau is VESSEL("Petit Cratère").

//###########################################################
//--- définition du Rover : list(position du rover, position parent, g, h, f)
//--- g = coût de la position, h = distance à l'objectif, f = g + h
//###########################################################
global posRover is list(
    latlng(ship:geoposition:lat, ship:geoposition:lng),
    latlng(0,0),
    0,
    h(ship:geoposition),
    h(ship:geoposition)
).

//###########################################################
//--- Direction pour la grille de points
//###########################################################
global coefDir is (drapeau:geoposition:lat - ship:geoposition:lat) / (drapeau:geoposition:lng - ship:geoposition:lng).
// Problème si drapeau:geoposition:lng = ship:geoposition:lng... Cela ne devrait pas arriver :fingerCrossed:
global coefPerpDir is -1 / coefDir.
// Problème si drapeau:geoposition:lat = ship:geoposition:lat... Cela ne devrait pas arriver :fingerCrossed:
global coefDiag is (sqrt(2) / 2 - 1) / coefDir.
global coefAutreDiag is -1 / coefDiag.

//###########################################################
//--- log :
//###########################################################
log ";longitude;latitude;parent longitude;parent latitude;g;h;f" to ("0:/A-Star/closeList.csv").
log ";longitude;latitude" to ("0:/A-Star/cheminRover.csv").

//###########################################################
//--- conditions initiales
//###########################################################
global solutionTrouvee is false. //True si une solution est trouvée
global seuilPente is 20. //Pente limite que le rover peut grimper
//global maxDistance is uniteLongueur * ceiling(deltaVoisin / 2). // Distance maximale au drapeau lorsque distance manhattan utilisée
global maxDistance is ceiling(uniteLongueur / 2). // Distance maximale au drapeau lorsque distance cartésienne utilisée
print "            Distance de la cible : " + round(posRover[3],1) + " m  " at (0,terminal:height - 6).
print "       Heuristique max souhaitée : " + maxDistance + " m  " at (0,terminal:height - 5).

//###########################################################
//--- Initialisation des listes.
//###########################################################
global openList is list().
global closeList is list().
global cheminRover is list().

//###########################################################
//--- Définition des chronos
//###########################################################
global chrono is time:seconds.
global chronoSolution is time:seconds.
global chronoChemin is time:seconds.

//###########################################################
//--- Ajout du rover dans la liste de départ
//###########################################################
//insertElement(posRover).
ajoutOpen(posRover).

//###########################################################
//--- main
//###########################################################
main ().

function main {
    print ("Recherche du meilleur chemin en cours...").
    print ("Merci de patienter...").
    until openList:empty {
        // on sélectionne la meilleure position (avec le f minimal)
        local current is openList[0].
        openList:remove(0).
        closeList:add(current).
        log closeList:length+";"+current[0]:lng+";"+current[0]:lat+";"+current[1]:lng+";"+current[1]:lat+";"+current[2]+";"+current[3]+";"+current[4] to ("0:/A-Star/closeList.csv").

        // l'objectif est-il atteint ?
        if current[3] <= maxDistance {
            set solutionTrouvee to true.
            set chronoSolution to time:seconds.
            break.
        }

        // on détermine l'ensemble des voisins de current
        local listVoisins is chercheVoisin(current, seuilPente).

        // ajout des voisins à openList
        for voisin in listVoisins {
            local checkVoisin is checkList(voisin, openList).
            if checkVoisin[0] = true { // voisin se trouve dans openList
                local index is checkVoisin[1]. // on détermine son index dans openList
                if voisin[4] < openList[index][4] { // on compare les valeurs de f : si celle de voisin est meilleure
                    openList:remove(index). // on supprime l'ancienne position
                    //insertElement(voisin). // on ajoute voisin à openList
                    ajoutOpen(voisin).
                }
            }
            else { // si voisin ne se trouve pas dans openList,
                //insertElement(voisin). // on l'y ajoute.
                ajoutOpen(voisin).
            }
            //}
        }
        print "  éléments dans openList : " + openList:length + "  " at (0,terminal:height - 4).
        print " éléments dans closeList : " + closeList:length + "  " at (0,terminal:height - 3).
        print "Heur. du dernier élément : " + round(closeList[closeList:length-1][3],3) + "  " at (0,terminal:height - 2).
        print "    f du dernier élément : " + round(closeList[closeList:length-1][4],3) + "  " at (0,terminal:height - 1).
    }

    if solutionTrouvee {
        clearScreen.
        print ("Solution trouvée en : ") + round(chronoSolution - chrono, 2) + " s.".
        print ("Construction du chemin en cours.").
        set cheminRover to constructionChemin(closeList, posRover).
        print ("Chemin calculé en : ") + round(chronoChemin - chronoSolution, 2) + " s.".
        local posIndex is 1.
        for pos in cheminRover {
            log posIndex + ";"
                + pos:lng + ";"
                + pos:lat to ("0:/A-Star/cheminRover.csv").
            set posIndex to posIndex + 1.
        }

        local goTime is time:seconds + 5.
        until goTime - time:seconds <= 0 {
            print ("Le rover va commencer son déplacement dans : ") + round(goTime - time:seconds,1) + " s   " at (0,5).
        }
        deplacerRover(cheminRover).
    }
    else {
        print ("Pas de chemin possible.").
        print ("Temps de calcul : ") + round(chronoSolution - chrono, 2) + " s.".
    }
}

//###########################################################
//--- Ajout d'un élément à la openList
//--- La liste est triée en fonction des valeurs croissantes de f
//--- L'élément le plus intéressant (f minimal) est le premier de la liste.
//###########################################################
function ajoutOpen {
    parameter element. // element = list (latlng(), latlng(), g, h, f)
    local index is 0.

    if openList:length = 0 {
        openList:add(element).
    }

    until openList:contains(element) {
        if index >= openList:length {
            openList:add(element).
        }
        else {
            if element[4] < openList[index][4] {
                openList:insert(index, element).
                break.
            }
            set index to index + 1.
        }
    }
}

//###########################################################
//--- Ajout d'un élément à la openList en utilisant une fonction récursive
//--- La liste est triée en fonction des valeurs croissantes de f
//--- L'élément le plus intéressant (f minimal) est le premier de la liste.
//###########################################################
function ajoutRecursif {
    parameter element.
    parameter oneList is openList.
    local L is oneList:length.
    local midIndex is floor(L/2).
    local newList is list().

    if L = 0 {return -1.}

    if midIndex = L - 1{
        if oneList[midIndex][4] > element[4] {
            return midIndex.
        }
        else {
            return -1.
        }
    }

    if oneList[midIndex][4] <= element[4] and oneList[midIndex + 1][4] >= element[4] {
        return midIndex + 1.
    }

    if oneList[midIndex][4] > element[4] {
        set newList to oneList:sublist(0, midIndex - 1).
        return ajoutRecursif(element, newList).
    }
    else {
        set newList to oneList:sublist(midIndex + 1, L - midIndex).
        return ajoutRecursif(element, newList).
    }
}

function insertElement {
    parameter element.
    parameter oneList is openList.
    local index is ajoutRecursif(element, oneList).
    if index < 0 {oneList:add(element).}
    else {oneList:insert(index, element).}
}

//###########################################################
//--- Vérifie si un élément appartient à une liste.
//--- Si oui, retourne également l'index de l'élément dans cette liste.
//###########################################################
function checkList {
    parameter position, list.
    local inList is false.
    local index is 0.
    local result is list(inList, index).
    for pos in list {
        if pos[0]:lng = position[0]:lng and pos[0]:lat = position[0]:lat {
            set inList to true.
            set index to list:indexOf(pos).
            break.
        }
    }
    set result to list(inList, index).
    return result.
}

//###########################################################
//--- Calcule l'heuristique entre une position et l'objectif
//###########################################################

//--- en utilisant la distance de Manhattan
//-----------------------------------------------------------
// function h {
//     parameter pos.
//     parameter destination is drapeau.
//     return 10 * uniteLongueur * (abs(pos:lng - destination:geoposition:lng) +
//                     abs(pos:lat - destination:geoposition:lat)).
// }

//--- en utilisant les vecteurs position
//-----------------------------------------------------------
function h {
    parameter pos.
    parameter destination is drapeau.
    return round((pos:position - destination:geoposition:position):mag).
}

//###########################################################
//--- Déterminer la pente entre deux positions
//###########################################################
function pente {
    parameter position1, position2.
    local distance is sqrt((position1:lng - position2:lng)^2 +
                            (position1:lat - position2:lat)^2) / unMetre.
    return abs((position2:terrainHeight - position1:terrainHeight) / distance) * 100.
}

//###########################################################
//--- Cherche les voisins posibles de la position sélectionnée
//--- en respectant la limite maximale d'une pente.
//###########################################################
function chercheVoisin {
    parameter position, slope.
    local listVoisins is list().

    // // voisin "devant"
    checkVoisin(1, coefDir).
    // voisin "derrière"
    checkVoisin(-1, -coefDir).
    // voisin "à droite"
    checkVoisin(1, coefPerpDir).
    // voisin "à gauche"
    checkVoisin(-1, -coefPerpDir).
    // voisin "en haut à droite"
    checkVoisin(1, coefDiag, coutDiagonal).
    // voisin "en bas à gauche"
    checkVoisin(-1, -coefDiag, coutDiagonal).
    // voisin "en bas à droite"
    checkVoisin(1, coefAutreDiag, coutDiagonal).
    // voisin "en haut à gauche"
    checkVoisin(-1, -coefAutreDiag, coutDiagonal).
    // checkVoisin(1, 0).
    // checkVoisin(-1, 0).
    // checkVoisin(0, 1).
    // checkVoisin(0, -1).
    // checkVoisin(-1, -1, coutDiagonal).
    // checkVoisin(-1, 1, coutDiagonal).
    // checkVoisin(1, -1, coutDiagonal).
    // checkVoisin(1, 1, coutDiagonal).

    function checkVoisin {
        parameter deltaLng, deltaLat.
        parameter deltaG is uniteLongueur.
        // on détermine un voisin de la position
        local voisin1Lng is position[0]:lng + deltaLng * deltaVoisin.
        local voisin1Lat is position[0]:lat + deltaLat * deltaVoisin.        
        local voisin1 is list(latlng(voisin1Lat, voisin1Lng), latlng(position[0]:lat, position[0]:lng),0,0,0).
        
        if pente(position[0], voisin1[0]) < slope {
            // modif g
            set voisin1[2] to position[2] + deltaG.
            // modif h
            set voisin1[3] to h(voisin1[0]).
            // modif f
            set voisin1[4] to voisin1[2] + voisin1[3].
            listVoisins:add(voisin1).
        }
        local checkVoisinList is checkList(voisin1, listVoisins).
        if checkList(voisin1, closeList)[0] and checkVoisinList[0] {
            local index is checkVoisinList[1].
            listVoisins:remove(index).
        }
    }
    return listVoisins.
}

//###########################################################
//--- Construction du chemin à partir de la closeList
//--- dans le sens drapeau -> rover
//###########################################################
function constructionChemin {
    parameter list, start.
    local chemin is list().
    local index is list:length - 1.
    local pos is list[index].
    chemin:add(pos[0]).
    until pos[0]:lng = start[0]:lng and pos[0]:lat = start[0]:lat {
        print "Nombre d'éléments dans chemin : " + chemin:length at (0,terminal:height - 1).
        set index to index - 1.
        if list[index][0]:lng = pos[1]:lng and list[index][0]:lat = pos[1]:lat {
            set pos to list[index].
            chemin:add(pos[0]).
        }
    }
    set chemin to inverseChemin(chemin).
    set chronoChemin to time:seconds.
    return chemin.
}

//###########################################################
//--- Chemin remis dans le bon sens rover -> drapeau
//###########################################################
function inverseChemin {
    parameter list.
    local result is list().
    local index is list:length - 1.
    until result:length = list:length {
        result:add(list[index]).
        set index to index - 1.
    }
    return result.
}

//###########################################################
//--- Déplacement du rover en utilisant des PID LOOP
//###########################################################
function deplacerRover {
    parameter wayPoints.
    local chronoRover is time:seconds.
    clearScreen.
    brakes off.
    lights on.

    local index is 0.
    print "Nombre de points de passage : " + wayPoints:length.
    print "Dernier point de passage : ".
    print "    coord : (" + round(wayPoints[wayPoints:length - 1]:lng,5) + " ; " + round(wayPoints[wayPoints:length - 1]:lat,5) + ").".
    print "    distance drapeau : " + round((wayPoints[wayPoints:length - 1]:position - drapeau:position):mag,1) + " m".
    until index > wayPoints:length - 1 {
        local cible is wayPoints[index].
        print "Point de passage n° " + index + "  " at (0,10).
        print "Coordonnées : (" + round(cible:lng,5) + " ; " + round(cible:lat,5) + ").   " at (0,11).

        // initialisation Vitesse
        set wheelThrottlePID to 0.
        set speedPID to PIDLoop(0.5, 0.1, 0.1, -5, 0.25).
        set speedPID:setPoint to max(6, min(0.5 * cible:distance, 9)).
        lock wheelThrottle to wheelThrottlePID.

        // initialisation Direction
        set wheelDirection to 0.
        set turnPID TO PIDLOOP(0.01,0.001,0.01,-0.3,0.3).
        set turnPID:setPoint to 0.

        // MaJ vitesse :
        set myVelocity to ship:velocity:surface:mag.
        set wheelThrottlePID to speedPID:UPDATE(time:seconds, myVelocity).
        // MaJ direction :
        set myHeading to cible:bearing.
        set wheelDirection to turnPID:UPDATE(TIME:SECONDS, myHeading).
        set ship:control:wheelsteer to wheelDirection.
        print "Distance au point de passage : " + round(cible:distance, 1) + (" m    ") at (0,12).
        print "Distance du rover à la cible : " + round(drapeau:distance, 1) + (" m    ") at (0,13).

        print "Vitesse actuelle : " + round(ship:velocity:surface:mag, 1) + (" m/s    ") at (0,15).


        if cible:distance < 5 {
            set index to index + 1.
        }

        if drapeau:distance < 2*maxDistance {break.}
    }
    
    clearScreen.
    until ship:velocity:surface:mag < 0.01 {
        print "Procédure d'arrêt du rover en cours..." at (0,3).
        print "Distance du rover à la cible : " + round(drapeau:distance, 1) + (" m    ") at (0,13).

        print "Vitesse actuelle : " + round(ship:velocity:surface:mag, 1) + (" m/s    ") at (0,15).
        lock wheelThrottle to 0.
        brakes on.
    }
    wait 1.
    clearscreen.
    print "Le rover a effectué son trajet en : " + round(time:seconds - chronoRover, 2) + " s.".
    unlock wheelThrottle.
    wait 3.
}



