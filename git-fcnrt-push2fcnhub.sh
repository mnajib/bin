# In the simplest terms, git pull does a git fetch followed by a git merge.
# You can do a git fetch at any time to update your local copy of a remote branch. This operation never changes any of your own branches and is safe to do without changing your working copy. I have even heard of people running git fetch periodically in a cron job in the background (although I wouldn't recommend doing this).
# A git pull is what you would do to bring your repository up to date with a remote repository.

#git branch -avv
#git remote update
#git remote show fcnhub

#git fetch fcnhub
#git pull fcnhub master
#git status

git fetch r61vmhub
git pull r61vmhub
git push r61vmhub

git fetch fcnhub
git pull fcnhub
git push fcnhub

#git fetch fnchub
#git status
##git diff fcnhub/master
##git diff fcnhub/master master
#git diff master fcnhub/master
