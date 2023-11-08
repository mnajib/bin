lpc status
lpadmin -p HP_DeskJet_2130_series -o printer-error-policy=retry-job
cupsenable HP_DeskJet_2130_series
lpc status
lpstat -p
systemctl restart cups
