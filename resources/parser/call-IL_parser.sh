rm -rf resources/parser/lexicon.txt
touch resources/parser/lexicon.txt

cd resources/parser

for i in `cat in.txt`
do
	perl il_parser_hts.pl $i
	cat wordpronunciation >> lexi
	echo "" >> lexi
done

sort -u lexi > lexicon.txt

cd ../..

