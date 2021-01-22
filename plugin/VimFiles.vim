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
" Use Correct Separator
function! s:separator()
  return !exists('+shellslash') || &shellslash ? '/' : '\\'
endfunction
" Rename File
function! s:RenameFile(curfile, name)
    let l:curfile = a:curfile
    let l:curfilepath = expand("%:p:h")
    let l:newname = l:curfilepath . "/" . a:name
    let v:errmsg = ""
    silent! exe "saveas " . l:newname
    if v:errmsg =~# '^$\|^E329'
        if expand("%:p") !=# l:curfile && filewritable(expand("%:p"))
            silent exe "bwipe! " . l:curfile
            if delete(l:curfile)
                echoerr "Could not delete " . l:curfile
            endif
        endif
    else
        echoerr v:errmsg
    endif
endfunction
function! s:DeleteFile(f)
    delete(a:f)
    if !bufloaded(s:file)
        echoerr 'Failed to delete "'.a:f.'"'
    endif
endfunction
function! s:RemoveDir(d)
endfunction
function! s:Move(src, dest)
    let s:src = expand(a:src)
    let s:dst = expand(a:dest)
    if s:fcall('isdirectory', s:dst) || s:dst[-1:-1] =~# '[\\/]'
        let s:dst .= (s:dst[-1:-1] =~# '[\\/]' ? '' : s:separator()) . fnamemodify(s:src, ':t')
    endif
    call s:MKDir(fnamemodify(s:dst, ':h'))
    let s:dst = substitute(s:fcall('simplify', s:dst), '^\.\'.s:separator(), '', '')
    if s:fcall('filereadable', s:dst)
      exe 'keepalt saveas '.s:fnameescape(s:dst)
    elseif s:fcall('filereadable', s:src) && EunuchRename(s:src, s:dst)
      echoerr 'Failed to rename "'.s:src.'" to "'.s:dst.'"'
    else
      setlocal modified
      exe 'keepalt saveas! '.s:fnameescape(s:dst)
      if s:src !=# expand('%:p')
        execute 'bwipe '.s:fnameescape(s:src)
      endif
      filetype detect
    endif
    unlet s:src
    unlet s:dst
    filetype detect
endfunction
" Module for capture user input
function! s:GetInput(text)
    call inputsave()
    let l:input = input(a:text, expand('%'), 'file')
    call inputrestore()
    return l:input
endfunction

" Function to create File Path
function! s:CreateFile(filename, openMode)
    if !empty('a:filename')
        let l:name = getcwd().s:separator().a:filename
        let l:name = fnamemodify(l:name, ':p')
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
    return substitute(a:text, "#FILENAME#", a:filename, "")
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
" ________ Simple Functions ________
"
"
function! VimFiles#CreateDir() abort                        " To create Dir
    let l:dir = s:GetInput('Enter Directory Name: ')
    call s:MKDir(l:dir, 0)
endfunction
function! VimFiles#CreateFile() abort                       " To create File
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, -1)
endfunction
function! VimFiles#CreateFileTab() abort                    " To create File and Open in new Tab
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 0)
endfunction
function! VimFiles#CreateFileVS() abort                     " To create File and Open in Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 1)
endfunction
function! VimFiles#CreateFileHS() abort                     " To create File and Open in Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 2)
endfunction
function! VimFiles#CreateFileCW() abort                     " To create File and Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    call s:CreateFile(l:name, 3)
endfunction
"
" ________ Themplate Functions ________
"
"
" Create Dirs based on Themplate
function! VimFiles#CreateDirThemplate() abort
    let l:themplate = input('Enter themplate Name: ')
    call s:DirThemplate(l:themplate)
endfunction
" Create Files Based on Themplate
function! VimFiles#CreateFileThemplate() abort
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, -1)
endfunction
function! VimFiles#CreateFileThemplateTab() abort                  " Open on new Tab
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 0)
endfunction
function! VimFiles#CreateFileThemplateVS() abort                  " Open on Vertical Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 1)
endfunction
function! VimFiles#CreateFileThemplateHS() abort                  " Open on Horizontal Split
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 2)
endfunction
function! VimFiles#CreateFileThemplateCW() abort                  " Open in current windows
    let l:name = s:GetInput('Enter File Name: ')
    let l:themplate = s:GetInput('Enter themplate Name: ')
    call s:FileThemplate(l:name, l:themplate, 3)
endfunction
"
" ________ Manipulate Files ________
"
"
" Rename File
function! VimFiles#RenameCurrentFile() abort
    let l:newname = s:GetInput('Enter New Name: ')
    call s:RenameFile(expand('%:p'), l:newname)
endfunction

function! VimFiles#DeleteFile() abort
    let l:filename = s:GetInput('Enter Directory to Delete: ')
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
