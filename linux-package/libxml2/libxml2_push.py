###############################################################################
#
# DESCRIPTION :
#
# Verify push parser support of libxl2
# # Author:  Muhammad Farhan
#
###############################################################################

import libxml2

ctxt = libxml2.createPushParser(None, "<foo", 4, "test.xml")
ctxt.parseChunk("/>", 2, 1)
doc = ctxt.doc()
print (doc)
print (doc.name)
doc.freeDoc()
