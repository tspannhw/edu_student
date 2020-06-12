/*
  To compile this source file, the Apache Spark libraries will need to be in the classpath.
  $ mkdir java8_example
  $ javac -d java8_example/ -classpath /usr/lib/spark/lib/spark-assembly.jar SparkBasicsJava8.java
  $ ls java8_example
*/

package example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

import java.util.List;


public final class SparkBasicsJava8 {

  public static void main(String[] args) throws Exception {

    if (args.length < 1) {
      System.err.println("Usage: JavaWordCount <file>");
      System.exit(1);
    }

    SparkConf sparkConf = new SparkConf().setAppName("SparkBasicsJava8");
    JavaSparkContext ctx = new JavaSparkContext(sparkConf);
    JavaRDD<String> mydata = ctx.textFile(args[0], 1);

    JavaRDD<String> mydata_uc = mydata.map(line -> line.toUpperCase());

    JavaRDD<String> mydata_filt = mydata_uc.filter(line -> line.startsWith("I"));

    for (String line : mydata_filt.collect()) {
      System.out.println(line);
    }

    ctx.stop();
  }
}