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
from requests import Session

from config_handler import ConfigHandler


####################
# Reading configuration from given file in relative path
config = ConfigHandler('conf/extractor.ini')
tika_url = config.get_config_option('tika', 'url')
file_dir = config.get_config_option('tika', 'dir')

####################
# Define the document model that the webapp receives from submission:
# It is a json format:
# [
#   "u": the file name of the document, the webapp retains and returns it
# ]
class Item(BaseModel):
    u: str

####################
# Create an instance of ASPI webapp provided by FastAPI
app = FastAPI()
session = Session()
session.headers.update({'Content-type': 'application/pdf'})

####################
# Useful for status report
@app.get("/")
async def root():
    return "OK"

####################
# The main entry:
# - receives a list of documents based on `BaseModel` format
# - send it content to `tika` processing pipeline
# - return to the sender processed content in following format
# [
#   {
#       "u": the uid of the document
#       "c": the extracted content
#   }
# ]
@app.post("/process/")
async def process(item_list: List[Item]):
    items = []
    for item in item_list:
        with open(file_dir + item.u, 'rb') as file:
            res = session.put(tika_url, file.read())
            items.append({ 'u': item.u, 'c':  res.text})
    return items
