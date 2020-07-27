import os
import re

def walkFiles(path):
  return os.walk(path);

def walkDirs(path):
  return [x[0] for x in os.walk(path)];

def getPartitions(path):
    return []