##################################
# idamanpharma
##################################

# mail
rdesktop -z -a 16 -5 -g 1024x768 -T mail.idamanpharma.com -u administrator -d idamanpharma mail.idamanpharma.com &
#rdesktop -g 80% -u administrator -d idamanpharma -z mail.idamanpharma.com &

# fs1
rdesktop -z -a 16 -5 -g 1024x768 -T fs1.idamanpharma.com -u administrator -d idamanpharma <ip> &

##################################
# prestigepharma
##################################

# mail
rdesktop -z -a 16 -5 -g 1024x768 -T mail.prestigepharma.com -u admin -d prestigepharma -p resocent mail.prestigepharma.com.my:3389 &

# ubs
rdesktop -z -a 16 -5 -g 1024x768 -T 'ubs.prestigepharma.com' -u admin -d prestigepharma mail.prestigepharma.com.my:3391 &

# dc1
rdesktop -z -a 16 -5 -g 1024x768 -T dc1.prestigepharma.com -u admin -d prestigepharma mail.prestigepharma.com.my:3390 &

##################################
# utm kl kaspersky
##################################

##################################
# utm jb kaspersky
##################################
rdesktop -z -a 16 -5 -g 1024x768 -T sepmdb -u administrator -p utmjbp@ssw0rd 161.139.18.160 & # db
rdesktop -z -a 16 -5 -g 1024x768 -T sepm1 -u administrator -p utmjbp@ssw0rd 161.139.18.161 & # staff
rdesktop -z -a 16 -5 -g 1024x768 -T sepm2 -u administrator -p utmjbp@ssw0rd 161.139.18.162 & # student

##################################
# utm jb wsus
##################################
rdesktop -z -a 16 -5 -g 1024x768 -T sepmkl1 -u administrator -p utmklp@ssw0rd 10.10.12.23 & # staff; tak boleh remote desktop direct, perla lalu server jb.
rdesktop -z -a 16 -5 -g 1024x768 -T sepmkl1 -u administrator -p utmklp@ssw0rd 10.10.12.23 & # staff; tak boleh remote desktop direct, perla lalu server jb.

