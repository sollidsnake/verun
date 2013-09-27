" VERun
" File: verun.vim
" Description: automatically run/compile your programs inside vim
" Author: Jesse Nazario <jessenzr at gmail dot com>

" config variables
let g:VEAutosave=1
let g:VEGppArg=""
let g:VEMakeRun=""
let g:VEPythonVer="auto"
let g:VEAutoClear=1
let g:VEExecArg=""

if has("gui_running")
  let g:VEExternalTerm=1
else 
  let g:VEExternalTerm=0
endif

let g:VETerm="xterm -e"
let g:VECppAutoHeaders=1
let g:VECppAutoHeaderList={"ncurses.h": "ncurses", "libusb-1.0/libusb.h": "usb-1.0"}

" default commands
command! VERun call verun#Compile(1, 0)
command! VERunMake call verun#Compile(1, 1)
