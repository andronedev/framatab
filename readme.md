# FRAMATAB
# Use old android device like a photoframe to display photos in a folder

<pre>
$ wget https://raw.githubusercontent.com/andronedev/framatab/master/app.sh
$ chmod +x app.sh
$ ./app.sh 
Usage: ./app.sh &lt;start|stop|reboot&gt;
</pre>

## requirements :

- adb (android debug bridge)
- imagemagick (for command convert)

## Start the diapo:
`./app.sh start <time> <folder of immage>`
## setup the device normally (after quit the diapo) :
`./app.sh stop`
## reboot the device :
`./app.sh reboot`
