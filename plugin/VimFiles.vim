if exists('g:nvim-files') | finish | endif

if exists('g:vimFilesThemplates')
    let g:vimFilesThemplates = g:vimFilesThemplates
else
    let g:vimFilesThemplates = []
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
    let l:name = getcwd().'/'.l:name
    let l:name = fnamemodify(l:name, ':p')
    call s:MKDir(fnamemodify(l:name, ':h'), 1)
    call s:OpenNewFileMode(l:name)
endfunction

function! VimFiles#CreateFileWhereThemplate() abort
    call inputsave()
    let name = input('Enter File Name: ')
    call inputrestore()
    call inputsave()
    let themplate = input('Enter themplate Name: ')
    call inputrestore()
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
