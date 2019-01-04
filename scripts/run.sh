#!/bin/bash
## ----------------------------------------------------------------- ##
##   Pause Detection using ASR			                     ##
##           developed by Rachana and Atish			     ##
## ----------------------------------------------------------------- ##



# create a list of wav files (wavlist) in data/ 
DataPath=$1
NJ=$2 #24
BC=$3  
SampleRate=$4

WAVPath=$DataPath/wav
TXT=$DataPath/txt.done.data
valgrind=1
BC=1  # forced boundary correction
iterations=8


#clean script
rm -rf data/train/* data/test/* exp/* mfcc/* output/wav_splitting/splitted_waves/* data/local/dict/* data/lang/*
rm -rf output/wav_splitting/filedir output/wav_splitting/filename output/wav_splitting/spk2utt output/wav_splitting/text output/wav_splitting/textSIL output/wav_splitting/utt2spk output/wav_splitting/wav.scp output/wav_splitting/wavlist output/wav_splitting/wav_list output/wav_splitting/xaa output/wav_splitting/xab

echo "Preparing data"
ls $WAVPath > data/wavlist

if [ ! $SampleRate -eq 48000 ]; then
	#echo $SampleRate > temp.txt
	sed -i -- 's/sample-frequency=48000/sample-frequency='"$SampleRate"'/g' conf/fbank.conf
	sed -i -- 's/sample-frequency=48000/sample-frequency='"$SampleRate"'/g' conf/mfcc.conf

	sh resources/scripts_alignment_for_TTS/copy_wav_and_downsample.sh data/wavlist $WAVPath $SampleRate #ENV variable WAVPath(path to 48KHz wavfiles) needs to be set
	WAVPath=$PWD/data/wav
fi

#####to generate lexicon.txt
awk '{$1=$2=$3=""; print $0}' $TXT > resources/parser/text
cat resources/parser/text | tr -d '"' | tr -d ')' | sed "s/'/ /g" | sed "s/‘/ /g"  > resources/parser/text1
sed -e 's/ /\n/g' -e 's/,/ /g' resources/parser/text1 | sort -u  > resources/parser/in.txt

###For text_c1#######
cat resources/parser/text1 | tr -d '\r' | awk '{print "<s>"$0"</s>"}' > data/local/plain-text/text_c1

sh resources/parser/call-IL_parser.sh
cp resources/parser/lexicon.txt data/local/dict
cat data/local/dict/lexicon.txt | awk '{$1=""; print $0}' | sed 's/\s\+/\n/g;s/sil//g' | sort -u  > data/local/dict/nonsilence_phones.txt
echo "sil" > data/local/dict/silence_phones.txt
echo "sil" > data/local/dict/optional_silence.txt
sed --i '1d' data/local/dict/lexicon.txt
sed --i '1i sil sil' data/local/dict/lexicon.txt
sed --i '1i !SIL sil' data/local/dict/lexicon.txt
sed --i '1d' data/local/dict/nonsilence_phones.txt



echo "data files prepared"

. .path.sh

sh resources/scripts_alignment_for_TTS/create_wav_scp_utt2spk.sh $WAVPath

#sed 's/(//g; s/"//g; s/)//g; s/^ *//g; s/\r//g; s/$/SIL/g' $TXT | awk '{$2="SIL"; print $0}' > data/train/text
sed 's/(//g; s/"//g; s/)//g; s/^ *//g; s/\r//g; s/$/SIL/g' $TXT | awk '{$1=$1" SIL "; print }' > data/train/text


sort data/train/text > data/train/text_sorted
rm data/train/text
mv data/train/text_sorted data/train/text
cp data/train/text data/test/text
sort data/train/spk2utt > data/train/spk2utt_sorted
rm data/train/spk2utt
mv data/train/spk2utt_sorted data/train/spk2utt
cp data/train/spk2utt data/test/spk2utt
sort data/train/utt2spk > data/train/utt2spk_sorted
rm data/train/utt2spk
mv data/train/utt2spk_sorted data/train/utt2spk
cp data/train/utt2spk data/test/utt2spk
sort data/train/wav.scp > data/train/wav.scp_sorted
rm data/train/wav.scp
mv data/train/wav.scp_sorted data/train/wav.scp
cp data/train/wav.scp data/test/wav.scp

#####for training
./scripts/create_lm.sh
bash scripts/myrun.sh $NJ
