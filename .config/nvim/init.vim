call plug#begin('~/.config/nvim/plugged')
    Plug 'https://github.com/jiangmiao/auto-pairs'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'junegunn/fzf.vim'
    Plug 'gruvbox-community/gruvbox'
    Plug 'phaazon/hop.nvim'
    Plug 'szw/vim-maximizer'
    Plug 'mattn/emmet-vim'
"     Plug 'octol/vim-cpp-enhanced-highlight'
"     Plug 'puremourning/vimspector'
call plug#end()

let g:codesdir=$HOME . "/Codes/X"
filetype off
filetype plugin indent on

"Colors for nonprogramming or config files
colo gruvbox
let ftToIgnore = ['cpp', 'python', 'java']
autocmd VimEnter * if index(ftToIgnore, &ft) < 0  | call Defaultcolor()

hi CursorLineNr guibg=none
hi VertSplit cterm=none gui=none guibg=none
hi Search guibg=none guifg=#8d93a1 gui=underline
hi snipLeadingSpaces guifg=bg


autocmd FileType * setlocal formatoptions-=cro

set wildmenu
set path+=**
set hidden
set scrolloff=8

" set shell=/usr/bin/fish
set mouse=a
set nu rnu
" set cursorline
set guicursor=
set termguicolors

set ignorecase
set smartcase

set statusline=\ %M\ %r\ %f 
set statusline+=%=
set statusline+=\ [%{getcwd()}]\ [%n]\ %p%%

set tabstop=4
set shiftwidth=4
set expandtab
set smartindent

set splitbelow splitright
set noequalalways
set shell=zsh

" autoreload file if its changed
autocmd Focusgained * checktime

" Clears highlighting after these commands
for s:c in ['a', 'A', '<Insert>', 'i', 'I', 'gI', 'gi', 'o', 'O', '<Esc>']
    exe 'nnoremap <silent>' . s:c . ' :noh<CR>' . s:c
endfor

"Keymapings

"Copying and Cutting to the system clipboard
vmap <C-c> "+y
vmap <C-x> <C-c>gvd

let mapleader=','
tnoremap <Leader><Esc> <C-\><C-n>
" tnoremap <Esc> <C-\><C-n>

"move between windows
map <C-l> <C-w>l
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k

map <Leader>Q :qa!<CR>
map <Leader>q :q!<CR>
map <Leader>w :w!<CR>
map <Leader>W :wq!<CR>

"Ctrl-Alt-k/j move current line up and down
nnoremap <C-A-j> :m .+1<CR>==
nnoremap <C-A-k> :m .-2<CR>==
inoremap <C-A-j> <Esc>:m .+1<CR>==gi
inoremap <C-A-k> <Esc>:m .-2<CR>==gi
vnoremap <C-A-j> :m '>+1<CR>gv=gv
vnoremap <C-A-k> :m '<-2<CR>gv=gv


let &winminwidth=0
let &winminheight=0

let g:MainWindowSize = 76

fu Ftog()
    if winwidth(0) > g:MainWindowSize
        exe "vert res" . g:MainWindowSize  | hi VertSplit guifg=#444444
    else
        vert res 200 | hi VertSplit guifg=bg
    endif
endfu
hi VertSplit guifg=bg

map <silent> <A-f> :MaximizerToggle <CR>
map <silent> <A-\> :call Ftog()<CR>


snoremap ;; <C-j>

map <silent> <F5> :exe "set ft=".&ft <CR>

map<silent> <Leader>ii gg=G<C-o>

fu! SetIO()
    exe ":vs".g:codesdir."/Input.txt"|exe ":sp".g:codesdir."/Output.txt"
endfu

map <silent> <Leader>io :call SetIO()<CR><C-h><A-\>


" Language Server
function EnableLanguageServer()
    call coc#config(g:LanguageServerEnablerKey,1) | CocRestart
endfunction

map <F8> :call EnableLanguageServer()<CR>

map <Leader>tl :call CocAction('toggleService', g:LanguageServerName)<CR>
map <Leader>td :call CocAction('diagnosticToggle', g:LanguageServerName)<CR>


" Hop
hi HopNextKey1 guifg=Cyan
hi HopNextKey2 guifg=LightBlue
hi HopNextKey guifg=Violet

map <Leader><Leader> <CMD>HopWord<CR>
map <Leader>j <CMD>HopChar1<CR>


"Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
" let g:user_emmet_leader_key='<A-.>'

" Copy/Paste Output/Input
fu UpdateInput()
    exe "silent !xclip -o -sel clip > " . g:codesdir . "/Input.txt"
endfu

fu CopyOutput()
    exe "silent !xclip -sel clip " . g:codesdir . "/Output.txt"
endfu

map<silent><F4> :call UpdateInput() <CR>
map<silent><F3> :call CopyOutput() <CR>



" Generic Compilation
fu! Compile_Generic(...)
    exe "w"
    
    cd `=g:codesdir`

    exe g:compile_cur_file
    
    if v:shell_error != 0
        cd -
        return
    endif


    if a:0 == 0
        exe g:run_program . "<Input.txt &> Output.txt"
    elseif a:1 == 0
        exe g:run_program . "<Input.txt > Output.txt"
    elseif a:1 == 1
        exe g:run_program_in_term
    elseif a:1 == 2
        exe g:run_program . "<Input.txt"
    elseif a:1 == 3
        exe g:run_program . "<Input.txt >> Output.txt"
    endif
    
    if index( [124,125,137], v:shell_error ) >= 0
        silent exe "!echo 'TLE' > Output.txt"
    endif
    cd -
endfu

"IO
imap <F12> <Esc> :call Compile_Generic(0) <CR>
map <F12> :call Compile_Generic(0) <CR>

"Input Only
imap<F9> <Esc> :call Compile_Generic(2) <CR>
map <F9> :call Compile_Generic(2) <CR>


