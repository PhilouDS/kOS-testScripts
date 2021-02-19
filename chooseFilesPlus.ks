switch to 0.
set directory to "0:".
list files in tempList.
set folderList to list().
set fileList to list().
for f in tempList {
    if f:isFile {fileList:add(f).}
    else {folderList:add(f).}
}.

set screen_resolution_x to 1920.
set screen_resolution_y to 1080.
set window_wide to 200.

global tempButtonList to list().

set closeWindow to false.

local chooseFile_window is gui(window_wide).
set chooseFile_window:x to screen_resolution_x - window_wide - 100.
set chooseFile_window:y to 0.1 * screen_resolution_y.



global continue_window is gui(window_wide).
set continue_window:x to (screen_resolution_x - window_wide)/2.
set continue_window:y to 0.25*screen_resolution_y.
continue_window:hide().
continue_window:addLabel("Copy more files?").
local myPadding is 15.
set continue_window:style:padding:H to myPadding.
local continue_horizontal is continue_window:addHlayout.
set continue_horizontal:style:padding:H to 0.
local yesButton is continue_horizontal:addButton("YES").
set yesButton:style:width to (window_wide - 2*myPadding)/2 - 5.
continue_horizontal:addSpacing(10).
local noButton is continue_horizontal:addButton("NO").
set noButton:style:width to (window_wide - 2*myPadding)/2 - 5.


global run_window is gui(window_wide).
set run_window:x to (screen_resolution_x - window_wide)/2.
set run_window:y to 0.25*screen_resolution_y.
run_window:hide().
run_window:addLabel("Run a file?").
local myPadding is 15.
set run_window:style:padding:H to myPadding.
local run_horizontal is run_window:addHlayout.
set run_horizontal:style:padding:H to 0.
local yesRunButton is run_horizontal:addButton("YES").
set yesRunButton:style:width to (window_wide - 2*myPadding)/2 - 5.
run_horizontal:addSpacing(10).
local noRunButton is run_horizontal:addButton("NO").
set noRunButton:style:width to (window_wide - 2*myPadding)/2 - 5.


local go_window is gui(window_wide).
set go_window:x to (screen_resolution_x - window_wide)/2.
set go_window:y to 0.25*screen_resolution_y.
go_window:hide().


chooseFile_window:addLabel("Choose a folder").
chooseFile_window:addSpacing(5).

local popupMenuList is chooseFile_window:addpopupmenu().
popupMenuList:addoption("Archive").
for folder in folderList {if folder:name <> "boot" {popupMenuList:addoption(folder:name).}}

chooseFile_window:addSpacing(10).

local choiceLabel is chooseFile_window:addLabel("Choose files you want to copy.").
chooseFile_window:addSpacing(5).

local chooseArchiveFile_box is chooseFile_window:addVbox.

chooseFile_window:addSpacing(10).

local button_box is chooseFile_window:addHlayout.
local copyButton is button_box:addButton("Copy").
local cancelButton is button_box:addButton("Cancel").


for files in fileList {
    set myButton to chooseArchiveFile_box:addCheckBox(files:name, false).
    tempButtonList:add(myButton).
}.

set popupMenuList:onChange to {
    parameter c.
    fileList:clear().
    chooseArchiveFile_box:clear().
    tempButtonList:clear().
    if popupMenuList:index = 0 {
        set directory to "0:".
        cd(directory).
        list files in tempList.
        for f in tempList {
            if f:isFile {fileList:add(f).}
        }.
    }
    else {
        set directory to "0:/" + popupMenuList:value.
        cd(directory).
        list files in tempList.
        for f in tempList {
            if f:isFile {fileList:add(f).}
        }.
    }
    for files in fileList {
        set myButton to chooseArchiveFile_box:addCheckBox(files:name, false).
        tempButtonList:add(myButton).
    }.
}.

chooseFile_window:show().

set copyButton:onClick to copyFiles@.
set cancelButton:onClick to cancelProgram@.
set yesButton:onClick to yesCopyButtonAction@.
set noButton:onclick to noCopyButtonAction@.
set yesRunButton:onClick to yesRunButtonAction@.
set noRunButton:onclick to noRunButtonAction@.

wait until closeWindow.

chooseFile_window:dispose().
continue_window:dispose().
run_window:dispose().
go_window:dispose().
switch to 1.

function copyFiles {
    global copiedFiles is list().
    for eachButton in tempButtonList {
        if eachButton:pressed {
            copypath(directory + "/" + eachButton:text, "1:/" + eachButton:text).
            copiedFiles:add(eachButton:text).
        }
        wait 0.
    }.
    continue_window:show().
    set copyButton:enabled to false.
    set cancelButton:enabled to false.
    wait 0.
}.

function cancelProgram {
    set closeWindow to true.
}

function yesCopyButtonAction {
    continue_window:hide().
    set copyButton:enabled to true.
    set cancelButton:enabled to true.
    set popupMenuList:index to 0.
}

function noCopyButtonAction {
    continue_window:hide().
    chooseFile_window:hide().
    run_window:show().
}

function yesRunButtonAction {
    run_window:hide().
    local go_popup is go_window:addpopupmenu().
    go_popup:addOption("Choose a file to run.").
    switch to 1.
    list files in tempList.
    for myFiles in tempList {
        if myFiles:name <> "chooseFilesPlus.ks" and myFiles:isFile  {go_popup:addOption(myFiles).}        
    }
    go_window:show().
    set go_popup:onChange to {parameter c. if go_popup:index <> 0 {set closeWindow to true. runOncePath(c).}}.
}.

function noRunButtonAction {
    set closeWindow to true.
}