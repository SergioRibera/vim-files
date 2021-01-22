# Vim-Files
This is a simple plugin to create directories and files from vim, and even using templates
## Installation
Plug:
``` Vim
Plug 'SergioRibera/vim-files'
```
The other way would be cloning the repository.
## Instructions
### Variables
|               Name               |           Default Value           |                                                                                                                                  Description                                                                                                                                 |
|:--------------------------------:|:---------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|        g:vimFilesOpenMode        |                 0                 | This variable allows you to indicate which will be the opening method for the created file, being: `0` to open it in a Tab, `1` to open in vertical split, `2` to open in horizontal split, `3`  to open it in the current window and `4` so as not to open it automatically |
| g:vimFilesThemplatesRootPathFile | '~/.config/nvim/themplates/files' | This variable indicates the path in which the file templates must be searched                                                                                                                                                                                                |
| g:vimFilesThemplatesRootPathDir  | '~/.config/nvim/themplates/dirs'  | This variable indicates the path in which the folder structure templates should be searched.                                                                                                                                                                                 |
| g:vimFilesThemplatesDir          | { }                               | This variable is a dictionary, which contains the name of the template and its file, which will contain, separated by lines, the directories to be created, example: {'react': 'react / native.txt'}                                                                         |
| g:vimFilesThemplatesFiles        | { }                               | This variable is a dictionary, which contains the name of the template and its file, example: {'py-comp': 'python / component.txt'}                                                                                                                                          |
### Functions
| Name                                                                                                                                                                                                                                                                                                                                  | Description                                                                                                                                                                         |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| VimFiles#DirCreate()                                                                                                                                                                                                                                                                                                                  | This function recursively creates directories relative to the current path.                                                                                                         |
| VimFiles#DirCreateFromTemplate()                                                                                                                                                                                                                                                                                                      | This function creates the directories specified in the template with the name specified in the input, thus building a file structure within the working path.                       |
| VimFiles#FileCreate()                                                                                                                                                                                                                                                                                                                 | This function creates a file in the directory indicated with the name and extension specified in the same input, below there are examples saved as soon as its creation is finished |
| ```<br>VimFiles#FileCreateTab()             " Open the new file in a new tab<br>VimFiles#FileCreateVS()              " Open the new file in a vertical split<br>VimFiles#FileCreateHS()              " Open the new file in a horizontal split<br>VimFiles#FileCreateCW()              " Open the new file in the current window      | These functions do the same but open the file differently, as if the variable `g:vimFilesOpenMode` were changed                                                                     |
| VimFiles#FileTemplateCreate()                                                                                                                                                                                                                                                                                                         | this function creates the specified file, just like the previous function, with the difference that it fills the file with the text containing the indicated template               |
| VimFiles#FileTemplateCreateTab()        " Open the new file in a new tab<br>VimFiles#FileTemplateCreateVS()         " Open the new file in a vertical split<br>VimFiles#FileTemplateCreateHS()         " Open the new file in a horizontal split<br>VimFiles#FileTemplateCreateCW()         " Open the new file in the current window | These functions do the same but open the file differently, as if the variable `g:vimFilesOpenMode` were changed                                                                     |
| VimFiles#ManipulateRenameCurrentFile()                                                                                                                                                                                                                                                                                                | This function renames the currently focused file and will create the required directories.                                                                                          |
| VimFiles#ManipulateRenameFile()                                                                                                                                                                                                                                                                                                       | This function renames the file with the path indicated and create the necessary directories.                                                                                        |
| VimFiles#ManipulateMoveCurrentFile()                                                                                                                                                                                                                                                                                                  | This function will move the focused file to the path indicated later and will create the necessary directories.                                                                     |
| VimFiles#ManipulateMoveFile()                                                                                                                                                                                                                                                                                                         | This function will move the file that is indicated to the path that is indicated later and will create the directories that are needed.                                             |
| VimFiles#ManipulateDeleteCurrentFile()                                                                                                                                                                                                                                                                                                | This function removes the focused file.                                                                                                                                             |
| VimFiles#ManipulateDeleteFile()                                                                                                                                                                                                                                                                                                       | This function deletes the file indicated.<br>*Note: do not delete the directory at any time or under any circumstances.*                                                            |
### Examples
With vim open in the path `~/Projects/test`, I call the `VimFiles#CreateDir()` function, and enter `python/component`, the result is that now I have this complete path `~/Projects/test/python/component`
<br/><br/>
![Graphical Explication Directory Create](https://raw.githubusercontent.com/SergioRibera/vim-files/main/doc/dir.gif)
<br/><br/>
With vim open in the path `~/Projects/test`, I call the `VimFiles#CreateFile()` function, and enter `python/view/User.py`, the result is that now the file is created and also opened, if not have the necessary folders created, the function will create them automatically and recursively
<br/><br/>
![Graphical Explication File Create](https://raw.githubusercontent.com/SergioRibera/vim-files/main/doc/file.gif)
### Example Configurations
``` Vim
" Dictioinary of Dir Themplates
let g:vimFilesThemplatesDir = {
    \ 'react-native': 'react/native.txt',
    \ 'html-bootstrap': 'web/html/bootstrap.txt'
    \}
" Dictionary of Files Themplates
let g:vimFilesThemplatesFiles = {
    \ 'react-component': 'react/component.txt'
    \}

" Simple Created Relative Directory
noremap <leader>cd :call VimFiles#CreateDir()<Cr>
" Simple Created Relative File
noremap <leader>cf :call VimFiles#CreateFile()<Cr>
" Create Directories based in themplate
noremap <leader>cdd :call VimFiles#CreateDirThemplate()<Cr>
" Create File based in themplate
noremap <leader>cff :call VimFiles#CreateFileThemplate()<Cr>
```
### **Please report all bugs and problems**
Thanks for install this tool, for see more visit [my web](https://sergioribera.com) (Very soon I will add an app store)
## Donate
[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Q5Q321D62)
[![](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/SergioRibera)
[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/SergioRibera)

#### Made with the ❤️ by [SergioRibera](https://sergioribera.com)
