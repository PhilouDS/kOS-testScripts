set programDone to false.


global manualControlBox is gui(150).
set manualControlBox:y to 60.
    local manualText is manualControlBox:addLabel("<b>Manual Control</b>").
        set manualText:style:textcolor to red.
        set manualText:style:hstretch to true.
        set manualText:style:align to "CENTER".
        set manualText:style:fontsize to 15.
manualControlBox:hide().

//---------------------------
local window_width is 300.
local offset is 10.
local small_button_width is 20.
local small_button_height is 20.
//---------------------------


global window_telemetry is gui(window_width).
    set window_telemetry:style:padding:H to offset.
set window_telemetry:x to 1200.
set window_telemetry:y to 200.

//--------------------------
// SKINS
//--------------------------

set window_telemetry:skin:font to "Consolas".
set window_telemetry:skin:button:hover:textcolor to red.
set window_telemetry:skin:button:textcolor to green.
set window_telemetry:skin:button:width to small_button_width.
set window_telemetry:skin:button:height to small_button_height.
set window_telemetry:skin:button:hstretch to true.
set window_telemetry:skin:button:align to "CENTER".
set window_telemetry:skin:button:fontSize to 15.
set window_telemetry:skin:label:fontSize to 15.

set oldStatus to ship:status.
wait until not core:messages:empty.
set received to core:messages:pop.
set targetApoapsis to received:content.

window_telemetry:addSpacing(10).

local top_box is window_telemetry:addHbox.
    set top_box:style:hstretch to true.

window_telemetry:addSpacing(10).

local main_box is window_telemetry:addVlayout.
    set main_box:style:hstretch to true.

window_telemetry:addSpacing(10).

local bottom_box is window_telemetry:addHbox.
    set bottom_box:style:hstretch to true.

//-------------------------
// TOP BOX
//-------------------------
    local title_box is top_box:addHlayout.
    set title_box:style:width to window_width - 2*small_button_width.
        local title is title_box:addLabel("").
        set title:text to ("<b>Telemetry: ") + ship:name + (" || ") + ship:status + ("</b>").
        set title:style:textcolor to RGB(25,250,25).
        set title:style:hstretch to True.
        set title:style:align to "CENTER".

    local reduceButton is top_box:addButton("_").
        set reduceButton:style:padding:bottom to 15.
        set reduceButton:toggle to true.
        set reduceButton:onToggle to { 
            parameter T.
            if T {main_box:hide().}
            else {main_box:show().}
        }.
    local closeButton is top_box:addButton("X").
        set closeButton:style:padding:bottom to 10.
        set closeButton:onClick to {set programDone to true.}.

//-------------------------
// MIDDLE BOX
//-------------------------
    local middle_box is main_box:addVLayout.

    local choice_box is middle_box:addHlayout.

    local scrollList is choice_box:addpopupmenu().
    local choiceList is list("Flight info", "Ship caracteristics", "Orbit info", "Body info").
    for option in choiceList {scrollList:addoption(option).}.

    middle_box:addSpacing(offset).
   
    local display_box is middle_box:addVbox.
        local info_box is display_box:addVlayout.
            local info_text is info_box:addLabel("--- Informations ---").
                set info_text:style:hstretch to true.
                set info_text:style:align to "CENTER".
            local actualAltitude_box is addParametre("Actual Altitude: ", info_box).
            local actualVelocity_box is addParametre("Velocity: ", info_box).
            local ApoTarget_box is addParametre("Target Apoapsis: ", info_box).
            local actualApo_box is addParametre("Apoapsis: ", info_box).
            local actualPe_box is addParametre("Periapsis: ", info_box).
            info_box:show().
        //
        local caract_box is display_box:addVlayout.
            local caract_text is caract_box:addLabel("--- Caracteristics ---").
                set caract_text:style:hstretch to true.
                set caract_text:style:align to "CENTER".
            local shipMass_box is addParametre("Mass: ", caract_box).
            local shipDeltaV_box is addParametre("Delta V: ", caract_box).
            local stageDeltaV_box is addParametre("Stage Delta V: ", caract_box).
            local shipBurnTime_box is addParametre("Burn Time Stage: ", caract_box).
            caract_box:hide().
        //
        local orbit_box is display_box:addVlayout.
            local orbit_text is orbit_box:addLabel("--- Orbit ---").
                set orbit_text:style:hstretch to true.
                set orbit_text:style:align to "CENTER".
            local orbitAp_box is addParametre("Apoapsis: ", orbit_box).
            local orbitPe_box is addParametre("Periapsis: ", orbit_box).
            local orbitEc_box is addParametre("Eccentricity: ", orbit_box).
            local orbitArg_box is addParametre("Argument of Pe: ", orbit_box).
            local orbitInc_box is addParametre("Inclination: ", orbit_box).
            local orbitLAN_box is addParametre("Longitude Asc. Node: ", orbit_box).
            local orbitPeriod_box is addParametre("Period (d:h:m:s): ", orbit_box).
            orbit_box:hide().
        //
        local body_box is display_box:addVlayout.
            local body_text is body_box:addLabel("--- Body ---").
                set body_text:style:hstretch to true.
                set body_text:style:align to "CENTER".
            local bodyName_box is addParametre("Name: ", body_box).
            local bodySOI_box is addParametre("SOI: ", body_box).
            local bodySOI2_box is addParametre("", body_box).
            local bodyRotation_box is addParametre("Rotation Period: ", body_box).
            local bodyRotation2_box is addParametre("", body_box).
            local bodySync_box is addParametre("GeoSync. Altitude: ", body_box).
            local bodybody_box is addParametre("Body: ", body_box).
            body_box:hide().

        set listBox to list(info_box, caract_box, orbit_box, body_box).
        set scrollList:onChange to {parameter c. display_box:showonly(listBox[scrollList:index]).}.

main_box:addSpacing(10).        

//-------------------------
// BOTTOM BOX
//-------------------------
    local abortButton is bottom_box:addButton("<b>ABORT</b>").
        set abortButton:style:width to (window_width - offset)/2.
        set abortButton:style:height to 25.
        set abortButton:onClick to {abort on.}.

    local newOffset is 2*offset.
    bottom_box:addSpacing(newOffset).

    local emergencyButton is bottom_box:addButton("<b>Manual Control</b>").
        set emergencyButton:style:width to (window_width - offset)/2.
        set emergencyButton:style:height to 25.
        set emergencyButton:toggle to true.
        set emergencyButton:onToggle to { 
            parameter T.
            if T {set config:suppressAutopilot to true. manualControlBox:show().}
            else {set config:suppressAutopilot to false. manualControlBox:hide().}
        }.





set terminal:width to 45.
set terminal:height to 26.

set oldBody to ship:body.
set geoSync to computeGeoSync(ship:body).
//core:part:getModule("kOSProcessor"):doEvent("Open Terminal").

set initialMass to ship:mass.
wait until ship:mass < initialMass.

wait 1.

printTelemetry().

global function printTelemetry{
    window_telemetry:show().
    until programDone {
        if ship:body <> oldBody {set geoSync to computeGeoSync(ship:body). set oldBody to ship:body.}
        if oldStatus <> ship:status {
            set title:text to ("<b>Telemetry: ") + ship:name + (" || ") + ship:status + ("</b>").
            set oldStatus to ship:status.
        }
        getParameter().
        setParameter().
        wait 0.
    }

    window_telemetry:dispose().
    manualControlBox:dispose().
    shutdown.
}

function getParameter{
    // SHIP INFO
    set actualAltitude to round(ship:altitude,1).
    set actualVelocity to choose round(ship:velocity:surface:mag,1) if ship:altitude < 36000 else round(ship:velocity:orbit:mag,1).
    set ApoTarget to targetApoapsis.
    set actualApo to round(ship:orbit:apoapsis,1).
    set actualPe to round(ship:orbit:periapsis,1).

    // SHIP CARACT
    set shipMass to round(ship:mass,3).
    set shipDeltaV to round(ship:deltaV:current,1).
    set stageDeltaV to round(ship:stageDeltaV(ship:stageNum):current,1).
    set shipBurnTime to round(ship:stageDeltaV(ship:stageNum):duration,1).

    //-- ORBIT CARACT
    set orbitAp to ship:orbit:apoapsis.
    set orbitPe to ship:orbit:periapsis.
    set orbitEc to ship:orbit:eccentricity.
    set orbitArg to ship:orbit:argumentofperiapsis.
    set orbitInc to ship:orbit:inclination.
    set orbitLAN to ship:orbit:lan.
    if orbitAp < 0 {set orbitPeriod to 0.} else {set orbitPeriod to ship:orbit:period.}
    set dayNum to floor(orbitPeriod / kerbin:rotationperiod).
}

function setParameter{
    // SHIP INFO
    set actualAltitude_box:text to actualAltitude:toString + (" m").
    set actualVelocity_box:text to actualVelocity:toString + (" m/s").
    set ApoTarget_box:text to ApoTarget:toString + (" m").
    set actualApo_box:text to actualApo:toString + (" m").
    set actualPe_box:text to actualPe:toString + (" m").

    // SHIP CARACT
    set shipMass_box:text to shipMass + (" t").
    set shipDeltaV_box:text to shipDeltaV + (" m/s").
    set stageDeltaV_box:text to stageDeltaV + (" m/s").
    set shipBurnTime_box:text to shipBurnTime + (" s").

    //-- ORBIT CARACT
    set orbitAp_box:text to round(orbitAp, 1):toString + (" m").
    set orbitPe_box:text to round(orbitPe, 1):toString + (" m").
    set orbitEc_box:text to round(10^5 * orbitEc, 2):toString + (" x 10^(-5)").
    set orbitArg_box:text to round(orbitArg, 2):toString + ("°").
    set orbitInc_box:text to round(orbitInc, 2):toString + ("°").
    set orbitLAN_box:text to round(orbitLAN, 2):toString + ("°").
    set orbitPeriod_box:text to dayNum:toString + ":" + (time(orbitPeriod):clock):toString.

    //-- BODY INFO
    set bodyName_box:text to ship:body:name.
    set bodySOI_box:text to round(ship:body:SOIradius,2):toString + (" m").
    set bodySOI2_box:text to round(ship:body:SOIradius/1000000,3):toString + (" Mm").
    set bodyRotation_box:text to round(ship:body:rotationperiod,2):toString + (" s").
    set bodyRotation2_box:text to (time(ship:body:rotationperiod):clock):toString.
    set bodySync_box:text to choose round(geoSync,2):toString + (" m") if geoSync < ship:body:SOIradius else "none".
    set bodybody_box:text to ship:body:body:name.
}


// bobix
//Ajoute un champ de paramètre
function addParametre{
	parameter nom.
	parameter layout.

    local largeurColonne is window_width.

	local ligne is layout:addHLayout().
    local etiquette is ligne:addlabel(nom).
	set etiquette:style:width to 0.5*largeurColonne - offset.
    set etiquette:style:align to "right".
	local valeur is ligne:addlabel("").
	set valeur:style:width to 0.5*largeurColonne - offset.
	set valeur:style:align to "left".

	return valeur.
}


function computeGeoSync{
    parameter theBody.
    local Vcub is 2 * constant:pi() * theBody:mu / theBody:rotationPeriod.
    local vel is (Vcub)^(1/3).
    local altR is vel * theBody:rotationPeriod / (2*constant:pi()).
    return altR - theBody:radius.
}