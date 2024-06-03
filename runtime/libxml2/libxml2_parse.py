###############################################################################
#
# DESCRIPTION :
#
# Python application for xml file parsing
# # Author:  Muhammad Farhan
#
###############################################################################

import libxml2
import sys

doc = libxml2.parseFile("test.xml")

if doc.name == "test.xml":
    print ("doc.name PASS")
else:
    print ("doc.name FAIL")

root = doc.children
if root.name == "table":
    print ("root.name PASS")
else:
    print ("root.name FAIL")
child = root.children
if child.name == "text":
    print ("child.name PASS")
else:
    print ("child.name FAIL")
doc.freeDoc()
