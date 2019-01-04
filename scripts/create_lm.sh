#!/bin/bash -u

. path.sh

KALDI_ROOT=/home/rachana/asr/kaldi-trunk

mkdir data/local/tmp
utils/prepare_lang.sh data/local/dict '!SIL' data/local/lang data/lang
# Create the phone bigram LM
export IRSTLM=/home/rachana/asr/kaldi-trunk/tools
(
  [ -z "$IRSTLM" ] && \
    error_exit "LM building wo'nt work without setting the IRSTLM env variable"
  $KALDI_ROOT/tools/bin/build-lm.sh -i data/local/plain-text/text_c1 -n 3 -o data/local/tmp/lm_phone_bg.ilm.gz
  $KALDI_ROOT/tools/bin/compile-lm --text="yes" data/local/tmp/lm_phone_bg.ilm.gz data/local/tmp/lm_phone_bg.ilm.lm
	
) >& data/prepare_lm.log

cat data/local/tmp/lm_phone_bg.ilm.lm | grep -v unk | gzip -c > data/lang/lm_phone_bg.arpa.gz 

gunzip -c data/lang/lm_phone_bg.arpa.gz | utils/find_arpa_oovs.pl data/lang/words.txt  > data/local/tmp/oov.txt

gunzip -c data/lang/lm_phone_bg.arpa.gz | grep -v '<s> <s>' | grep -v '<s> </s>' | grep -v '</s> </s>' | grep -v 'SIL' | $KALDI_ROOT/src/bin/arpa2fst - | fstprint | utils/remove_oovs.pl data/local/tmp/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon > data/lang/G.fst
$KALDI_ROOT/src/fstbin/fstisstochastic data/lang/G.fst
