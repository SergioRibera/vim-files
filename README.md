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
|        Name        | Default Value |                                                                                                                                  Description                                                                                                                                 |
|:------------------:|:-------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| g:vimFilesOpenMode |       0       | This variable allows you to indicate which will be the opening method for the created file, being: `0` to open it in a Tab, `1` to open in vertical split, `2` to open in horizontal split, `3`  to open it in the current window and `4` so as not to open it automatically |
### Functions
|          Name         |                                                                                                                  Description                                                                                                                 |
|:---------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|  VimFiles#CreateDir() |                                                                                  This function recursively creates directories relative to the current path                                                                                  |
| VimFiles#CreateFile() | This variable indicates if the newly created file should This function creates a file in the directory indicated with the name and extension specified in the same input, below there are examples saved as soon as its creation is finished |

### Examples
With vim open in the path `~/Projects/test`, I call the `VimFiles#CreateDir()` function, and enter `python/component`, the result is that now I have this complete path `~/Projects/test/python/component`

With vim open in the path `~/Projects/test`, I call the `VimFiles#CreateFile()` function, and enter `python/view/User.py`, the result is that now the file is created and also opened, if not have the necessary folders created, the function will create them automatically and recursively

### Example Configurations
``` Vim
noremap <leader>cd :call VimFiles#CreateDir()<Cr>
noremap <leader>cf :call VimFiles#CreateFile()<Cr>
```
### **Please report all bugs and problems**
Thanks for install this tool, for see more visit [my web](https://sergioribera.com) (Very soon I will add an app store)
## Donate
[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Q5Q321D62)
[![](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/SergioRibera)
[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/SergioRibera)

#### Made with the ❤️ by [SergioRibera](https://sergioribera.com)
