source $VIMRUNTIME/defaults.vim

"general preferences
set background=dark mouse=
set noswapfile
set nowrap
set tabstop=4 shiftwidth=4 expandtab
set laststatus=2

"do not abandon unloaded buffers
set hidden

"complete from current buffer and tags, do not use popup menu
set complete=.,t completeopt=

"configure netrw (declutter header, human-readable file sizes)
let g:netrw_sort_sequence='\/,*'
let g:netrw_sizestyle='H'

"configure SQL filetype plugin (MySQL syntax, prevent stupid <C-C> mapping)
let g:sql_type_default='mysql'
let g:omni_sql_no_default_maps=1


"----- config -----

let g:sysconf_dir = expand('<sfile>:p:h')

com! U so ~/.vimrc
com! UR exec '!cd '.g:sysconf_dir.' && git pull' | U


"---- terminal -----

fun! TermRun(pre, post)
    let g:run_cmd = a:pre.' '.expand('%:p').' '.a:post
    let g:run_buf_nr = term_start(g:run_cmd)
    let g:run_win_id = win_findbuf(g:run_buf_nr)[0]
endfun

com! -nargs=? -complete=file R call TermRun('', <q-args>)

fun! TermRerun()
    call win_gotoid(g:run_win_id)
    call term_start(g:run_cmd, {'curwin': 1})
endfun

com! RR call TermRerun()

fun! TermStatus() 
    let l:job = term_getjob(g:run_buf_nr)
    let l:pid = job_info(l:job)['process']
    exec '!cat /proc/'.l:pid.'/status'
endfun

com! RS call TermStatus()


"----- git ------

com! -nargs=+ G !git add --all && git status && read -n 1 _ && git commit -m "<args>" && git push
com! GP !git pull
com! GD !clear; git diff

fun! GitDiff()
    " make % relative to current working dir
    cd .
    let @d = system("git show HEAD:./".expand('%'))
    let l:ft = &ft
    let l:ln = line('.')
    vert new
    exec "set bt=nofile bh=wipe ft=".l:ft
    put d
    0delete
    exec l:ln
endfun

com! D call GitDiff()

"----- mysql -----

fun! MySQL(login, ...)
    let l:options = ' ++close'
    let l:args = ''
    if a:0 > 0
        let l:args = ' '.a:1
        if a:0 > 1
            let l:sql = join(a:000[1:], ' ')
            let l:args .= ' -e "'.l:sql.'"'
            let l:options = ''
        endif
    endif
    exec 'ter'.l:options.' mysql --login-path='.a:login.' -A'.l:args
endfun

com! -nargs=+ M call MySQL(<f-args>)


"----- ptyhon -----

com! P ter ++close python3
com! -nargs=? -complete=file RP call TermRun('python3 -i', <q-args>)
com! PL compiler pylint | make %


"----- misc -----

com! S sub/\%#\([^,]*\), \([^,)}\]]*\)/\2, \1/
nmap gl :S<cr><c-o>
com! CX !chmod +x %
com! W write
com! B setlocal wrap! | setlocal wrap?
com! C setlocal paste! | setlocal paste?
com! -nargs=1 T setlocal tabstop=<args>