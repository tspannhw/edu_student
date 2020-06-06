Last Thursday Raphael Chazelle while prepping for tomorrows SCI-241 delivery pointed out that he was getting an error while trying to install the python interpreter ( later stated the same error was present while trying to install any interpreter).

I briefly reviewed it Thursday replicating his findings and confirming it to be a problem. After 6 hours of hunting down the source of the error on Friday I was able to isolate the issue.
The ambari installed version of Zeppelin sets the maven repository where all of the interpreters are installed from to -> http://repo1.maven.org/maven2/
If you go to that location in a web browser you will get :

501 HTTPS Required.
Use https://repo1.maven.org/maven2/
More information at https://links.sonatype.com/central/501-https-required
If you go to the link provided you will see:

Effective January 15, 2020, The Central Repository no longer supports insecure communication over plain HTTP and requires that all requests to the repository are encrypted over HTTPS.

If you're receiving this error, then you need to replace all URL references to Maven Central with their canonical HTTPS counterparts:

Replace http://repo1.maven.org/maven2/ with https://repo1.maven.org/maven2/

Replace http://repo.maven.apache.org/maven2/ with https://repo.maven.apache.org/maven2/

If for any reason your environment cannot support HTTPS, you have the option of using our dedicated insecure endpoint at http://insecure.repo1.maven.org/maven2/


This seems really simple right? Well since the location is set during the install from our official versions of the software it is not as easy as you may think.

I have found a nice easy work around and I am currently testing it for tomorrows SCI-241 delivery.
You can temporarily change the repo URL with an environment variable "export ZEPPELIN_INTERPRETER_DEP_MVNREPO=http://insecure.repo1.maven.org/maven2/"
This will allow you run your interpreter installs without error.

Now for my SME's if you already knew this you may want to grin and keep it to yourself as stated above 6 hours went into this and I may become mildly irritated :( !

This presents a problem for SCI-241 , DEV-331 and any other Courseware that consumes Zeppelin 0.8.0 or older.

Given that Ambari 2.7.5 has released and that Zeppelin 0.8.2 is now GA( I do not know if this is included in the ambari 2.7.5 stack that would need to be checked as well) further testing as to whether or not the https issue as been addressed in the later versions may be of interest to us or simply applying the fix that I am testing right now ( once it confirms that it does in fact fix the issue) to both production versions of the courses effected.

