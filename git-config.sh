#git log --pretty=format:'%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cr)'
#git log --pretty=oneline --decorate --graph
#git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'

git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist 'log --pretty=format:"%C(yellow)%h%Cred%d%Creset - %C(cyan)%an %Creset: %s %Cgreen(%cr)" --graph --date=short'
git config --global alias.type 'cat-file -t'
git config --global alias.dump 'cat-file -p'

#git branch -a -vv
git config --global alias.branchall 'branch -a -vv'
