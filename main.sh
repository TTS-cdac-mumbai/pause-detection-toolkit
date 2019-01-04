## ----------------------------------------------------------------- ##
##   Pause Detection using ASR			                     ##
##           developed by Rachana and Atish			     ##
## ----------------------------------------------------------------- ##

rm -rf filedir filename spk2utt text txt.done.data utt2spk wav.scp

bash scripts/run.sh input/ 16 1 8000

sh output/wav_splitting/call_splitting.sh

bash scripts/online_speech.sh
