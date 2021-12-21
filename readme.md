#FRAMATAB
# Use old android device like a photoframe to display photos in a folder

## requirements :

- adb (android debug bridge)
- imagemagick (for command convert)

## Start the diapo:
./app.sh start <time> <folder of immage>
## setup the device normally (after quit the diapo) :
./app.sh stop 
## reboot the device :
./app.sh reboot