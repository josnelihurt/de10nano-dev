#/bin/bash

echo "playing with /dev/custom_leds"
values=('\x1' '\x2' '\x4' '\x8' '\x10' '\x10' '\x20' '\x40' '\x80')
for i in {1..5}; do
   for j in {0..8}; do
        echo -n -e ${values[$j]} > /dev/custom_leds
        sleep 0.05
   done
   
   for j in {0..8}; do
        echo -n -e ${values[8-$j]} > /dev/custom_leds
        sleep 0.05
   done
done