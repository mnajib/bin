 rsync -azP \
 --exclude /home/najib/bin \
 --exclude /home/najib/.xmonad \
 --exclude '/home/najib/.nix*' \
 --exclude /home/najib/.cache \
 --exclude /home/najib/.bash_history \
 --exclude /home/najib/.gitconfig \
 najib@mahirah:/home/najib \
 /home
