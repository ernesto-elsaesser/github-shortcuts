unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" ----- options -----

" hacker mode
set background=dark

" spaces > tabs
set tabstop=4 shiftwidth=4 expandtab

" disable unwanted features
set mouse= nowrap noswapfile viminfo=

" do not abandon unloaded buffers
set hidden

" complete only from current buffer
set complete=.

" use autocmd to reset formatoptions after ftplugins
autocmd BufEnter * setlocal formatoptions=

" disable parenthese highlighting
let loaded_matchparen = 1

" configure netrw (preserve alternate file, declutter banner)
let g:netrw_altfile=1
let g:netrw_sort_sequence='\/$,\*$,*'

" configure SQL filetype plugin (MySQL syntax, prevent stupid <C-C> mapping)
let g:sql_type_default='mysql'
let g:omni_sql_no_default_maps=1


"----- config -----

let g:dotfile_dir = $HOME.'/dotfiles'

com! U so ~/.vimrc
com! UP exec '!cd ' . g:dotfile_dir . ' && git pull --ff-only' | U


"----- tabs -----

fun! GetTabLine()
    let tabnrs = range(1, tabpagenr('$'))
    let titles = map(tabnrs, 'v:val . ":" . fnamemodify(bufname(tabpagebuflist(v:val)[-1]),":t")')
    let selnr = tabpagenr() - 1
    let titles[selnr] = titles[selnr] . '*'
    return ' ' . join(titles, ' | ')
endfunction

set tabline=%!GetTabLine()

com! -nargs=1 -complete=file T tabedit <args>

"----- terminal -----

fun! LaunchEnv(name, prefix)
    exec a:prefix.'ter ++close '.g:dotfile_dir.'/launch-env.sh '.a:name.' '.expand('%')
endfun

com! -nargs=1 SSH ter ++close ssh <args>


"----- git ------

fun! ShowGitRev(ref)
    " make % relative to current working dir
    cd .
    let name = expand('%')
    let type = &ft
    let lnum = line('.')
    vert new
    exec 'setlocal bt=nofile bh=wipe ft='.type
    exec '0read !git show '.a:ref.':./'.name
    exec lnum
endfun

com! -nargs=? RV call ShowGitRev('HEAD<args>')


"----- mysql -----

com! -nargs=1 DB let g:mysql_conf = <q-args>

fun! ExecSQLQuery(query)
    new
    exec 'setlocal bt=nofile bh=wipe ts=20'
    exec 'silent 0read !mysql --login-path='.g:mysql_conf.' -vv -e "'.a:query.'"'
    0
endfun

fun! GetSQLQuery(reg)
    let query = getreg(a:reg)
    let query = substitute(query, '\n', ' ', 'g')
    let query = substitute(query, '\s\+', ' ', 'g')
    let query = substitute(query, '"', '\\"', 'g')
    return query
endfun

com! -nargs=1 Q call ExecSQLQuery(<q-args>)
com! -nargs=1 QA call ExecSQLQuery('SELECT * FROM <args>')
com! QQ call ExecSQLQuery(GetSQLQuery(0))
com! -nargs=1 S call ExecSQLQuery('SHOW FULL COLUMNS FROM <args>')
com! ST call ExecSQLQuery('SHOW TABLES')
com! SD call ExecSQLQuery('SHOW DATABASES')
com! SP call ExecSQLQuery('SHOW PROCESSLIST')



"----- python -----

com! PL compiler pylint | make %


" ----- mappings -----

" open current file's directory (after making it the alternate file)
nmap - :edit %:h/<CR>

" swap list items (separated by ', ')
nmap gx `sv`ty`uv`vp`tv`sp
nmap L mst,mtlllmu/\v(,<Bar>\)<Bar>\}<Bar>\])<CR>?\S<CR>mvgxlll
nmap H mvT,lmuhhhmt?\v(,<Bar>\(<Bar>\{<Bar>\[)<CR>/\S<CR>msgx

" next quickfix
nmap Q :cnext<CR>

" leader mappings
nmap <Leader>d :call LaunchEnv('dbg', 'vert ')<CR>
nmap <Leader>c :call LaunchEnv('git', '')<CR>
nmap <Leader>w :setlocal wrap!<CR>:setlocal wrap?<CR>
nmap <Leader>v :setlocal paste!<CR>:setlocal paste?<CR>
nmap <Leader>t :setlocal tabstop+=4<CR>
nmap <Leader>s :let g:netrw_sizestyle=( g:netrw_sizestyle == 'H' ? 'b' : 'H' )<CR>:let g:netrw_sizestyle<CR>
