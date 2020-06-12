import sys
from pyspark import SparkContext
import xml.etree.ElementTree as ElementTree

def parsefile(fileiterator):
    s = ''
    for i in fileiterator: s = s + str(i)
    yield ElementTree.fromstring(s)
    
def getDocID(e):
  for tag in e.getiterator('meta'):
    if tag.get('name') == 'docid': return tag.get('content')
  return ''
        
def getTitle(e): e.find('head').find('title').text


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print >> sys.stderr, "Usage: IndexKB.py <files>"
        exit(-1)
    sc = SparkContext()

    # knowledge base articles
    kbfiles = sys.argv[1]
    
    #kbfiles="file:/home/training/training_materials/data/kb/*")


    kbs = sc.textFile(kbfiles)
    kbtrees = kbs.mapPartitions(lambda file: parsefile(file))
    kbdocs = kbtrees.map(lambda kb: (getDocID(kb),getTitle(kb))

import re

dict(map(lambda l: l.split(':'),open('kblist')))
re.search(r'GET\s*/(KBDOC-[0-9]*)\.\w*',test1).group(1)

logs.filter(lambda s: '/KBDOC-' in s).map(lambda s: re.search(r'GET\s*/(KBDOC-[0-9]*)\.\w*',s).group(1)).take(10)

