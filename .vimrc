""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Vim main config
" by Sergey Yakovlev (me@klay.me)
" https://github.com/sergeyklay/
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on      " filetype dependent indenting and plugins

set nocompatible               " use Vim settings, rather then Vi settings
set modelines=0                " prevents some security holes
set backup                     " create backup files
set bdir=~/.vim/back,/tmp      " directory to save backup files
set history=1000               " cmdline history table size
set ruler                      " show line and column in status line
set incsearch                  " live search while typing search expression
set nohls                      " no highlighting when performing search
set ignorecase                 " search is case insensitive
set smartcase                  " if search pattern contains an uppercase letter
                               " it is case sensitive, otherwise, it is not
set gdefault                   " lets skip the ending '/g' in keystrokes
set ai                         " indents line relative to the line above it
set ttyfast                    " for fast terminals - smoother (apparently)
set novb                       " beeping instead of flashing
set showmatch                  " indicate matching parentheses, braces etc
set shortmess=a                " abbreviate file messages
" status line settings
set stl=%t\ %{strftime(\"%H:%M\ \")}%(%l,%c\ %p%%%)\ %y%m%r[%{&fileencoding}]
set nowrap                     " don't wrap visible lines
set ts=4                       " tab defaults to 4 spaces
set shiftwidth=4               " number of spaces used for (auto)indent
set expandtab                  " when inserting replace tabs with spaces
set softtabstop=4              " tab defaults to 4 spaces while performing
                               " editing operations
set t_Co=256                   " enable 256 colors support
set wildmenu                   " enhanced cmdline completion
set wildchar=<Tab>             " type tab in cmdline to start wildcard expansion
set wildmode=longest:full,full " cmdline completion mode settings
set makeprg=make               " application for build - make
set whichwrap=<,>,[,],h,l      " allow line-wrapped navigation
set encoding=utf-8             " encoding
set fencs=utf8,cp1251,koi8r,cp866 " possible encodings of files
set showcmd                    " show partial command in status line
set showmode                   " show whether in insert, visual mode etc
set noacd                      " current directory - where is the active file
set tpm=100                    " maximum number of tab pages to be opened
set ar                         " reload file if it has changed externally
set dir=~/.vim/swapfiles,/tmp  " directory to save the swap files
set undofile                   " create undofile
set undodir=~/.vim/undo,/tmp   " directory to save the rollback files
set undolevels=1000            " amount of possible undo
set ex                         " use .vimrc from current dir
" insert mode completion options
set cot=menu,menuone,longest,preview
set list                       " display the tabs, and leading spaces
set lcs=tab:»\ ,trail:·,eol:¶  " how to display non-printing characters
set autowrite                  " automatically write contents of file
                               " where sensible
set tw=80                      " maximum column width of inserted text
                               " longer lines are broken after whitespace
set cc=+1                      " highlight border for tw
set nohidden                   " when closing tab, remove the buffer
set laststatus=2               " always display the status line
set backspace=indent,eol,start " allow backspacing over evrything in insert mode
set shell=/bin/bash            " set the shell to be used
set formatoptions=qrn1         " correctly handle long lines
set cursorline                 " display cursor line
set complete=.,t,i,b,w,k       " keyword completion configuration
set scrolloff=3                " minimal number of screen to keep above
                               " and below the cursor
set number                     " show line numbers

" pathogen
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
" generate heltags for everything in 'rintimepath'
call pathogen#helptags()

" save on loss of focus
au FocusLost * :wa

" more complete information when pressing <C-g>
map <C-g> g<C-g>
" save sesson to file
map <C-k> :mks! ~/.vim/session/sess.vim<CR>
" restore sesion from file
map <C-l> :so ~/.vim/session/sess.vim<CR>
" Map a specific shortcut to open NERDTree
map <C-n> :NERDTreeToggle<CR>
" that will list file names in the current directory
map <F2> :e <C-d>

" if terminal's color count > 2
if &t_Co > 2
   " enable syntax highlighting and override current colour settings
   syntax on
endif

" if using gvim
if has('gui_running')
    " nothing
" if we're in a linux console
elseif (&term == 'screen.linux') || (&term =~ '^linux')
    " use 8 bit colour
    set t_Co=8
    " set color scheme
    colors desert
" if we're in xterm, urxvt or screen with 256 colours
elseif (&term == 'rxvt-unicode') || (&term =~ '^xterm') || (&term =~ '^screen-256')
    " allow mouse in all editing modes
    set mouse=a
    " use xterm mouse behaviour
    set ttymouse=xterm
    " set encoding to uft-8
    set termencoding=utf-8
    " set color scheme
    colors desert256-transparent
" if we're in a different terminal
else
    " set color scheme
    colors desert
endif

" ; the same as :
nnoremap ; :

""""""""""""" autocommand stuff """""""""""

" only do this part when compiled with support for autocommands
if has("autocmd")
  " put these in an autocmd group, so that we can delete them easily
  augroup vimrcEx
    au!

    " open a NERDTree automatically
    " when vim starts up if no files were specified
    autocmd vimenter * if !argc() | NERDTree | endif

    " for all text files set 'textwidth' to 78 characters
    autocmd FileType text setlocal textwidth=78
    " for all C files set 'textwidth' to 78 characters.
    autocmd bufreadpre *.c setlocal textwidth=78
    " some settings for php
    autocmd FileType php  setlocal makeprg=zca\ %<.php
    autocmd FileType php  setlocal errorformat=%f(line\ %l):\ %m

    " when editing a file, always jump to the last known cursor position
    " don't do it when the position is invalid or when inside an event handler
    autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
  augroup END
else

endif

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" using templates for new files.
" in order for plugin was able to find a specific template,
" files must be named template.*, and should be located in
" ~/.vim/template directory
augroup template-plugin
  autocmd User plugin-template-loaded call s:template_keywords()
augroup END

function! s:template_keywords()
  " file name
  if search('<+FILE_NAME+>')
    silent %s/<+FILE_NAME+>/\=toupper(expand('%:t:r'))/g
  endif
  " cursor position
  if search('<+CURSOR+>')
    execute 'normal! "_da>'
  endif
  " current date
  silent %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
endfunction
