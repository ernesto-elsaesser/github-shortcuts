unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set background=dark
set hidden
set number
set complete=.,t
set completeopt=
set noswapfile
set nowrap
set splitright
set splitbelow

nmap gz de/\w<cr>vep``P

hi MatchParen ctermfg=Green ctermbg=NONE
hi LineNr ctermfg=DarkGray

let g:diff_branch='master'

fun! DiffGit()
	cd .
	let @d = system("git show ".g:diff_branch.":./".bufname('%'))
	let l:ft = &ft
	let l:ln = line('.')
	setlocal diff scrollbind
	vert new
	autocmd BufDelete <buffer> diffoff!
	exec "set bt=nofile ft=".l:ft
	put d
	0delete
	exec l:ln
	setlocal diff scrollbind 
	diffupdate
endfun

fun! MySQL(login, database)
	exec 'ter ++rows=40 ++close mysql --login-path="'.a:login.'" '.a:database
endfun

fun! MySQLExec(login, database, ...)
	let l:sql = join(a:000, ' ')
	exec 'ter ++rows=40 mysql --login-path="'.a:login.'" '.a:database.' -e "'.l:sql.'"'
endfun

com! U so ~/.vimrc
com! UR ter ++rows=10 update-repo.sh
com! -nargs=? -complete=file R exec "ter ++rows=24 ".expand('%:p')." <args>"

com! G ter ++close commit-and-push.sh
com! -nargs=+ GE ter git <args>
com! C ter ++rows=10 git diff --name-status
com! D call DiffGit()

com! -nargs=+ P py3 <args>
com! -nargs=1 PP py3 print(<args>)
com! PF py3file %
com! PL compiler pylint | make %

com! -nargs=+ M call MySQL(<f-args>)
com! -nargs=+ ME call MySQLExec(<f-args>)
