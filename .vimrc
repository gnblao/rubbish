" set runtimepath=/home/work/.vim/
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2008 Dec 17
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

""""""""""""""""""""""""""""""""
" del by ripwu
""""""""""""""""""""""""""""""""
"if has("vms")
  "set nobackup		" do not keep a backup file, use versions instead
"else
  "set backup		" keep a backup file
"endif

set history=4096 " keep 4096 lines of command line history
set ruler		 " show the cursor position all the time
set showcmd		 " display incomplete commands
set incsearch	 " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions=substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

  " Customisations based on house-style (arbitrary)
  autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab
  autocmd FileType javascript setlocal ts=4 sts=4 sw=4 noexpandtab

  " Treat .rss files as XML
  autocmd BufNewFile,BufRead *.rss setfiletype xml

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""                                                hacked by ripwu from 2010/7/19                                              ''
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set nu
syntax enable
syntax on
set nocp         " non vi compatible mode
set autoindent
set smartindent
set shiftwidth=4
set incsearch    " incremental search
set nobackup     " no *~ backup files
set copyindent   " copy the previous indentation on autoindenting
set ignorecase   " ignore case when searching
set smartcase    " ignore case if search pattern is all lowercase, case-sensitive otherwise
set showmatch    " highlight matched (
set noerrorbells " close error bell
set novisualbell
set t_vb=        " close visual bell
filetype plugin on
filetype plugin indent on

""""""""""""""""""""""""""""""
"" tab setting
""""""""""""""""""""""""""""""
set tabstop=4    " set tab length=4space
set expandtab    " replace <Tab> with spaces, if want to insert a real tab, use Ctrl-V<Tab>
set smarttab     " insert tabs on the start of a line according to context
set softtabstop=4
set shiftwidth=4

au FileType Makefile set noexpandtab

""""""""""""""""""""""""""""""
"" colorscheme
""""""""""""""""""""""""""""""
" I really love my own color scheme
" enable terminal 256 num colors 
set t_Co=256
if has("win32")
	colorscheme desertEx
else
	" colorscheme rip
	colorscheme desertExCTerm 
endif

""""""""""""""""""""""""""""""
"" session
""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
"" Show syntax highlighting groups for word under cursor by pressing <C-S-P>
""""""""""""""""""""""""""""""
" remember to install this script with :so %
" nmap <C-S-P> :call <SID>SynStack()<CR>
" function! <SID>SynStack()
"    if !exists("*synstack")
"    	  return
"    endif
"    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
" endfunc

""""""""""""""""""""""""""""""
"" ctags
""""""""""""""""""""""""""""""
if has("win32")
    set tags+=E:\workspace\linux\tags  " tags for /usr/include/ (copy /usr/include/ to E:\workspace\linux\usr\include\ then build the tags :-)
else
    set tags+=~/.vim/linux_tags " tags for /usr/include/
endif
set tags+=tags                         " tags for current project

" :[count]tn[ext]                  " jump to [count] next matching tag (default 1)
" :[count]tp[revious]              " jump to [count] previous matching tag (default 1)
" :ts[elect][ident]                " list the tags that match [ident]
" :sts[elect][ident]               " does :tselect[!] [ident] and splits the window for the selected tag

" <C-]>       " go to definition
" <C-T>       " Jump back from the definition.
" <C-W><C-]>  " Open the definition in a horizontal split

" Open the definition in a new tab
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" Open the definition in a vertical split
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

""""""""""""""""""""""""""""""
"" Tag list (ctags)
""""""""""""""""""""""""""""""
"map <C-l> :Tlist<CR>
if has("win32")
    let Tlist_Ctags_Cmd='ctags'             " set ctags path
else
    let Tlist_Ctags_Cmd='ctags'             " set ctags path
endif
let Tlist_Show_One_File=1               " only show current file's taglist
let Tlist_Exit_OnlyWindow=1             " if taglist is of the last windows, exit vim
let Tlist_Use_Right_Window=1            " show taglist at right
let Tlist_File_Fold_Auto_Close=1        " hide taglist if it's not for current file

""""""""""""""""""""""""""""""
"" Supertab.vim
""""""""""""""""""""""""""""""
let g:SuperTabRetainCOmpletionType=2    " 2: remember last autocomplete type, unless I use ESC to exit insert mode
let g:SuperTabDefaultCompletionType="<C-X><C-O>"

""""""""""""""""""""""""""""""
"" Omnicppcomplete
""""""""""""""""""""""""""""""
" :help omnicppcomplete
set completeopt=longest,menu      " I really HATE the preview window!!!
let OmniCpp_NameSpaceSearch=1     " 0: namespaces disabled
                                  " 1: search namespaces in the current buffer [default]
                                  " 2: search namespaces in the current buffer and in included files
let OmniCpp_GlobalScopeSearch=1   " 0: disabled 1:enabled
let OmniCpp_ShowAccess=1          " 1: show access
let OmniCpp_ShowPrototypeInAbbr=1 " 1: display prototype in abbreviation
let OmniCpp_MayCompleteArrow=1    " autocomplete after ->
let OmniCpp_MayCompleteDot=1      " autocomplete after .
let OmniCpp_MayCompleteScope=1    " autocomplete after ::
let OmniCpp_DefaultNamespaces=["std", "GLIBCXX_STD"]

" autocmd FileType python set omnifunc=pythoncomplete#Complete
" autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
" autocmd FileType css set omnifunc=csscomplete#CompleteCSS
" autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
" autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

""""""""""""""""""""""""""""""
"" BufExplorer
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize=30    " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
autocmd BufWinEnter \[Buf\ List\] setl nonumber

""""""""""""""""""""""""""""""
"" winManager setting
""""""""""""""""""""""""""""""
"let g:winManagerWindowLayout="BufExplorer,FileExplorer|TagList"
let g:winManagerWindowLayout="FileExplorer|TagList"
let g:winManagerWidth=30
let g:defaultExplorer=0
nmap <silent> <leader>fir :FirstExplorerWindow<CR>
nmap <silent> <leader>bot :BottomExplorerWindow<CR>
nmap <F8> :WMToggle<CR>

""""""""""""""""""""""""""""""
"" NERDTree setting (not used cause vim-nerdtree-tabs.vim is more powerful)
""""""""""""""""""""""""""""""
" let NERDTreeWinPos="left" " where NERD tree window is placed on the screen
" let NERDTreeWinSize=28    " size of the NERD tree
" nmap <F6> <ESC>:NERDTreeToggle<CR>

" set guitablabel=%t

" " :help event
" autocmd VimEnter * NERDTree
" autocmd BufEnter * NERDTreeMirror

""""""""""""""""""""""""""""""
"" vim-nerdtree-tabs.vim
""""""""""""""""""""""""""""""
map <F6> <plug>NERDTreeTabsToggle<CR>

" let g:nerdtree_tabs_open_on_gui_startup=1     " Open NERDTree on gvim/macvim startup
" let g:nerdtree_tabs_open_on_console_startup=1 " Open NERDTree on console vim startup
" let g:nerdtree_tabs_open_on_new_tab=1         " Open NERDTree on new tab creation
let g:nerdtree_tabs_meaningful_tab_names=1    " Unfocus NERDTree when leaving a tab for descriptive tab names
let g:nerdtree_tabs_autoclose=1               " Close current tab if there is only one window in it and it's NERDTree
let g:nerdtree_tabs_synchronize_view=1        " Synchronize view of all NERDTree windows (scroll and cursor position)

" When switching into a tab, make sure that focus is on the file window, not in the NERDTree window.
let g:nerdtree_tabs_focus_on_files=1

" t  " Opens the selected file in a new tab.
" T  " The same as |NERDTree-t| except that the focus is kept in the current tab.
" i  " Opens the selected file in a new split window and puts the cursor in the new window.
" gi " The same as |NERDTree-i| except that the cursor is not moved.  |NERDTree-i|).
" s  " Opens the selected file in a new vertically split window and puts the cursor in the new window.
" gs " The same as |NERDTree-s| except that the cursor is not moved.
" x  " Closes the parent of the selected node.
" X  " Recursively closes all children of the selected directory.
" o  " Open a file or a directory.
" O  " Recursively opens the selelected directory.

""""""""""""""""""""""""""""""
"" DoxygenToolkit.vim
""""""""""""""""""""""""""""""
" :Dox       " generate function comment
" :DoxLic    " generate lincese
" :DoxAuthor " generate author info
" let g:DoxygenToolkit_authorName="ripwu@tencent.com"
" let g:DoxygenToolkit_licenseTag="My own license\<enter>"
" let g:DoxygenToolkit_undocTag="DOXIGEN_SKIP_BLOCK"
" let g:DoxygenToolkit_briefTag_pre="@brief\t"
" let g:DoxygenToolkit_paramTag_pre="@param\t"
" let g:DoxygenToolkit_returnTag="@return\t"
" let g:DoxygenToolkit_briefTag_funcName="no"
" let g:DoxygenToolkit_maxFunctionProtoLines=30

""""""""""""""""""""""""""""""
"" vimwiki
""""""""""""""""""""""""""""""
" \ww open wiki index at new window
" \wt open wiki index at new tab
" \w\w open/create today's item
" \w\t open/create today's item at new tab
" \ws
" \wd delete current item
" \wr rename current item
" map <F3> :Vimwiki2HTML<cr>
" map <S-F3> :VimwikiAll2HTML
"let g:vimwiki_list=[{'html_header' : '~/vimwiki_html/header.tpl'}]

""""""""""""""""""""""""""""""
"" show invisible character
""""""""""""""""""""""""""""""
" :set list!    " show invisible character
" :set invlist
"set listchars=
" invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

""""""""""""""""""""""""""""""
"" edit command
""""""""""""""""""""""""""""""
let mapleader=','
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

""""""""""""""""""""""""""""""
" F1: vim help
" F2: not used by now
" F3: VimWiki2Html
" F4: tag list
" F5: builg tags
" F6: NERDTree
" F7: generate comments by doxygen
" F8: winManager
" F9: replace all spaces at the end of line
" <C-F>: search word under cursor like source insight
" F10: next matched line
" F11: previous matched line (Quick Fix)
" F12: show calander
""""""""""""""""""""""""""""""
" build tags of my own project width F5
" --c++-kinds=+p : generate extra function prototypes info
" {
"              c : classes
"              d : macro definitions
"              e : enumerators(values inside an enumeration)
"              f : function definitions
"              g : enumeration names
"              l : local variables [off]
"              m : class, struct, and union members
"              n : namespaces
"              p : function prototypes [off]
"              s : structure names
"              t : typedefs
"              u : union names
"              v : variable definitions
"              x : external variable declarations [off]
" }
" --fileds=+iaS  : generate inheritabce/access/function Signature
" {
"              i : inheritance information
"              a : acess(or export) of class members
"              S : signature of routine (e.g. prototpye or parameter list)
" }
" --extra=+q     : generate class name info for class members
if has("win32")
    " firstly, copy a win version of ctags to $PATH, then enjoy using it
    map <F5> :!ctags -R --exclude=*.js --exclude=*.java --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
else
    map <F5> :!ctags -R --exclude=*.js --exclude=*.java --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
endif

set grepprg=grep
" set grepprg=ack

" :make
" :grep [pattern] [file]
" example: :grep -rn epoll **/*.[hc] **/*.cpp

" replace all spaces at the end of line
map <F9> :s=\s\+$==<CR>

" search word under cursor like source insight
" <cword> is replaced with the word under the cursor (like |star|) (:help cmdline or :help cword)
map <C-F> :execute "let g:word=expand(\"<cword>\")"<Bar>execute "vimgrep /\\<" . g:word ."\\>/g **/*.[ch] **/*.cpp **/*.cc"<Bar>execute "cc 1"<Bar>execute "cw"<CR>
" next matched line
map <silent> <F10> :cnext<CR>
" previous matched line
map <silent> <F11> :cprevious<CR>
" open QuickFix
" :copen
" close QuickFix
" :cclose

" calander
map <F12> :Calendar<cr>

""""""""""""""""""""""""""""""
"" tagbar setting
""""""""""""""""""""""""""""""
nmap <silent> <F4> :TagbarToggle<CR>
let g:tagbar_ctags_bin='ctags'
let g:tagbar_width=30

""""""""""""""""""""""""""""""
"" move around tabs
""""""""""""""""""""""""""""""
" :gt  " go to prev tab
" :gT  " go to next tab
" map <C-t><C-t> :tabnew<CR>
" map <C-t><C-c> :tabclose<CR>
" map <C-t><C-e> :tabedit

nmap <A-C-1> 1gt
nmap <A-C-2> 2gt
nmap <A-C-3> 3gt
nmap <A-C-4> 4gt
nmap <A-C-5> 5gt
nmap <A-C-6> 6gt
nmap <A-C-7> 7gt
nmap <A-C-8> 8gt
nmap <A-C-9> 9gt

imap <A-C-1> 1gt
imap <A-C-2> 2gt
imap <A-C-3> 3gt
imap <A-C-4> 4gt
imap <A-C-5> 5gt
imap <A-C-6> 6gt
imap <A-C-7> 7gt
imap <A-C-8> 8gt
imap <A-C-9> 9gt

vmap <A-C-1> 1gt
vmap <A-C-2> 2gt
vmap <A-C-3> 3gt
vmap <A-C-4> 4gt
vmap <A-C-5> 5gt
vmap <A-C-6> 6gt
vmap <A-C-7> 7gt
vmap <A-C-8> 8gt
vmap <A-C-9> 9gt

""""""""""""""""""""""""""""""
"" misc.
""""""""""""""""""""""""""""""
" select all text
map <C-a> ggVG

nmap t V>
nmap T V<
vmap t >gv
vmap T <gv

map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

""""""""""""""""""""""""""""""
"" search words
""""""""""""""""""""""""""""""
" * " search the word under cursor forward
" # " search the word under cursor backward
" / "
" ? "
"
" :help usr_03 (*03.8*	Simple searches)
" '\>' only matches at the end of a word.
" '\<' only matches at the begin of a word.
"
" If you type '/the' it will also match 'there".  To only find words that end in 'the' use: '/the\>'
" Thus to search for the word 'the' only: '/\<the\>' , This does not match 'there' or 'soothe'.
" Notice that the l*' and l#' commands use these start-of-word and end-of-word markers to only find whole words
" you can use 'g*' and 'g#' to match partial words).

""""""""""""""""""""""""""""""
"" save sessions
""""""""""""""""""""""""""""""
" vim -S Session.vim        " start VIM with a previously saved session file
" :mks[session][!] [file]   " write a Vim script that restores the current editing session.
			                " when [!] is included an existing file is overwritten.
			                " when [file] is omitted 'Session.vim' is used.

""""""""""""""""""""""""""""""
"" using macros
""""""""""""""""""""""""""""""
" qa      " starts recording the macro to register a
" q       " stops recoding the macro
" [count]@a " repeat the macro [count] times

""""""""""""""""""""""""""""""
"" Rip's vim tips
""""""""""""""""""""""""""""""
" :help text-objexts
"
" .         " command executes the last change command
" q:        " show history
"
" ddkP      " move this line upward
" ddp       " move this line downward
" dwwp      " swap words
" dw        " delete from current cursor position to the end of word
" D         " delete from current cursor position to the end of line
" d%        " delete by parenthesis matching. EXCELLENT!!!
" dd        " delete current line
" cc/S      " change current line
" C         " change a line from current cursor position to the end of line
" xp        " swap char under the cursor with the next char
" Vjjxp     " move next two lines downward
" VjjxP     " move next two lines upward
"
" Vu        " makes an entire sentence lowercase
" VU        " makes an entire sentence uppercase
"
" [count]f{char}   " To [count]'th occurrence of {char} to the right.  The cursor is placed on {char} |inclusive|.
" [count]F{char}   " To the [count]'th occurrence of {char} to the left.  The cursor is placed on {char} |exclusive|.
" [count]t{char}   " Till before [count]'th occurrence of {char} to the right.  The cursor is placed on the character left of {char} |inclusive|.
" [count]T{char}   " Till after [count]'th occurrence of {char} to the left.  The cursor is placed on the character right of {char} |exclusive|.
" ;	               " Repeat latest f, t, F or T [count] times.
" ,                " Repeat latest f, t, F or T in opposite direction [count] times.
" dt{char}  " delete from current cursor position till {char}. EXCELLENT!!!
"
" :help usr_03 ( *03.10*	Using marks)
" `.        " jump to last modificated line. EXCELLENT!!!
"
" [{        " jump to the start of the parenthesis {}
" ]}        " jump to the end of the parenthesis {}
" [(        " jump to the start of the parenthesis ()
" ])        " jump to the end of the parenthesis ()
" [/        " jump to the start of the current comment (only works for /* - */ comments.)
" ]/        " jump to the end of the current comment (only works for /* - */ comments.)
" [[        " jump to the start of the outer block
" ][        " jump to the end of the outer block
" ]]        " jump to the start of next block
" []        " jump backward to the end of a function
"
" gD        " search in the current file only, and jump to the first place where the word under the cursor. (goto definition)
" gd        " look only in the current function

"
" [I        " display all lines that contain the keyword. start at the begining of this file.
" ]I	    " like [I, but start at the current cursor position.
" [CTRL-I   " jump to the first line that contains the keyword. (CTRL-I is equal to Tab)
" ]CTRL-I	" like [CTRL-I, but start at the current cursor position.
"
" :help text-objects 
"   <action>i/a<object>
"   <action>  : v,d,c,y, and even '>' !!!
"   <object>  : {,',",(, and even s(entence),w(ord),p(aragraph) !!!
" vi{       " select all text inside parenthesis {}
" vi(       " select all text inside parenthesis ()
" vi"       " select all text inside parenthesis ""
" va{       " select all text inside parenthesis {}, including {}
" va(       " select all text inside parenthesis (), including ()
" va"       " select all text inside parenthesis "", including ""
"
" [I        " display all lines that contain the keyword under the cursor. the search starts at the beginning of the file.
" ]I	    " like [I, but start at the current cursor position.
" [CTRL-I   " jump to the first line that contains the keyword under the cursor.
" ]CTRL-I	" like [CTRL-I, but start at the current cursor position.
"
" :r[ead] !{cmd} " execute {cmd} and insert its standard output below the cursor or the specified line.

""""""""""""""""""""""""""""""
"" change windows size
""""""""""""""""""""""""""""""
" <C-w>(N)- " minus windows height by N pixel
" <C-w>(N)+ " add   windows height by N pixel
" <C-w>(N)< " minus windows weight by N pixel
" <C-w>(N)> " add   windows weight by N pixel

""""""""""""""""""""""""""""""
"" encoding settings
""""""""""""""""""""""""""""""
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,gbk,euc-jp,euc-kr,latin1
"set fileencodings=ucs-bom,cp936,gb18030,big5,gbk,euc-jp,euc-kr,latin1
if has("win32")
	set fileencoding=chinese
	" fix menu gibberish
	source $VIMRUNTIME/delmenu.vim
	source $VIMRUNTIME/menu.vim
	" fix console gibberish
	language messages zh_CN.utf-8
else
    set termencoding=utf-8
    "set termencoding=cp936
    " set fileencoding=utf-8
endif

""""""""""""""""""""""""""""""
" FencView.vim
""""""""""""""""""""""""""""""
" :FencAutoDetect " auto detect file encoding
" :FencView       " choose file encodings
let g:fencview_autodetect=1   " auto detect file encoding when I open file
let g:fencview_checklines=100 " check encoding by first N lines

""""""""""""""""""""""""""""""
"" mark.vim settings
""""""""""""""""""""""""""""""
" Highlighting:
"    Normal \m  mark or unmark the word under or before the cursor
"           \r  manually input a regular expression
"           \n  clear current mark (i.e. the mark under the cursor), or clear all marks
"    Visual \m  mark or unmark a visual selection
"           \r manually input a regular expression (base on the selection text)
" Searching:
"    Normal \*  jump to the next occurrence of current mark
"           \#  jump to the previous occurrence of current mark
"           \/  jump to the next occurrence of ANY mark
"           \?  jump to the previous occurrence of ANY mark
"            *  behaviors vary, please refer to the table on
"            #  line 123
"    combined with VIM's / and ? etc.
"
" Command line:
"    :Mark regexp   to mark a regular expression
"    :Mark regexp   with exactly the same regexp to unmark it
"    :Mark          to clear all marks

""""""""""""""""""""""""""""""
"" folden  settings
""""""""""""""""""""""""""""""
set foldenable           " enable folden
set foldmethod=syntax    " manual : Folds are created manually.
                         " indent : Lines with equal indent form a fold.
                         " expr   : 'foldexpr' gives the fold level of a line.
                         " marker : Markers are used to specify folds.
                         " syntax : Syntax highlighting items specify folds.
                         " diff   : Fold text that is not changed.
set foldcolumn=3         " set folden column width
"setlocal foldlevel=100
set foldlevel=100        " 100: means don't autofold anything (but I can still fold manually)
set foldopen-=search     " dont open folds when I search into thm
set foldopen-=undo       " dont open folds when I undo stuff

"set foldclose=all
" use space to folden
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

""""""""""""""""""""""""""""""
"" a.vim
""""""""""""""""""""""""""""""
" :A  " switches to the header file corresponding to the current file being edited (or vise versa)
" :AS " splits and switches
" :AV " vertical splits and switches

""""""""""""""""""""""""""""""
"" Tabular.vim
""""""""""""""""""""""""""""""
" :Tabularize /= " align selected text with =
" :tabularize /: " align selected text with :
"

"set foldclose=all
" use space to folden
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

""""""""""""""""""""""""""""""
"" highlight 80/81th char
""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.h,*.c,*.cpp,*.py match Error /\%80v.\%81v./

" markdown filetype file
au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   set filetype=markdown
" go filetype file
au BufRead,BufNewFile *.go set filetype=g

""""""""""""""""""""""""""""""
"" EasyMotion.vim
""""""""""""""""""""""""""""""
let g:EasyMotion_leader_key = 'f'
hi EasyMotionTarget ctermbg=none ctermfg=green
"hi EasyMotionShade  ctermbg=none ctermfg=blue

""""""""""""""""""""""""""""""
"" Ack.vim
""""""""""""""""""""""""""""""
" sudo apt-get install ack-grep
" :Ack hello
" :Ack -Q "*hello" "treat all metacharacters in PATTERN as a literal.

""""""""""""""""""""""""""""""
"" CtrlP.vim :help ctrlp
""""""""""""""""""""""""""""""
" <c-d> switch to filename only search instead of full path.
let g:ctrlp_working_path_mode = 'c' " the directory of the current file
set wildignore+=*/tmp/*,*.so,*.swp,*.zip " MacOSX/Linux
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

