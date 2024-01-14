
:nmap %% :let X=1<cr>1G!!
:nmap !! /^\s*<SomeElement Id="F"<cr>:s/F"/\=X.'"'/<cr>:let X=X+1<cr>!!

:,$s/^(\d*,\ /(xxx,\ /gc

:nmap %% :let X=1<cr>1G!!
:nmap !! /^(xxx,\ <cr>:s/^(xxx,\ /\=X.', '/<cr>:let X=X+1<cr>!!

:nmap !! /^(xxx,\ <cr>:s/xxx,\ /\=X.', '/<cr>:let X=X+1<cr>!!

