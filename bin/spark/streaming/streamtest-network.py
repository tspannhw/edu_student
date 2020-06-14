# Cloudera Developer Training
# This script simulates streaming data by sending the contents of a file to a socket.
# The script will wait for a connection on the specified hostname and port.  Once
# connected it will send the contents of the specified files, one line at a time, at the
# speed specified.
#
# Parameters:
#     host: the host name or IP to bind to (e.g. localhost)
#     port: the port to listen on (e.g. 1234)
#     lines-per-second: how fast to send the data
#     files: one or more files (e.g. datadirectory/*)
#
# Note: script makes no attempt to recover from a broken connection; restart the script.

import sys
import time
import socket

if __name__ == "__main__":
  if len(sys.argv) < 4:
    print >> sys.stderr, "Usage: streamtest.py <host> <port> <lines-per-second> <files>"
    exit(-1)

  host = sys.argv[1]
  port = int(sys.argv[2])
  sleeptime = 1/float(sys.argv[3])
  filelist = sys.argv[4:]
  
  serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  serversocket.bind((host,port))
  serversocket.listen(1)

  while(1):
    print "Waiting for connection on",host,":",port
    (clientsocket,address) = serversocket.accept()
    print "Connection from",address
    print "Streaming data from files",filelist
    for filename in filelist: 
      print "Sending",filename
      for line in open(filename): 
        print line
        clientsocket.send(line)
        time.sleep(sleeptime)

