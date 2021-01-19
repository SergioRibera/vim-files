if exists('g:nvim-files') | finish | endif

if exists('g:vimFilesThemplatesRootPathFile')
    let g:vimFilesThemplatesRootPathFile = g:vimFilesThemplatesRootPathFile
else
    let g:vimFilesThemplatesRootPathFile = '~/.config/nvim/themplates/files'
endif
if exists('g:vimFilesThemplatesRootPathDir')
    let g:vimFilesThemplatesRootPathDir = g:vimFilesThemplatesRootPathDir
else
    let g:vimFilesThemplatesRootPathDir = '~/.config/nvim/themplates/dirs'
endif

if exists('g:vimFilesThemplatesDir')
    let g:vimFilesThemplatesDir = g:vimFilesThemplatesDir
else
    let g:vimFilesThemplatesDir = { }
endif

if exists('g:vimFilesThemplatesFiles')
    let g:vimFilesThemplatesFiles = g:vimFilesThemplatesFiles
else
    let g:vimFilesThemplatesFiles = { }
endif

if exists('g:vimFilesOpenMode')
    let g:vimFilesOpenMode = g:vimFilesOpenMode
else
    let g:vimFilesOpenMode = 0
endif

function! s:MKDir(...) abort
    if isdirectory(a:1)
        if a:2 =~# 1
            echoerr "The input is not directory"
        endif
        return
    endif
    call mkdir(fnamemodify(a:1, ':p'), "p")
endfunction

function! VimFiles#CreateDir() abort
    call inputsave()
    let l:dir = input('Enter Directory Name: ')
    call inputrestore()
    call s:MKDir(l:dir, 1)
endfunction

function! VimFiles#CreateFile() abort
    call inputsave()
    let l:name = input('Enter File Name: ')
    call inputrestore()
    call s:CreateFile(l:name)
endfunction

function! VimFiles#CreateDirThemplate() abort
    call inputsave()
    let l:themplate = input('Enter themplate Name: ')
    call inputrestore()
    call s:MKDir(g:vimFilesThemplatesRootPathDir, 0)

    if has_key(g:vimFilesThemplatesDir, l:themplate)
        let l:vimThemplateFile = fnamemodify(g:vimFilesThemplatesRootPathDir . '/' . g:vimFilesThemplatesDir[l:themplate], ':p')
        for line in readfile(l:vimThemplateFile)
            let l:vimThemplate = fnamemodify(getcwd(). '/' . line, ':p')
            call s:MKDir(l:vimThemplate, 0)
        endfor
    else
        echoerr "Not found Themplate name"
        return
    endif

endfunction

function! VimFiles#CreateFileThemplate() abort
    call inputsave()
    let l:name = input('Enter File Name: ')
    call inputrestore()
    call inputsave()
    let l:themplate = input('Enter themplate Name: ')
    call inputrestore()
    call s:MKDir(g:vimFilesThemplatesRootPathFile, 0)

    if has_key(g:vimFilesThemplatesFiles, l:themplate)
        let l:vimThemplate = fnamemodify(g:vimFilesThemplatesRootPathFile . '/' . g:vimFilesThemplatesFiles[l:themplate], ':p')
        let l:content = ''
        for line in readfile(l:vimThemplate)
            let l:content .= s:ReplaceText(line, fnamemodify(l:name, ':t:r')) . "\x0a"
        endfor
        call s:CreateFile(l:name)
        put! = l:content
    else
        echoerr "Not found Themplate name"
        return
    endif
endfunction

function! s:CreateFile(filename)
    let l:name = getcwd().'/'.a:filename
    let l:name = fnamemodify(l:name, ':p')
    call s:MKDir(fnamemodify(l:name, ':h'), 1)
    call s:OpenNewFileMode(l:name)
endfunction

function! s:OpenNewFileMode(filename)
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
endfunction
function! s:ReplaceText(text, filename)
    return substitute(a:text, "#FILENAME#", a:filename, "")
endfunction
