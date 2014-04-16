" VE
" File: verun.vim
" Description: automatically run/compile your programs inside vim
" Author: Jesse Nazario <jessenzr at gmail dot com>

" config variables
let s:VEName="Verun"

" Check the header to find python version
function! s:TreatPythonVer()
  if( strpart(getline(1), 0, 2) == "#!" )
    let l:pyver = split( getline(1), "python" )
  else
    return ""
  endif
  if exists("l:pyver[-1]") && strpart(l:pyver[-1], 0, 2) != "#!" 
    return l:pyver[-1]
  else 
    return ""
  endif
endfunction

function! s:GetCppHeaders()
  " check the defined list
  let l:libList = s:TreatLocalVar('VECppAutoHeaderList', g:VECppAutoHeaderList)
  " get num of lines
  let l:lines = line('$')
  " get buffer content
  let l:buffer = getline(1, l:lines)
  " declare list of libs to return
  let l:libs = []
  let l:count = 1
  for l:line in l:buffer " check for '#include' for every line in buffer
    if strpart(l:line, 0, 8) == "#include"
      let [l:tmp, l:lib] = split(l:line, "<")
      unlet l:tmp
      let l:lib = substitute(l:lib, ">", "", "")
      " if find included library in the headers, append to libs list
      if exists("l:libList[\"".l:lib."\"]")
        let l:libs += ["-l " . l:libList[l:lib]]
      endif
    endif
  endfor
  " return found libs
  return join(l:libs, " ")
endfunction

" Local variables vs global variables vs default value
function! s:TreatLocalVar(v, default)
  " check if global variable is empty
  exec "let l:global = !empty(g:" . a:v .")"

  if exists('w:'.a:v)  " check for local defined variable
    exec "return w:" . a:v
  elseif l:global " check if global is non-zero
    exec "return g:" . a:v
  else " return default value
    return a:default
  endif
endfunction

" check for compilation errors
function! s:CheckCppErrors(cmd, out)
  if stridx(a:out, "error: ") < 0
    return 0
  else
    echo s:VEName . ": Compilation error: " . a:cmd "\n" . a:out
    return 1
  endif
endfunction

" core function
function! verun#Compile(run, make) 
  if empty(&filetype)
    echom s:VEName . ": No filetype set"
    return 0
  endif

  if s:TreatLocalVar('VEAutosave', 1) " check if auto save is enabled
    write
  endif

  " big if
  if !empty(a:make) " check if makefile will be used
    let l:dir = expand("%:p:h")
    let l:cmd = "make -B -C " . l:dir
    let l:result = system(l:cmd)

    let l:runfile = s:TreatLocalVar("VEMakeRun", expand("%:p:r:s"))
    let l:exec = "" . l:runfile
  else " if not using makefile check the filetype
    let l:execArg = " " . s:TreatLocalVar("VEExecArg", g:VEExecArg)
    if &filetype == "cpp"
      let l:file = expand("%:p") " file dir
      let l:exec = expand("%:p:r:s") " exec dir

      let l:gppArg = s:TreatLocalVar("VEGppArg", g:VEGppArg)
      let l:cpphead = s:TreatLocalVar("VECppAutoHeaders", g:VECppAutoHeaders)
      if l:cpphead
        let l:gppArg .= " " . s:GetCppHeaders()
      endif

      " Compile and store result
      let l:cmd = "g++ -Wall " . l:file . " -o " . l:exec . " " . l:gppArg
      let l:result = system(l:cmd)
      if !empty(s:CheckCppErrors(l:cmd, l:result)) " check compilation errors
        return 1
      else
        let l:exec = "" . l:exec
      endif
    elseif &filetype == "php" " php
      let l:exec = "php -e " . expand("%:p")
    elseif &filetype == "sh" " sh
      let l:exec = "sh " . expand("%:p")
    elseif &filetype == "python" " python
      let l:pyver = s:TreatLocalVar("VEPythonVer", "")
      if l:pyver=="auto"
        let l:pyver = s:TreatPythonVer()
      endif

      let l:python = 'python' . l:pyver
      let l:exec = "" . l:python . " " . expand("%:p")
    elseif &filetype == 'java' "java
      let l:cmd = "javac " . expand("%:p")
      let l:result = system(l:cmd)
      let l:exec = "cd " . expand("%:p:h") . " && java " . expand("%:t:r")
      echom l:exec
    else
      echom s:VEName . ": " .  &filetype . " is not implemeneted (yet)"
      return 0
    endif

  endif
  if s:TreatLocalVar("VEExternalTerm", g:VEExternalTerm) " treat for custom terminal
    let l:exec = s:TreatLocalVar("VETerm", "xterm -e") . " \"" . l:exec . "; read;\" "
    let l:silent = "silent "
  else | let l:silent = ""
  endif 

  " execute the program
  if a:run
    if s:TreatLocalVar('VEAutoClear', g:VEAutoClear) && !s:TreatLocalVar('VEExternalTerm', g:VEExternalTerm) 
      let l:clear = "clear; "
    else
      let l:clear = ""
    endif

    exec l:silent . "!" . l:clear . l:exec . l:execArg
    " wait for keypress after execution inside gvim
    if has("gui_running") && !s:TreatLocalVar('VEExternalTerm', g:VEExternalTerm) 
      call getchar()
    endif
  endif

  " after external execution the screen might inherit the terminal colors
  " execute redraw to fix it
  redraw!

  return 0
endfunction
