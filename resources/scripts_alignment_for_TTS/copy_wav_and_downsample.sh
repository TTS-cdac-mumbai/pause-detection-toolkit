## ----------------------------------------------------------------- ##
##  DNN Segmentation					                     ##
##           developed by Indian Language Text-to-Speech Consortium  ##
## ----------------------------------------------------------------- ##
##                                                                   ##
##  Copyright (c) 2015  Indian Language Text-to-Speech Consortium    ##
##                      Headed by Prof Hema A Murthy, IIT Madras     ##
##                      Department of Computer Science & Engineering ##
##                      hema@cse.iitm.ac.in                          ##
##                                                                   ##
##                                 				               ##
## All rights reserved.                                              ##
##                                                                   ##
## Redistribution and use in source and binary forms, with or        ##
## without modification, are permitted provided that the following   ##
## conditions are met:                                               ##
##                                                                   ##
## - It can be used for research purpose but for commercial use,     ##
##   prior permission is needed.                                     ##
## - Redistributions of source code must retain the above copyright  ##
##   notice, this list of conditions and the following disclaimer.   ##
## - Redistributions in binary form must reproduce the above         ##
##   copyright notice, this list of conditions and the following     ##
##   disclaimer in the documentation and/or other materials provided ##
##   with the distribution.                                          ##
## - Neither the name of the Indian Language TTS Consortium nor      ##
##   the names of its contributors may be used to endorse or promote ##
##   products derived from this software without specific prior      ##
##   written permission.					               ##
##                                                                   ##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            ##
## CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       ##
## INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          ##
## MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          ##
## DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS ##
## BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          ##
## EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   ##
## TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     ##
## DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ##
## ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   ##
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    ##
## OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           ##
## POSSIBILITY OF SUCH DAMAGE.                                       ##
## ----------------------------------------------------------------- ##
#Set WAV_48 env variable
#Argument is list of files to be copied (only file names)
list=$1
WAV_48=$2
sampleRate=$3

root=$PWD
echo "Copying wav"
wav_8=data/wav
rm -rf $wav_8; mkdir -p $wav_8;
for f in `cat $list` ; do `cp $WAV_48/$f $wav_8/$f` ; done

echo "Converting Sampling Rate"
cd  $wav_8 ;
for f in *.wav; do ch_wave $f -f 48000 -F $3 -o $f ; done
cd $root


