#!/bin/bash

if [ -z "$1" ] ; then
  echo input file missing
  echo "Usage: $0 input.cu8 output.sr [sample rate in kHz]"
  exit 1
fi
if [ ! -r "$1" ] ; then
  echo input not found
  echo "Usage: $0 input.cu8 output.sr [sample rate in kHz]"
  exit 1
fi
file=$1

if [ -z "$2" ] ; then
  echo output file missing
  echo "Usage: $0 input.cu8 output.sr [sample rate in kHz]"
  exit 1
fi
if [ -e "$2" ] ; then
  echo output already exists
  echo "Usage: $0 input.cu8 output.sr [sample rate in kHz]"
  exit 1
fi
out=$2

if [ -z "$3" ] ; then
  rate=250
else
  rate=$3
fi

if [ ! -z "$4" ] ; then
  echo too many arguments
  echo "Usage: $0 input.cu8 output.sr [sample rate in kHz]"
  exit 1
fi

# create I-data channel
rtl_433 -q -r "$file" -m 7 analog-1-4-1 >/dev/null 2>&1
# create Q-data channel
rtl_433 -q -r "$file" -m 8 analog-1-5-1 >/dev/null 2>&1
# create AM-data channel
rtl_433 -q -r "$file" -m 5 analog-1-6-1 >/dev/null 2>&1
# create FM-data channel
rtl_433 -q -r "$file" -m 6 analog-1-7-1 >/dev/null 2>&1
# create state channels
rtl_433 -q -r "$file" -m 10 logic-1-1 >/dev/null 2>&1
# create version tag
echo -n "2" >version
# create meta data
cat >metadata <<EOF
[device 1]
capturefile=logic-1
total probes=3
samplerate=$rate kHz
total analog=4
probe1=FRAME
probe2=ASK
probe3=FSK
analog4=I
analog5=Q
analog6=AM
analog7=FM
unitsize=1
EOF

zip "$out" version metadata analog-1-4-1 analog-1-5-1 analog-1-6-1 analog-1-7-1 logic-1-1
rm version metadata analog-1-4-1 analog-1-5-1 analog-1-6-1 analog-1-7-1 logic-1-1
