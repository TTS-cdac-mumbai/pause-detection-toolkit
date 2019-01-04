#!/bin/bash

rm -rf PhraseCorrection.class
rm -rf atishJAVA
touch atishJAVA
javac PhraseCorrection.java
java PhraseCorrection path.properties
