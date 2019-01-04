#! /bin/sh


cd output/wav_splitting
rm -rf CorrectASR.txt filedir filename spk2utt text textSIL toCorrectASR-ngram.txt txt.done.data utt2spk wav.scp wavlist wav_list 
rm -rf splitted_waves/*.txt
cd ../..

cd data/wav/

ls -d $PWD/*.wav > ../../output/wav_splitting/wavlist


cd ../..


cd output/wav_splitting

sh load_splitting.sh
