if exists('g:nvim-files') | finish | endif

"--------------------------------- Verify vars ----------------------------------------
"
" Themplate Root Path
if !exists('g:vimFilesThemplatesRootPathFile')
    let g:vimFilesThemplatesRootPathFile = '~/.config/nvim/themplates/files'
endif
" Themplate Root Directory
if !exists('g:vimFilesThemplatesRootPathDir')
    let g:vimFilesThemplatesRootPathDir = '~/.config/nvim/themplates/dirs'
endif
" Dictionary of themplates Dir
if !exists('g:vimFilesThemplatesDir')
    let g:vimFilesThemplatesDir = { }
endif
" Dictionary of themplate Files
if !exists('g:vimFilesThemplatesFiles')
    let g:vimFilesThemplatesFiles = { }
endif
" Open mode
if !exists('g:vimFilesOpenMode')
    let g:vimFilesOpenMode = 0
endif
" Auto Comfirm delete Folder
if !exists('g:vimFiles_AutoConfirmDeleteFolder')
    let g:vimFiles_AutoConfirmDeleteFolder = v:false
endif


let s:isLinux = !has("win32")

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
    silent! exe "saveas " . l:newname | call s:DeleteFile(a:curfile)
endfunction
function! s:DeleteFile(f)
    call delete(a:f)
endfunction
" Rename Dir
function! s:RenameDir(curDir, outDir)
    let l:cDir = s:getRelativeFile(a:curDir)
    let l:oDir = s:getRelativeFile(a:outDir)
    if !s:isLinux
        silent execute "!move ". shellescape(l:cDir)." ".shellescape(l:oDir)
    else
        silent execute "!mv ". shellescape(l:cDir)." ".shellescape(l:oDir)
    endif
endfunction
function! s:RemoveDir(d)
    let l:dir = s:getRelativeFile(a:d)
    if !g:vimFiles_AutoConfirmDeleteFolder
        let l:confirm = s:GetInput("Folder ".a:d." and all its contents will be permanently deleted, are you sure you want to continue? (y/n): ")
    else
        let l:confirm = "y"
    endif
    if tolower(l:confirm) == "y" || tolower(l:confirm) == "yes"
        if !s:isLinux
            silent execute "!rmdir /s/q " . shellescape(l:dir)
        else
            silent execute "!rm -rf " . shellescape(l:dir)
        endif
    endif
endfunction
function! s:MoveFile(src, dest)
    call s:RenameFile(a:src, a:dest)
endfunction
function! s:MoveDir(inDir, outDir)
    call s:RenameDir(a:inDir, a:outDir)
endfunction

function! GetCompletionDirTemplates(ArgLead, CmdLine, ...)
    let myList = keys(g:vimFilesThemplatesDir)
    return filter(myList, 'v:val =~ "^'. a:ArgLead .'"')
endfunction
function! GetCompletionFileTemplates(ArgLead, CmdLine, ...)
    let myList = keys(g:vimFilesThemplatesFiles)
    return filter(myList, 'v:val =~ "^'. a:ArgLead .'"')
endfunction

" Module for capture user input
function! s:GetInput(text)
    call inputsave()
    let l:input = input(a:text, '', 'file')
    call inputrestore()
    return l:input
endfunction
" Module for capture user input with custom autocomlpetion
function! s:GetInputTemplate(text, template)
    let l:input = ""
    call inputsave()
    if a:template == 0
        let l:input = input(a:text, '', 'customlist,GetCompletionDirTemplates')
    else
        let l:input = input(a:text, '', 'customlist,GetCompletionFileTemplates')
    endif
    call inputrestore()
    return l:input
endfunction

" Function to create File Path
function! s:CreateFile(filename, openMode)
    if !empty('a:filename')
        let l:name = s:getRelativeFile(a:filename)
        call s:MKDir(fnamemodify(l:name, ':h'), 0)
        if writefile([], l:name) == 0
            call s:OpenNewFileMode(l:name, a:openMode)
        else 
            echoerr "could not create file: ".a:filename
        endif
    endif
endfunction
" Function to open buffer file
function! s:OpenNewFileMode(filename, openMode)
    let l:vimFilesOpenMode = g:vimFilesOpenMode
    if a:openMode != -1
        let g:vimFilesOpenMode = a:openMode
    endif
    if g:vimFilesOpenMode == 0 " tab
        silent execute "tabnew ".a:filename
    endif
    if g:vimFilesOpenMode == 1 " vsplit
        silent execute "vnew ".a:filename
    endif
    if g:vimFilesOpenMode == 2 " hsplit
        silent execute "new ".a:filename
    endif
    if g:vimFilesOpenMode == 3
        silent execute ".bd!|e ".a:filename
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
        let l:content = []
        for line in readfile(l:vimThemplate)
            call add(l:content, s:ReplaceText(line, fnamemodify(a:filename, ':t:r')))
        endfor
        if writefile(l:content, a:filename) == 0
            call s:CreateFile(a:filename, a:openmode)
        else 
            echoerr "could not create file: ".a:filename." with template: ".a:themplate
        endif
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
function! VimFiles#DirCreate() abort
    let l:dir = s:GetInput('Enter Directory Name: ')
    call s:MKDir(l:dir, 0)
endfunction
"
" Create Dirs based on Themplate
function! VimFiles#DirCreateFromTemplate() abort
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 0)
    call s:DirThemplate(l:themplate)
endfunction
"
" ________ Manipulate Dirs ________
"
"
" Rename Dir
"
function! VimFiles#ManipulateRenameDir() abort
    let l:cDir = s:GetInput('Enter Dir to Rename: ')
    let l:dDir = s:GetInput('Enter new Name: ')
    call s:RenameDir(l:cDir, l:dDir)
endfunction
"
" Move Dir
"
function! VimFiles#ManipulateMoveDir() abort
    let l:cDir = s:GetInput('Enter Dir to Move: ')
    let l:dDir = s:GetInput('Enter new relative path: ')
    call s:MoveDir(l:cDir, l:dDir)
endfunction
"
" Delete Dir
"
function! VimFiles#ManipulateDeleteDir() abort
    let l:cDir = s:GetInput('Enter Dir to Delete: ')
    call s:RemoveDir(l:cDir)
endfunction
"
"
" ________ Files Functions ________
"
"
function! VimFiles#FileCreate() abort                       " To create File
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, -1)
endfunction
function! VimFiles#FileCreateTab() abort                    " To create File and Open in new Tab
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 0)
endfunction
function! VimFiles#FileCreateVS() abort                     " To create File and Open in Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 1)
endfunction
function! VimFiles#FileCreateHS() abort                     " To create File and Open in Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 2)
endfunction
function! VimFiles#FileCreateCW() abort                     " To create File and Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 3)
endfunction
"
" ________ Template Functions ________
"
"
" Create Files Based on Template
function! VimFiles#FileTemplateCreate() abort
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 1)
    call s:FileThemplate(l:name, l:themplate, -1)
endfunction
function! VimFiles#FileTemplateCreateTab() abort                  " Open on new Tab
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 1)
    call s:FileThemplate(l:name, l:themplate, 0)
endfunction
function! VimFiles#FileTemplateCreateVS() abort                  " Open on Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 1)
    call s:FileThemplate(l:name, l:themplate, 1)
endfunction
function! VimFiles#FileTemplateCreateHS() abort                  " Open on Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 1)
    call s:FileThemplate(l:name, l:themplate, 2)
endfunction
function! VimFiles#FileTemplateCreateCW() abort                  " Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInputTemplate('Enter themplate Name: ', 1)
    call s:FileThemplate(l:name, l:themplate, 3)
endfunction
"
" ________ Manipulate Files ________
"
"
" Rename Current File
"
function! VimFiles#ManipulateRenameCurrentFile() abort
    let l:newname = s:GetInput('Enter New Name: ')
    call s:RenameFile(expand('%:p'), l:newname)
endfunction
" Rename File
function! VimFiles#ManipulateRenameFile() abort
    let l:oldfile = s:GetInput('Enter the file to rename')
    let l:newname = s:GetInput('Enter New Name: ')
    call s:RenameFile(s:getRelativeFile(l:oldfile), l:newname)
endfunction
"
" Move Current File
"
function! VimFiles#ManipulateMoveCurrentFile() abort
    let l:dfile = s:GetInput('Enter File Destination: ')
    call s:Move(expand('%:p'), l:dfile)
endfunction
" Move another file
function! VimFiles#ManipulateMoveFile() abort
    let l:cfile = s:GetInput('Enter File To Move: ')
    let l:dfile = s:GetInput('Enter File Destination: ')
    call s:Move(s:getRelativeFile(l:cfile), l:dfile)
endfunction
"
" Delete Current File
"
function! VimFiles#ManipulateDeleteCurrentFile() abort
    call s:DeleteFile(expand('%:p'))
endfunction
" Delete another File
function! VimFiles#ManipulateDeleteFile() abort
    let l:filename = s:GetInput('Enter File to Delete: ')
    call s:DeleteFile(l:filename)
endfunction
