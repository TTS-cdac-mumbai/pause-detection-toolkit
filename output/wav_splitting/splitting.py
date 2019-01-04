## This script can be used only for 8KHz wavefile.


import glob # For command line wildcards
import os # For optionally deleting the input files
import struct # For converting the (two's complement?) binary data to integers
import sys # For command line arguments
import wave # For .wav input and output

# Set sensible defaults
threshold = 1024 # This has to be a number between 1 and 32767
duration = 1440  ####11025 # Measured in single samples## 1ms=8Samples so, 250ms=2000samples
delete = False
inputFilenames = []

# Override the defaults
for argument in sys.argv:       # check for args
	# Override the filename
	print "1=", argument
	if (argument[-4:].lower() == '.wav'):   ## list of arguments
		filenames = glob.glob(argument)

		for filename in filenames:
			inputFilenames.append(filename)

		continue

	# Override the threshold                         
	if (argument[:12] == '--threshold='):            #extract threshold
		argument = int(argument[12:])
		print "argument=",argument

		if (argument > 0 and argument < 32768):
			threshold = argument			#set user threshold
			print "by threshold from argument=",threshold
			continue
		else:
			print('The threshold must be an integer between 1 and 32767')
			exit()

	# Override the duration
	if (argument[:11] == '--duration='):
		argument = int(argument[11:])

		if (argument > 0):
			duration = argument
			continue
		else:
			print('The duration must be a positive integer')
			exit()
	# Replace original files
	elif (argument == '-d'):
		delete = True

if (len(inputFilenames) == 0):
	print("""\
Usage:
python3 wavesplit.py [option...] input.wav
Options: (may appear before or after arguments)
	--threshold=foo
		set the cutoff point between signal and noise (default is 1024, any number between 1 and 32767 is valid)
	--duration=foo
		require this many consecutive samples below the cutoff point in order to close the output file (default is 11025, a quarter of a second at CD quality)
	-d
		delete original files
	""")
	exit()

# Cycle through files
for inputFilename in inputFilenames:
	#outputFilenamePrefix = inputFilename[:-4]
	outputFilenameNumber = 0
        print "inputfilename=",inputFilename        
	head, tail = os.path.split(inputFilename)
	print tail
	#outputFilenamePrefix = tail[:-4]
        outputFilenamePrefix="splitted_waves/" + tail[:-4]
         
	try:
		inputFile = wave.open(inputFilename, 'r')
	except:
		print(inputFilename, "doesn't look like a valid .wav file.  Skipping.")
		continue

	framerate = inputFile.getframerate()      ### get frame rate and channels
	print "framerate=",framerate
	numberOfChannels = inputFile.getnchannels()   
	print "numberOfChannels=",numberOfChannels
	sampleWidth = inputFile.getsampwidth()    ##    use of sample width
        print "sample_width is=" , sampleWidth
        print "nframes=",inputFile.getnframes()
        duration_of_wave=inputFile.getnframes()/framerate
	print "duration of wave=",duration_of_wave
	currentlyWriting = False
	allChannelsBeneathThreshold = 0

	for iteration in range(0, inputFile.getnframes()):
		allChannelsAsBinary = inputFile.readframes(1)
		allChannelsCurrentlyBeneathThreshold = True

		for channelNumber in range (numberOfChannels):
			channelNumber = channelNumber + 1
			channelStart = (channelNumber - 1) * sampleWidth
			print "channelStart=", channelStart
			channelEnd = channelNumber * sampleWidth
			print "channelEnd=",channelEnd
			channelAsInteger = struct.unpack('<h', allChannelsAsBinary[channelStart:channelEnd])
                        print "channelAsInteger= " , channelAsInteger
			channelAsInteger = channelAsInteger[0]
                        #print "check " ,channelNumber , channelAsInteger
			if (channelAsInteger < 0):
				channelAsInteger = 0 - channelAsInteger # Make readout unipolar

			if (channelAsInteger >= threshold):
				allChannelsCurrentlyBeneathThreshold = False

		if (currentlyWriting == True):
			# We are currently writing
			outputFile.writeframes(allChannelsAsBinary)

			if (allChannelsCurrentlyBeneathThreshold == True):
				allChannelsBeneathThresholdDuration = allChannelsBeneathThresholdDuration + 1

				if (allChannelsBeneathThresholdDuration >= duration):
					currentlyWriting = False
					outputFile.close()
			else:
					allChannelsBeneathThresholdDuration = 0

		else:
			# We're not currently writing
			if (allChannelsCurrentlyBeneathThreshold == False):
				currentlyWriting = True
				allChannelsBeneathThresholdDuration = 0
				outputFilenameNumber = outputFilenameNumber + 1
				outputFilename = str(outputFilenameNumber)
				outputFilename = outputFilename.zfill(2) # Pad to 2 digits(find which digits are padding )
				outputFilename = outputFilenamePrefix + 'part' + outputFilename + '.wav'
				print('Writing to', outputFilename)
				outputFile = wave.open(outputFilename, 'w')
				outputFile.setnchannels(inputFile.getnchannels())
				outputFile.setsampwidth(inputFile.getsampwidth())
				outputFile.setframerate(inputFile.getframerate())

	if (currentlyWriting == True):
		outputFile.close()

	if (delete == True):
		print('Deleting', inputFilename)
		os.unlink(inputFilename)

print(inputFilename, "finished splitting")
