#! /bin/bash

path=$PWD
model_path=$path/exp/tri2_450_1800
. $path/path.sh


train_cmd=$path/utils/run.pl
decode_cmd=$path/utils/run.pl 

wav_dir="/media/rachana/sda8/workspace-1nov18/pause_detection_toolkit/DNN_SEGMENTATION/SEGMENTATION/output/wav_splitting/splitted_waves"	# 1st input giving frm outside give path of input testing waves
decode_graph="graph"

touch att

rm -rf wav_list
cd $path/output/wav_splitting/splitted_waves
ls *.wav > wav_list       
mv wav_list ../
cd ..

prev=""

rm -rf $path/txt.done.data
touch $path/txt.done.data


for wav_name in `cat wav_list`     ## error located from here
do
	filename="${wav_name%.*}"".txt"
	name=$(basename "$wav_name" ".wav")
	echo "file-name=$name\n" >> att

	test="part"
	cut_index=$(awk -v a="$name" -v b="$test" 'BEGIN{print index(a,b)}')
	cut_ind=`expr $cut_index - 1`
	echo "cutting index is=$cut_ind"
	basic_name=$(echo $name | cut -c1-$cut_ind)
	echo "basicname=$basic_name"
        echo "basic name=$basic_name" >> att
	if [ "$prev" != "$basic_name" ]
	then
		prev=$basic_name
		printf " \" )"  >> .txt.done.data
		printf "\n ( $basic_name \""  >> txt.done.data
	fi

	cd $wav_dir
	rm -rf filedir cmvn.scp filename wav.scp text utt2spk spk2utt dmp log
	echo "$wav_name" > filename
	echo $wav_dir/$wav_name > filedir

	paste filename filedir > wav.scp
	paste filename filename > utt2spk
	cp utt2spk spk2utt
	paste filename filename > text

	cd -

	cd $path

	steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt
	steps/compute_cmvn_stats.sh $wav_dir $wav_dir/log $wav_dir/dmp > $wav_dir/log.txt

	#Decode Using tri2 acaustic model
	gmm-latgen-faster --print-args=false --max-active=7000 --beam=13.0 --lattice-beam=6.0 --acoustic-scale=0.083333 --allow-partial=true --word-symbol-table=$model_path/$decode_graph/words.txt $model_path/final.mdl $model_path/$decode_graph/HCLG.fst "ark,s,cs:apply-cmvn  --utt2spk=ark:$wav_dir/utt2spk scp:$wav_dir/cmvn.scp scp:$wav_dir/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- |  transform-feats $model_path/final.mat ark:- ark:- |" ark,t:$model_path/trans.txt >$wav_dir/log.txt 2> $wav_dir/out.txt 

	cat $wav_dir/out.txt |grep ^"$wav_name" |cut -d ' ' -f2- | sed 's/SIL//g'| sed 's/sil//g'| sed 's/^ //g' | sed 's/  $//g' |sed 's/ / /g' | head -1 > $wav_dir/$filename

	if [ "$basic_name" = "$prev" ]
	then
		op=$(cat $wav_dir/$filename) 
		echo "rachana check op=$op" >> att
		     printf " $op " >> txt.done.data
		printf ", " >> txt.done.data
		else
		printf " \")" >> txt.done.data 
		printf "( " $base_name >> txt.done.data

	fi
done

cp txt.done.data resources/text-correction/
cp data/train/text resources/text-correction/
cd resources/text-correction
#rm -rf CorrectASR.txt correctedRecognition.txt ErrorFromCorrect.txt ErrorFromCorrected.txt PhraseCorrection.class text textOpen textSIL toCorrectASR-ngram.txt 
mv txt.done.data toCorrectASR-ngram.txt
sed 's/SIL/\"/g' text > textSIL
sed -e 's/^/( /' textSIL > textOpen
sed -e 's/$/ )/' textOpen > CorrectASR.txt

./runJava.sh

mv correctedRecognition.txt corrected_txt.done.data
cp corrected_txt.done.data ../

echo "Completed text generation...."
