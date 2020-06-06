package lan.cloudair;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

/**
 * WordCount:WordCount program consists of Mapper class and the 
 * Reducer class, plus a set of driver instructions to configure 
 * and run the job. In this case the driver instructions are 
 * contained within the master class WordCountDriver. 
 * 
 * The job specifies TextInputFormat for the input data, this submits 
 * the key as a line number in the text file  and the value is the line of
 * text. The Mapper does not make use of the key. 
 * The Mapper is executed once for each line of text. It takes the line of 
 * text and breaks it into words using " " as the split. The Mapper then uses 
 * the Context object to emit <word, 1>, ( K2/V2 values ) into the Reducer. 
 * The Reducer us executed once for each key/value. The Reducer counts the 
 * number of Iterable objects. It emits <word, count>, ( K3/V3 values ).
 */

public class WordCount {
	
	public static void main( String[] args ) throws Exception {
		
		/**
		 * Configuration data type for data reference conf, the constructor
		 * sets all of the configurations for Hadoop.
		 */
		Configuration conf = new Configuration();
		
		/**
		 * The Job data type for data reference job, the Job.getInstance()
		 * method instantiates the job object, it inputs the conf to 
		 * obtain all of the configuration for Hadoop and it assigns 
		 * a name to the job, "WordCount Job".
		 */
		Job job = Job.getInstance( conf, "WordCount Job" );
		
		/**
		 * FileInput and FileOutput sets the input and output
		 * paths for the job.
		 */
		FileInputFormat.addInputPath( job, new Path( args[0] ) );
		FileOutputFormat.setOutputPath( job, new Path( args[1] ) );
		
		/**
		 * The job.set() methods set all of the required parameters
		 * to configure and run the job. This list shows the
		 * minimum required parameters to run a successful job.
		 */
		job.setJarByClass( WordCount.class );
	   job.setMapperClass( WordCountMapper.class );
	   
		job.setReducerClass( WordCountReducer.class );	
		job.setOutputKeyClass( Text.class );
		job.setOutputValueClass( IntWritable.class );
		
		/**
		 * The tertiary operator is used set the success/failure
		 * value for System.exit ( 0 or 1 ). The job.waitForCompletion()
		 * method runs the job and streams out the progress of the job.
		 */
		System.exit( job.waitForCompletion( true ) ? 0 : 1 );
	}
	
}

