VERun
Easily run/compile your files inside vim.

The main goal of VERun is to run your program with just one command without leaving vim. You just open the file you want to run and execute :VERun.

Main features included in this version:
- Runs C/C++, php, python, bash/sh and makefiles with just one command, without needing to cd your dir nor configuring anything 
- Auto detect your C/C++ headers and adds the links to the g++ command (see VECppAutoHeaderList) 
- Auto detect your python version 
- Option to execute your program in an external terminal 
- Currently supports only C/C++, php, python, bash/sh and makefiles

To compile/run your program, run:
    :VERun 

For further information and configuration, check [help file](doc/verun.txt) in the doc folder

Author: jessenzr@gmail.com<br>
Please feel free to contact me for suggestions, critics or anything :)
