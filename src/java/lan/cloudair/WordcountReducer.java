package lan.cloudair;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
//This is a standard list of imports for the Reducer

/**
 *  WordcountReducer. The WordcountReducer class extends Reducer 
 *  which is a generic class. You must set parameters for 
 *  Key In, Value In, Key Out, Value Out. The input is Text 
 *  for key in, IntWritable for value in and the output is Text 
 *  for key out, IntWritable for value out.
 *  Absolutely must have alignment of data types for map key out/value 
 *  out with reduce key in/value in.
 */

/*
 * The Reducer subclass extends the Reducer base class. The four generic
 * data types parameters are Text for Key in, IntWritable for Value in,
 * Text for Key out, and IntWritable for Value out.
 */
public class WordcountReducer 
		extends Reducer<Text, IntWritable, Text, IntWritable> {
	
	/*
	 * The reduce() method receives the intermediate data for the key
	 * and value. The Value in is an Iterable collection of objects. 
	 * The Context object passes in Hadoop parameters required for the 
	 * application.
	 */
	public void reduce(Text key, Iterable<IntWritable> values, Context context)
			throws IOException, InterruptedException {
			
		//Set sum to 0
		int sum = 0;
			
		/*
		 * Foreach loop inputs an array of values to be counted.
		 * val.get() retrieves the actual numeric value on each
		 * iteration.
		 */
		for ( IntWritable val : values ) {
			sum += val.get();
		}
		/*
		 * Context write() method emits out the key, a word, and 
		 * the value, which is sum.
		 */
		context.write( key,  new IntWritable( sum ) );
	}
		
}

