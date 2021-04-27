package lan.cloudair;

import java.io.*;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

/**
 *  The WordcountMapper class extends Mapper which is a 
 *  generic class. You must set parameters for:
 *  	Key In, Value In, Key Out, Value Out.
 *   
 *  The input is Object for key in, Text for value in.  
 *  The output is Text for key out, IntWritable for value out.
 */

public class WordcountMapper 
		extends Mapper<Object, Text, Text, IntWritable> {
	
	//Set constant for IntWritable to 1, Set word to object Text
	private final static IntWritable one = new IntWritable( 1 );
	private Text word = new Text();
	
	//The Map method must match the object type for Key In and Value in
	public void map( Object key, Text value, Context context ) 
			throws IOException, InterruptedException {
			
		//The input text is split on the delimiter " "
		String[] words = value.toString().split( " " );
		
			//Foreach loop inputs array of words
			for ( String str : words ) {
				//Assign each word to Text variable word
				word.set( str );
				//Context write outputs word and 1
				context.write( word, one );
			}
	}
		
}
