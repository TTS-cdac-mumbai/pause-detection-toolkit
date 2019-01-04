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
##   written permission.					     ##
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

WAV_48=$1

#wav.scp
ls $WAV_48/* > data/wav.scp_temp2
sed 's/\.wav//g' data/wavlist > data/wav.scp_temp1
paste data/wav.scp_temp1 data/wav.scp_temp2 > data/train/wav.scp
rm data/wav.scp_temp1 data/wav.scp_temp2;

#utt2spk
sed 's/\.wav//g' data/wavlist > data/utt2spk_temp1
#cat data/utt2spk_temp1 | cut -d '_' -f2 > data/utt2spk_temp2
#paste data/utt2spk_temp1 data/utt2spk_temp2 > data/train/utt2spk
paste data/utt2spk_temp1 data/utt2spk_temp1 > data/train/utt2spk
rm data/utt2spk_temp1

#spk2utt
perl utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt 
