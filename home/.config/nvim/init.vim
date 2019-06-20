""" uses vim-plug https://github.com/junegunn/vim-plug  
call plug#begin()
Plug 'jnurmine/zenburn'
Plug 'lervag/vimtex'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdtree'
"Plug 'jiangmiao/auto-pairs'
"Plug 'Raimondi/delimitMate'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
Plug 'reedes/vim-wordy'

" Hyperfocus writing
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" Writing

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
call plug#end()

"" Visual
colors zenburn
syntax on

""" Spelling + encoding
set encoding=utf-8
set spell spelllang=en_gb

" Tabs
set tabstop=2
set shiftwidth=2
set expandtab

""" Always switch to the current file's directory
set autochdir

""" Mouse integration
set mouse=a
"set clipboard+=unnamed
"vnoremap <LeftRelease> "*ygv<LeftRelease>
"noremap <S-Insert> "*p

""" Tab
noremap <C-TAB> <Esc>:tabnext<CR>
noremap <C-S-TAB> <Esc>:tabprev<CR>
"noremap <A-TAB> ]}a
"inoremap <A-TAB> <Esc>]}a

noremap <A-Tab> /\(\$\\|)\\|}\)<CR><Esc>:noh<CR>a
inoremap <A-Tab> <Esc>/\(\$\\|)\\|}\)<CR>:noh<CR>a


""" NERDtree
let g:NERDTreeQuitOnOpen = 1


""" autoPairs
let g:AutoPairsMapCR = 0

""" move line by line in indented text
noremap <up> gk
noremap <down> gj
inoremap <up> <C-o>gk
inoremap <down> <C-o>gj
map <Home> g0
map <End> g$
imap <Home> <C-o>g0
imap <End> <C-o>g$

""" airline
"let g:airline_powerline_fonts = 1
"let g:airline_theme = 'angr'

""" completion	
let g:deoplete#enable_at_startup = 1
let g:deoplete#max_menu_width = 0 " Don't cut off completion popdpdown

inoremap <expr><BS>  deoplete#smart_close_popup()."\<C-h>"

map <F8> :NERDTreeToggle<CR>
map <F1> :Goyo<CR>
imap <F1> <C-o>:Goyo<CR>

""" ultisnips
let g:UltiSnipsSnippetDirectories=["UltiSnips", "snips"]

let g:SuperTabDefaultCompletionType = "<c-n>"

let g:UltiSnipsExpandTrigger="<TAB>"
let g:UltiSnipsListSnippets="<>"
let g:UltiSnipsJumpForwardTrigger="<A-TAB>"
let g:UltiSnipsJumpBackwardTrigger="<A-S-TAB>"

inoremap <silent><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr> <down> ((pumvisible())?("\<C-n>"):("\<down>"))
"inoremap <expr> <up> ((pumvisible())?("\<C-p>"):("\<up>"))




""" tag browsing
nnoremap ü <C-]>
nnoremap Ü <C-O>


""" vimtex
let g:tex_flavor = "latex"
set iskeyword+=:
set grepprg=grep\ -nH\ $*
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_method = 'pplatex'
"let g:vimtex_quickfix_method = 'latexlog'
let g:vimtex_quickfix_fix_paths = 1
let g:vimtex_indent_enabled = 0
let g:vimtex_compiler_progname = 'nvr'

if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif
let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete

nmap <localleader>ls <plug>(vimtex-compile-ss)

""" Dict + thesaurus

let g:online_thesaurus_map_keys = 0
nnoremap <localleader>d :DictCur<CR>
nnoremap <localleader>t :OnlineThesaurusCurrentWord<CR>

""" Override default options to add bibtex compilation
"let g:vimtex_latexmk_options = "-pdf -bibtex -verbose -synctex=1 -interaction=nonstopmode"

""" Indent und wordwrap, linenumbers
""" set smartindent
" set autoindent
" set showbreak=...\ \ \ \ \ \ \ \ 
" set wrap lbr 
"let breakindentopt = 'sbr,shift:2'
set autoindent
set formatoptions=l
set lbr
set breakindent
set number


""" Goyo
function! s:goyo_enter()
  if has('gui_running')
    set fullscreen
"    set background=light
    set guifont=DejaVu\ Sans\ Mono\ 11
    set linespace=3
    set go-=m
    set go-=T
  elseif exists('$TMUX')
    silent !tmux set status off
  endif
endfunction

function! s:goyo_leave()
  if has('gui_running')
    set nofullscreen
"    set background=dark
    set guifont=DejaVu\ Sans\ Mono\ 10
    set linespace=0
    set go+=m
    set go+=T
  elseif exists('$TMUX')
    silent !tmux set status on
  endif
endfunction

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Swapfiles in system dir
set dir=/var/tmp/
set exrc
