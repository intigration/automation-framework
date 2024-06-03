
###############################################################################
#
# DESCRIPTION :
#
# Verify xpath file parsing of libxml2 package
# # Author:  Muhammad Farhan
#
###############################################################################


import libxml2
import sys

doc = libxml2.parseFile("test.xml")
ctxt = doc.xpathNewContext()
res = ctxt.xpathEval("//*")
print (res)
if len(res) == 23:
    print ("xpath query: node set size PASS")
else:
    print("xpath query: node set size FAIL")
if res[0].name == "table" or res[1].name == "title":
    print ("xpath query: node set value PASS")
else:
    print("xpath query: node set value FAIL")
doc.freeDoc()
ctxt.xpathFreeContext()
