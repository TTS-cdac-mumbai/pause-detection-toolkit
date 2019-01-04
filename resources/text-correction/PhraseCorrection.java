
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;
import java.util.TreeSet;


/**
 *
 * @author prakash Pimpale, prakash@cdac.in/pbpimpale@gmail.com
 */
public class PhraseCorrection {

    private static String correctSent = null;
    private static String toCorrectSent = null;
    private static String correctedSent = null;
    private static TreeSet<String> grams = null;
//    private static String text

    private static String[] tokenize(String str) {
        return str.split("\\s+");
    }

    private static int sentenceLength(String[] sent) {
        return sent.length;
    }

    public static int levenshteinDistance(CharSequence lhs, CharSequence rhs) {
        int len0 = lhs.length() + 1;
        int len1 = rhs.length() + 1;

        // the array of distances                                                       
        int[] cost = new int[len0];
        int[] newcost = new int[len0];

        // initial cost of skipping prefix in String s0                                 
        for (int i = 0; i < len0; i++) {
            cost[i] = i;
        }

        // dynamically computing the array of distances                                  
        // transformation cost for each letter in s1                                    
        for (int j = 1; j < len1; j++) {
            // initial cost of skipping prefix in String s1                             
            newcost[0] = j;

            // transformation cost for each letter in s0                                
            for (int i = 1; i < len0; i++) {
                // matching current letters in both strings                             
                int match = (lhs.charAt(i - 1) == rhs.charAt(j - 1)) ? 0 : 1;

                // computing cost for each transformation                               
                int cost_replace = cost[i - 1] + match;
                int cost_insert = cost[i] + 1;
                int cost_delete = newcost[i - 1] + 1;

                // keep minimum cost                                                    
                newcost[i] = Math.min(Math.min(cost_insert, cost_delete), cost_replace);
            }

            // swap cost/newcost arrays                                                 
            int[] swap = cost;
            cost = newcost;
            newcost = swap;
        }

        // the distance is the cost for transforming all letters in both strings        
        return cost[len0 - 1];
    }

    public static List<String> ngrams(int n, String sentence) {
        String[] tokens = sentence.trim().split("\\s+");
        int len = tokens.length;

        List<String> ngrams = new ArrayList<String>();
        for (int i = 0; i < len - n + 1; i++) {
            StringBuilder gram = new StringBuilder();
            for (int j = i; j < i + n; j++) {
                gram.append(tokens[j]).append(" ");
                // System.out.print(tokens[j]+" ");
            }
            ngrams.add(gram.toString().trim());
            //System.out.println();
        }
        return ngrams;
    }

    private static void performCorrect() {
        /* Perform tokenization on both sentences. get correct sentence length. perform sentence length n-grams - from 1 to n split the tocorrect sentence into phrases
         perform phrase level correction by looping over every phrase by finding out the least character distance of the current phrase with one of the n-grams from list of the n-grams
         the one with the least distance pharse is the correct version of the phrase. Create the sentence with the corrected phrases. Remove all commas and compare with the correct sentence and they should match, just to confirm.
         return corrected sentence or write to file
         */
        correctedSent = "";
        String correctedSentTemp = "";
        String[] scor = tokenize(correctSent);
        int lscor = sentenceLength(scor);
        //generate n-grams from correct sentence
        grams = new TreeSet();
        for (int i = 1; i <= lscor; i++) {
            List gramlist = ngrams(i, correctSent);
            grams.addAll(gramlist);
        }

        //Phrase Split for processing
        String[] s2cor = toCorrectSent.split(",");
        //loop over all these phrases for correction
        for (String phrase : s2cor) {
            phrase = phrase.trim();
	    //System.out.println("phrase ="+phrase+"\n");        
	    String corrphrase = getNearestGram(phrase);
            //no comma at start and construct the corrected sentence
            if (corrphrase != null) {
                correctedSentTemp = constructSentence(correctedSentTemp, corrphrase);
            } else {
                correctedSentTemp = constructSentence(correctedSentTemp, phrase);
            }

            //final assignment
            correctedSent = correctedSentTemp;
        }

    }
private static void performBackCorrect()
{
		// code to built a phrase from toCorrectSent as combining 1+1 word till getting the exact match
		String[] toCorrectphrases=toCorrectSent.split(",");
                String[] correctedphrases=correctedSent.split(",");
                String[] correctWords=correctSent.split(" ");
		for (int i = 0; i < toCorrectphrases.length; i++)
	        {
           		// s2cor[i] = s2cor[i].trim();
				System.out.println("Atishcheck="+toCorrectphrases[i]);
       	        }
		for (int k = 0; k < correctedphrases.length; k++)
	        {
           		// s2cor[i] = s2cor[i].trim();
				System.out.println("Atishcheckcorrectedphrases="+toCorrectphrases[k]);
       	        }
                for (int j = 0; j < correctWords.length; j++)
	        {
           		// s2cor[i] = s2cor[i].trim();
				System.out.println("Atishcheckcorrectwors="+correctWords[j]);
       	        }
               
					
				//now here have to match the two phrases, if phrase match keep as it is else.. takee previous matched  phrase of corrected and take its last word in variable ..now match this word in original and start to take words from this original words up to the word of toCrrect is matched with original word(correctword [])
				
	
}

    private static void performMisMatchCorrectHistory() {
        // start over and do performCorrect again with the phrases with prev context phrase only
        //Phrase Split for processing
        String[] s2cor = toCorrectSent.split(",");
        //String[] s2cor = correctedSent.split(",");
        correctedSent = "";
       

        //trim all phrases
        for (int i = 0; i < s2cor.length; i++) {
            s2cor[i] = s2cor[i].trim();
        }

        //loop over all these phrases for correction
        String phrase = null;
         String correctedSentTemp = s2cor[0];
        //start only from phrase 1
        for (int i = 1; i < s2cor.length; i++) {

	/*
            //go ahead only if current phrase is not exact match
            if (isExactMatch(s2cor[i])) {
                  //System.out.println("Exact match found" + s2cor[i]);
                correctedSentTemp = constructSentence(correctedSentTemp, s2cor[i]);
                 //System.out.println("TEMP:" + correctedSentTemp);
                continue;
            }

*/
            //for all phrases previous as context phrase
            phrase = s2cor[i - 1] + " " + s2cor[i];
	    // phrase = A B + C K 	
            //corrected phrase with context
            String contextCorPhrase = getNearestGram(phrase);
	    // correction   A B + C D

             //System.out.println("nearest phrase context:" + contextCorPhrase);
            //if no suitable found
            String phrasei = s2cor[i];
            if (contextCorPhrase != null) {
                if (contextCorPhrase.startsWith(s2cor[i - 1])) {
                    int index = s2cor[i - 1].length();
                    phrasei = contextCorPhrase.substring(index);
                }
            }
            correctedSentTemp = constructSentence(correctedSentTemp, phrasei);
            //System.out.println("TEMP:" + correctedSentTemp);

        }
        //final assignment
        correctedSent = correctedSentTemp;
        //System.out.println("Final:" + correctedSentTemp);

    }

    
    private static String constructSentence(String correctedSentTemp, String corrphrase) {
        if (correctedSentTemp.length() < 1) {
            correctedSentTemp = corrphrase;

        } else {
            correctedSentTemp = correctedSentTemp + ", " + corrphrase;
            //System.out.println("temp corrected:" + correctedSentTemp);
        }
        return correctedSentTemp;
    }

    private static boolean isExactMatch(String phrase) {
        for (String gr : grams) {
            int dist = levenshteinDistance(phrase.trim(), gr.trim());
            if (dist == 0) {
                return true;
            }
        }
        return false;
    }

    private static String getNearestGram(String phrase) {
        int mindist = phrase.length();
        //System.out.println("initialMinDist" + mindist);
        String corrphrase = "";
        for (String gr : grams) {
            //Let's check if can we combine all the chars in phrases and ngrams
            //increases errors int dist = levenshteinDistance(phrase.trim().replaceAll("\\s+", ""), gr.trim().replaceAll("\\s+", ""));
            int dist = levenshteinDistance(phrase.trim(), gr.trim());
            //System.out.println("Dist:" + phrase + " & " + gr + ":" + dist);
            if (dist < mindist) {
                corrphrase = gr;
                mindist = dist;
                if (mindist == 0) {
                    break;
                }
            }
        }
        //System.out.println("Nearest Phrase:" + corrphrase + ":of:" + phrase + ":distance:" + mindist);
        if (corrphrase.length() > 0) {
            return corrphrase;
        } else {
            return null;
        }
    }

    private static boolean partialMatch(String constructed, String original) {
        constructed = constructed.trim().replaceAll(",", "").replaceAll("\\s+", "");
        original = original.trim().replaceAll("\\s+", "");
        return original.startsWith(constructed);
    }

    private static boolean match(String s1new, String s2or) {
        //remove , and spaces
        s1new = s1new.trim().replaceAll(",", "").replaceAll("\\s+", "");;
        s2or = s2or.trim().replaceAll("\\s+", "");
        return s1new.equals(s2or);
    }

   

    public static void main(String args[]) throws FileNotFoundException, IOException {

        Properties prop = new Properties();
        System.out.println("Path for properties file?");
        //Scanner scprop = new Scanner(System.in);
        ///home/prakash/NetBeansProjects/SentenceSimilarity/src/sentencesimilarity/path.properties
        //String propfile = scprop.nextLine().trim();
	String propfile = args[0].trim();
        
        //String propfile = "/media/rachana/sda5/prosody/pause_prediction/triedthisusingthengramapproach/path.properties";
        prop.load(new FileInputStream(propfile));
        //scprop.close();
        //System.out.println("Basepath:"+prop.getProperty("basepath"));

        String basepath = prop.getProperty("basepath");
        Scanner scCorrect = new Scanner(new File(basepath + prop.getProperty("scCorrect")));
        Scanner scTocorrect = new Scanner(new File(basepath + prop.getProperty("scTocorrect")));
        PrintWriter pwout = new PrintWriter(basepath + prop.getProperty("output"));
        PrintWriter pwcorrected_error = new PrintWriter(basepath + prop.getProperty("error_obtain_corrected"));
        PrintWriter pwcorrect_error = new PrintWriter(basepath + prop.getProperty("error_obtain_correct"));


        //Confirm the accuracy
        int mismatch = 0;
        int mismatch1=0;
        while (scTocorrect.hasNextLine()) {
            String correctSentTemp = scCorrect.nextLine().trim();
            String toCorrectSentTemp = scTocorrect.nextLine().trim();
            //correctTerminalWords();
            
	   
          
          String[] correctSentText = correctSentTemp.split("\"");
          String[] toCorrectSentText=toCorrectSentTemp.split("\"");
      /*    for (int ii=0;ii<correctSentText.length;ii++)
	 {
			System.out.println("check sent only="+ii+"="+correctSentText[ii]);
	 }
       */
	correctSent=correctSentText[1];
	toCorrectSent=toCorrectSentText[1];

	//correctSent=correctSent.replaceAll(" ",correctSentText[1]);
        //toCorrectSent=toCorrectSent.replaceAll(" ",toCorrectSentText[1]);
        //System.out.println(correctSent+"atish "+toCorrectSent);
	String textName = correctSentText[0];
        String lastString = correctSentText[2];
	


           performCorrect();
          // performBackCorrect();
            //to correct mismatch
            if (!match(correctedSent, correctSent)) {
                // System.out.println("ASR OP:" + correctedSent);
                // System.out.println("Original Sentence:" + correctSent);
                //performMisMatchCorrect();
                mismatch1++;
                performMisMatchCorrectHistory();   // have to make comment when----for otherthan 1st iteration
		//performBackCorrect();  // call this function from another if of this matching
            }

            //to count final mismatch
            if (!match(correctedSent, correctSent)) {
               // System.out.println("##");
                //System.out.println("ASR OP:" + toCorrectSent);
                //System.out.println("Original Sentence:" + correctSent);
               // System.out.println("Corrected Sentence:" + correctedSent);
		  //System.out.println(textName + "\"" + correctedSent + ".\"" + lastString);
                   pwcorrected_error.println(textName + "\"" + correctedSent + ".\"" + lastString);
                 pwcorrect_error.println(textName + "\"" + correctSent + ".\"" + lastString);

                mismatch++;
            } else {
                correctedSent = textName + "\"" + correctedSent + ".\"" + lastString;
		//System.out.println("Corrected Sentence from else:" + correctedSent);
                pwout.println(correctedSent);
		
            }
        }
        pwcorrected_error.flush();
        pwcorrected_error.close();
        pwcorrect_error.flush();
        pwcorrected_error.close();
        pwout.flush();
        pwout.close();
        scCorrect.close();
        scTocorrect.close();
        System.out.println("Total Errors in Correction in iteration1: " + mismatch1);
        System.out.println("Total Errors in Correction in iteration2: " + mismatch);

	
    }
		
}

