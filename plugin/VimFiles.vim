if exists('g:nvim-files') | finish | endif

"--------------------------------- Verify vars ----------------------------------------
"
" Themplate Root Path
if exists('g:vimFilesThemplatesRootPathFile')
    let g:vimFilesThemplatesRootPathFile = g:vimFilesThemplatesRootPathFile
else
    let g:vimFilesThemplatesRootPathFile = '~/.config/nvim/themplates/files'
endif
" Themplate Root Directory
if exists('g:vimFilesThemplatesRootPathDir')
    let g:vimFilesThemplatesRootPathDir = g:vimFilesThemplatesRootPathDir
else
    let g:vimFilesThemplatesRootPathDir = '~/.config/nvim/themplates/dirs'
endif
" Dictionary of themplates Dir
if exists('g:vimFilesThemplatesDir')
    let g:vimFilesThemplatesDir = g:vimFilesThemplatesDir
else
    let g:vimFilesThemplatesDir = { }
endif
" Dictionary of themplate Files
if exists('g:vimFilesThemplatesFiles')
    let g:vimFilesThemplatesFiles = g:vimFilesThemplatesFiles
else
    let g:vimFilesThemplatesFiles = { }
endif
" Open mode
if exists('g:vimFilesOpenMode')
    let g:vimFilesOpenMode = g:vimFilesOpenMode
else
    let g:vimFilesOpenMode = 0
endif

"-------------------------------------- Private Functions -------------------------------------
"
" Module for create Directory
function! s:MKDir(...) abort
    if isdirectory(a:1)
        return
    endif
    call mkdir(fnamemodify(a:1, ':p'), "p")
endfunction
" Get Relative Path
function! s:getRelativeFile(name)
    let l:name = getcwd().s:separator().a:name
    return fnamemodify(l:name, ':p')
endfunction
" Use Correct Separator
function! s:separator()
  return !exists('+shellslash') || &shellslash ? '/' : '\\'
endfunction
" Rename File
function! s:RenameFile(curfile, name)
    let l:curfile = a:curfile
    let l:curfilepath = getcwd()
    let l:newname = s:getRelativeFile(a:name)
    call s:MKDir(fnamemodify(l:newname, ':p:h'))
    let v:errmsg = ""
    silent! exe "saveas " . l:newname
    if v:errmsg =~# '^$\|^E329'
        s:DeleteFile(l:curfile)
    else
        echoerr v:errmsg
    endif
endfunction
function! s:DeleteFile(f)
    let l:file =s:getRelativeFile(a:f) 
    if filewritable(l:file)
        silent exe "bwipe! " . l:file
        if delete(l:file)
            echoerr "Could not delete " . l:file
        endif
    endif
endfunction
function! s:RemoveDir(d)
endfunction
function! s:Move(src, dest)
    call s:RenameFile(a:src, a:dest)
    filetype detect
endfunction
" Module for capture user input
function! s:GetInput(text)
    call inputsave()
    let l:input = input(a:text, '', 'file')
    call inputrestore()
    return l:input
endfunction

" Function to create File Path
function! s:CreateFile(filename, openMode)
    if !empty('a:filename')
        let l:name = s:getRelativeFile(a:filename)
        call s:MKDir(fnamemodify(l:name, ':h'), 0)
        call s:OpenNewFileMode(l:name, a:openMode)
    endif
endfunction
" Function to open buffer file
function! s:OpenNewFileMode(filename, openMode)
    let l:vimFilesOpenMode = g:vimFilesOpenMode
    if a:openMode != -1
        let g:vimFilesOpenMode = a:openMode
    endif
    if g:vimFilesOpenMode == 0 " tab
        execute "tabnew ".a:filename
    endif
    if g:vimFilesOpenMode == 1 " vsplit
        execute "vnew ".a:filename
    endif
    if g:vimFilesOpenMode == 2 " hsplit
        execute "new ".a:filename
    endif
    if g:vimFilesOpenMode == 3
        execute "enew ".a:filename
    endif
    let g:vimFilesOpenMode = l:vimFilesOpenMode
endfunction
"
" ________ Themplate Section ________
"
" Replace text for any value is finded
"
function! s:ReplaceText(text, filename)
    let l:textProcesed = a:text
    if stridx(l:textProcesed, "#FILENAME#UPPER#") >= 0
        let l:textProcesed = substitute(l:textProcesed, "#FILENAME#UPPER#", toupper(a:filename), "")
    endif
    if stridx(l:textProcesed, "#FILENAME#LOWER#") >= 0
        let l:textProcesed = substitute(l:textProcesed, "#FILENAME#LOWER#", tolower(a:filename), "")
    endif
    if stridx(l:textProcesed, "#FILENAME#") >= 0
        let l:textProcesed = substitute(l:textProcesed, "#FILENAME#", a:filename, "")
    endif
    return l:textProcesed
endfunction
"
" Make Themplate Dirs
function! s:DirThemplate(themplate)
    if has_key(g:vimFilesThemplatesDir, a:themplate)
        let l:vimThemplateFile = fnamemodify(g:vimFilesThemplatesRootPathDir . s:separator() . g:vimFilesThemplatesDir[a:themplate], ':p')
        for line in readfile(l:vimThemplateFile)
            let l:vimThemplate = fnamemodify(getcwd(). s:separator() . line, ':p')
            call s:MKDir(l:vimThemplate, 0)
        endfor
    else
        echoerr "Not found Themplate name"
        return
    endif
endfunction
" 
" Make Themplate Files
function! s:FileThemplate(filename, themplate, openmode)
    if has_key(g:vimFilesThemplatesFiles, a:themplate)
        let l:vimThemplate = fnamemodify(g:vimFilesThemplatesRootPathFile . s:separator() . g:vimFilesThemplatesFiles[a:themplate], ':p')
        let l:content = ''
        for line in readfile(l:vimThemplate)
            let l:content .= s:ReplaceText(line, fnamemodify(a:filename, ':t:r')) . "\x0a"
        endfor
        call s:CreateFile(a:filename, a:openmode)
        put! = l:content
    else
        echoerr "Not found Themplate name"
        return
    endif
endfunction

"--------------------------------------------- Plublic Functions ---------------------------------------------
"
"
" ________ Directory Functions ________
"
"
" Create Dir
function! VimFiles#Dir#Create() abort
    let l:dir = s:GetInput('Enter Directory Name: ')
    call s:MKDir(l:dir, 0)
endfunction
"
" Create Dirs based on Themplate
function! VimFiles#Dir#FromTemplate() abort
    let l:themplate = input('Enter themplate Name: ')
    call s:DirThemplate(l:themplate)
endfunction
"
" ________ Files Functions ________
"
"
function! VimFiles#File#Create() abort                       " To create File
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, -1)
endfunction
function! VimFiles#File#CreateTab() abort                    " To create File and Open in new Tab
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 0)
endfunction
function! VimFiles#File#CreateVS() abort                     " To create File and Open in Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 1)
endfunction
function! VimFiles#File#CreateHS() abort                     " To create File and Open in Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 2)
endfunction
function! VimFiles#File#CreateCW() abort                     " To create File and Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 3)
endfunction
"
" ________ Template Functions ________
"
"
" Create Files Based on Template
function! VimFiles#File#Template#Create() abort
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, -1)
endfunction
function! VimFiles#File#Template#CreateTab() abort                  " Open on new Tab
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 0)
endfunction
function! VimFiles#File#Themplate#CreateVS() abort                  " Open on Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 1)
endfunction
function! VimFiles#File#Themplate#CreateHS() abort                  " Open on Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 2)
endfunction
function! VimFiles#File#Themplate#CreateCW() abort                  " Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 3)
endfunction
"
" ________ Manipulate Files ________
"
"
" Rename Current File
"
function! VimFiles#Manipulate#File#RenameCurrentFile() abort
    let l:newname = s:GetInput('Enter New Name: ')
    call s:RenameFile(expand('%:p'), l:newname)
endfunction
" Rename File
function! VimFiles#Manipulate#File#RenameFile() abort
    let l:oldfile = s:GetInput('Enter the file to rename')
    let l:newname = s:GetInput('Enter New Name: ')
    call s:RenameFile(s:getRelativeFile(l:oldfile), l:newname)
endfunction
"
" Move Current File
"
function! VimFiles#Manipulate#File#MoveCurrentFile() abort
    let l:dfile = s:GetInput('Enter File Destination: ')
    call s:Move(expand('%:p'), l:dfile)
endfunction
" Move another file
function! VimFiles#Manipulate#File#MoveFile() abort
    let l:cfile = s:GetInput('Enter File To Move: ')
    let l:dfile = s:GetInput('Enter File Destination: ')
    call s:Move(s:getRelativeFile(l:cfile), l:dfile)
endfunction
"
" Delete Current File
"
function! VimFiles#Manipulate#File#DeleteCurrent() abort
    call s:DeleteFile(expand('%:p'))
endfunction
" Delete another File
function! VimFiles#Manipulate#File#Delete() abort
    let l:filename = s:GetInput('Enter File to Delete: ')
    call s:DeleteFile(l:filename)
endfunction

" -------------------------------------- Auto Commands --------------------------------------
"
" Automate Reload NerdTree on change buffer or save
" _________________________________________________
"
"autocmd CmdlineEnter * <C-x><C-f>
"command VimFilesCreateDir execute ":call VimFiles#CreateDir()"
"command -nargs=1 -complete=file MyCommand echomsg <q-args>
