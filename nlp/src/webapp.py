__author__ = "Nghia Doan"
__copyright__ = "Copyright 2021"
__version__ = "0.1.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from itertools import groupby
from typing import List

from fastapi import FastAPI
from pydantic import BaseModel
import stanza

from config_handler import ConfigHandler
from post_nlp import PostProcessor


####################
# Reading configuration from given file in relative path
config = ConfigHandler('conf/nlp.ini')

####################
# Create an instance of the post processor
post_processor = PostProcessor(config)

####################
# Start `stanza`:
# - obtain the language string
# - (optional) uncomment if the language's model was not pre-downloaded
# - creates a `stanza` NLP processing pipeline, namely `nlp`
language = config.get_config_option('stanza', 'language')
# stanza.download(language)
nlp = stanza.Pipeline(language)

####################
# Define the document model that the webapp receives from submission:
# It is a json format:
# [
#   "u": the uid of the document, the webapp retains and returns it
#   "c": the textual content of the document.
# ]
class Item(BaseModel):
    u: str
    c: str

####################
# Create an instance of ASPI webapp provided by FastAPI
app = FastAPI()


####################
# Useful for status report
@app.get("/")
async def root():
    return "OK"

####################
# The main entry:
# - receives a list of documents based on `BaseModel` format
# - send it content to `nlp` processing pipeline
# - post-processing with the PostProcessor instance
# - return to the sender processed content in following format
# [
#   {
#       "u": the uid of the document
#       "p": the processed content, see PostProcessor for more information
#   }
# ]
@app.post("/process/")
async def process(item_list: List[Item]):
    return [
        {'u': item.u, 'p': post_processor.process(nlp(item.c))}
        for item in item_list
    ]
