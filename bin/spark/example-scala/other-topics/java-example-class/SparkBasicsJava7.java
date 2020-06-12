/*
  To compile this source file, the Apache Spark libraries will need to be in the classpath.
  $ mkdir java7_example
  $ javac -d java7_example/ -classpath /usr/lib/spark/lib/spark-assembly.jar SparkBasicsJava7.java
  $ ls java7_example
*/

package example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

import java.util.List;


public final class SparkBasicsJava7 {

  public static void main(String[] args) throws Exception {

    if (args.length < 1) {
      System.err.println("Usage: JavaWordCount <file>");
      System.exit(1);
    }

    SparkConf sparkConf = new SparkConf().setAppName("JavaSparkBasics");
    JavaSparkContext ctx = new JavaSparkContext(sparkConf);
    JavaRDD<String> mydata = ctx.textFile(args[0], 1);

    JavaRDD<String> mydata_uc = mydata.map(new Function<String,String>() {
      @Override
      public String call(String s) {
        return (s.toUpperCase());
      }
    });

    for (String line : mydata_uc.collect()) {
      System.out.println(line);
    }

    JavaRDD<String> mydata_filt = mydata_uc.filter(new Function<String,Boolean>() {
      @Override
      public Boolean call(String s) {
        return (s.startsWith("I"));
      }
    });

    for (String line : mydata_filt.collect()) {
      System.out.println(line);
    }

    ctx.stop();
  }
}