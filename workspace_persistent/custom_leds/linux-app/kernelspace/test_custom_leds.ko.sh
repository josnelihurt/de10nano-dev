#!/bin/sh

echo "playing with /dev/custom_leds"
#values=('\x1' '\x2' '\x4' '\x8' '\x10' '\x10' '\x20' '\x40' '\x80')
for i in {1..5}; do
    echo -n -e '\x1' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x2' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x4' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x8' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x10' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x20' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x40' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x80' > /dev/custom_leds
    sleep 0.05
    
    echo -n -e '\x80' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x40' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x20' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x10' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x8' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x4' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x2' > /dev/custom_leds
    sleep 0.05
    echo -n -e '\x1' > /dev/custom_leds
    sleep 0.05
done
# values=('\x1' '\x2' '\x4' '\x8' '\x10' '\x10' '\x20' '\x40' '\x80')
# for i in {1..5}; do
#    for j in {0..8}; do
#         echo -n -e ${values[$j]} > /dev/custom_leds
#         sleep 0.05
#    done

#    for j in {0..8}; do
#         echo -n -e ${values[8-$j]} > /dev/custom_leds
#         sleep 0.05
#    done
# done