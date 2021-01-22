# Proof of Concept
## Pacific Salmon Knowledge Graph Initiative

### A. Overview
DFO’s Pacific Salmon Strategy (PSS) is a multi-branch initiative that seeks to transform the governance, management and assessment of salmon in the Pacific Region. Those leading this initiative, which is anticipated to begin in earnest in 2021, recognize the potential of a applying Knowledge Graph (KG) (or labelled property graph, e.g. Neo4j.com) technology to assist in the assembly, storage and interpretation of complex salmon-related data and information.

One focus of the initiative is on information pertaining to current salmon rebuilding activities, building upon earlier KG work, including some that focused on southern BC Chinook salmon.

This **Proof of Concept** (PoC) is intended to demonstrate the value of KG technology as a means of helping to achieve the overall goals of the PSS by showcasing data processing procedures for assembly, cleaning, transformation (standardization), loading, and linking of data from text sources (e.g. reports, Word documents and Excel spreadsheets) into nodes and links in a Salmon Knowledge Graph.

### B. Quick-start

##### 1. Prerequisite

###### Step 1 - Install `Docker Desktop`/`Docker Engine`
For macOS and Windows, install [Docker Desktop](https://docs.docker.com/desktop/).

For Linux, install [Docker Engine](https://docs.docker.com/engine/).

**Important**: it is recommended that at least 6GB memory and 10GB disk space allowed for Docker Desktop. Check the `Preferences` menu-item of the `Docker` top menu icon.

###### Step 2 - Install `Docker Compose`
For all system, install [Docker Compose](https://docs.docker.com/compose/).

###### Step 3 - Install `git`
Make sure that you have `git` install on your system.

- For Windows: Download [Git for Windows](https://git-scm.com/download/win) and install it.

- For macOS: install [homebrew](https://brew.sh), and then in Terminal:

      brew install git

- For Debian-based Linux:

      sudo apt update
      sudo apt upgrade
      sudo apt install git


- For RPM-based Linux:

      sudo yum upgrade
      sudo yum install git

It is likely already installed if it is a mac

###### Step 4 - Install `pskgi_poc` (this repository):
Check out the [repo](https://github.com/nghia71/pskgi_poc) by opening a Terminal or Command Prompt on your system, go to a directory where you want to place this repository, and type:

    git clone https://github.com/nghia71/pskgi_poc.git
    cd pskgi_poc

##### 2. Setting up the Dockers:

Make sure that all requirements in `1. Prerequisite` are satisfied.
It it **important** to note that all `docker` and `docker-compose` command must be execute inside the `pskgi_poc` repo directory, where the `docker-compose.yml` is present.

###### a. Build the docker images, create the containers, and run them:

For the first time:

    docker-compose up --build

Subsequent invocations:

    docker-compose up

Add a `-d` option if you want them run in the background

    docker-compose up -d --build
    docker-compose up -d

*Note: it will takes sometimes to download `PyTorch` (700MB), and neural English language models for `stanza`.*

###### b. Stop the running containers

If they are running on the console (i.e. without `-d` option). Press `Ctrl+C` to gracefully shutdown.

    docker-compose down

###### c. Removing unused images

    docker image prune

*Note: it is worth to run because it can remove over 3.5GB temporary data produced during the build of the docker image*

##### 3. Using the Dockers:

##### a. `nlp`:

Assume that you are in `pskgi_poc` directory, check if it's running:

    cd test
    ./check_nlp.sh

If the script prints `"OK"`, the service is ready, then test it with proper input. You should see `json` output on the console.

    cd test
    ./test_nlp.sh http://127.0.0.1:8000/process/ nlp_input.txt

*Note: see the Input and Output sections of the Natural Language Processing (NLP) micro service for more details*

### C. System Architecture

TBD

### D. Components

#### 1. Natural Language Processing (NLP) micro service

This NLP micro service (`nlp`) is to provide an internal feature that:
- accept `human language text` in plain textual Unicode format with UTF-8 encoding.
- convert given text into lists of sentences and words, to generate base forms of those words, their parts of speech and morphological features, to give a syntactic structure dependency parse, and to recognize named entities.
- assemble extracted `key phrases` (based on customizable *syntactic treebank annotations*), `named entities`, and `sentiment score` into json objects as result.

The *back-end* of `nlp` incorporates [Stanza](https://stanfordnlp.github.io/stanza/), a Python natural language analysis package, which is built with highly accurate neural network components that also enable efficient training and evaluation with your own annotated data. The modules are built on top of the [PyTorch](https://pytorch.org) library. Stanza also provides the official Python wrapper for accessing [the Java Stanford CoreNLP package](https://stanfordnlp.github.io/CoreNLP/).

The *front-end* of `nlp` is a lightweight web server based on [Uvicorn](https://www.uvicorn.org), a fast `ASGI` (*Asynchronous Server Gateway Interface*). It accepts HTTP requests, forwards them to the back-end, and returns responses coming back from the back-end to the caller.

##### Input
How input is submitted to `nlp`:
- a HTTP POST request to **http://`HOST_NAME`:8000/process/**
- A `json` document formatted as below must be sent in the `request's body`

      ####################
      # Define the document model that the webapp receives from submission:
      # It is a json format:
      # {
      #   "u": the uid of the document, the webapp retains and returns it
      #   "c": the textual content of the document.
      # }

##### Output:
`nlp` processes the document and extracts:
- `sentiment score`
- `named entities` (18 named entity types
described [here](https://stanfordnlp.github.io/stanza/available_models.html).
- `noun phrases` based on given *treebank annotations* that is configurable
in *conf/app.ini*, section *key_phrase*, entry *grammar*.

  Output is a `json` document in following format:

      {
          'et': list of extracted entities (see below)
          'st': list of sentence data (see below)
      }

  A sentence data is represented by a dictionary:

      {
          'ot': the original text of the sentence,
          'sm': the sentiment score (0, 1, 2), as a string
          'kp': list of extracted key phrases, for format see below
      }

  Extracted entities of a document is a list of dictionaries:

      {
          't': the entity type, one of the 18 named entity types, e.g. PERSON
          'c': the textual content, for example `First Nations`
          'l': list of lemmatized forms of the entity's words
      }

  Extracted key phrases of a sentence is a list of dictionaries:

    {
        'c': the textual content, e.g. `restoration stock assessment activities`
        'l': lemmatized forms, e.g ['restoration', 'stock', 'assessment', 'activity']
    }

    *Note: a key phrase is collected from a sentence by using treebank-specific grammar on the `xpos` property of each word in a sentence:*

      JJ? ((VB[G|N|D]|NN[P]?[S]?) (HYPH|IN|POS)*)* NN[P]?[S]?

##### Sample input & output:

Sample input from [PSF](https://www.psf.ca/news-media/238056-granted-16-south-vancouver-island-salmon-community-projects-pacific-salmon), this can be located at `test/nlp_input.txt`

    {
        "u":"123",
        "c":"The Pacific Salmon Foundation (PSF) announces grants for 16 projects in the South Vancouver Island region, totalling $238,056 through the PSF Community Salmon Program (CSP). The total value of the projects, which includes community fundraising, contributions and volunteer time, is $1,488,711 and is focused on the rehabilitation of key Pacific salmon habitats and stock enhancement in the South Vancouver Island area."
    }

Output

    {
       "p" : {
          "et" : [
             {
                "c" : "The Pacific Salmon Foundation (PSF)",
                "l" : [
                   "the",
                   "pacific",
                   "salmon",
                   "foundation",
                   "(",
                   "psf",
                   ")"
                ],
                "t" : "ORG"
             },
             {
                "c" : "16",
                "l" : [
                   "16"
                ],
                "t" : "CARDINAL"
             },
             {
                "c" : "South Vancouver Island",
                "l" : [
                   "south",
                   "vancouver",
                   "island"
                ],
                "t" : "LOC"
             },
             {
                "c" : "238,056",
                "l" : [
                   "238,056"
                ],
                "t" : "MONEY"
             },
             {
                "c" : "the PSF Community Salmon Program",
                "l" : [
                   "the",
                   "psf",
                   "community",
                   "salmon",
                   "program"
                ],
                "t" : "ORG"
             },
             {
                "c" : "CSP",
                "l" : [
                   "csp"
                ],
                "t" : "ORG"
             },
             {
                "c" : "1,488,711",
                "l" : [
                   "1,488,711"
                ],
                "t" : "MONEY"
             },
             {
                "c" : "Pacific",
                "l" : [
                   "pacific"
                ],
                "t" : "LOC"
             },
             {
                "c" : "South Vancouver Island",
                "l" : [
                   "south",
                   "vancouver",
                   "island"
                ],
                "t" : "LOC"
             }
          ],
          "st" : [
             {
                "kp" : [
                   {
                      "c" : "Pacific Salmon Foundation",
                      "l" : [
                         "pacific",
                         "salmon",
                         "foundation"
                      ]
                   },
                   {
                      "c" : "PSF",
                      "l" : [
                         "psf"
                      ]
                   },
                   {
                      "c" : "grants",
                      "l" : [
                         "grant"
                      ]
                   },
                   {
                      "c" : "projects",
                      "l" : [
                         "project"
                      ]
                   },
                   {
                      "c" : "South Vancouver Island region",
                      "l" : [
                         "south",
                         "vancouver",
                         "island",
                         "region"
                      ]
                   },
                   {
                      "c" : "PSF Community Salmon Program",
                      "l" : [
                         "psf",
                         "community",
                         "salmon",
                         "program"
                      ]
                   },
                   {
                      "c" : "CSP",
                      "l" : [
                         "csp"
                      ]
                   }
                ],
                "ot" : "The Pacific Salmon Foundation (PSF) announces grants for 16 projects in the South Vancouver Island region, totalling $238,056 through the PSF Community Salmon Program (CSP).",
                "sm" : 1
             },
             {
                "kp" : [
                   {
                      "c" : "total value",
                      "l" : [
                         "total",
                         "value"
                      ]
                   },
                   {
                      "c" : "projects",
                      "l" : [
                         "project"
                      ]
                   },
                   {
                      "c" : "community fundraising",
                      "l" : [
                         "community",
                         "fundraising"
                      ]
                   },
                   {
                      "c" : "contributions",
                      "l" : [
                         "contribution"
                      ]
                   },
                   {
                      "c" : "volunteer time",
                      "l" : [
                         "volunteer",
                         "time"
                      ]
                   },
                   {
                      "c" : "rehabilitation",
                      "l" : [
                         "rehabilitation"
                      ]
                   },
                   {
                      "c" : "key Pacific salmon habitats",
                      "l" : [
                         "key",
                         "pacific",
                         "salmon",
                         "habitat"
                      ]
                   },
                   {
                      "c" : "stock enhancement",
                      "l" : [
                         "stock",
                         "enhancement"
                      ]
                   },
                   {
                      "c" : "South Vancouver Island area",
                      "l" : [
                         "south",
                         "vancouver",
                         "island",
                         "area"
                      ]
                   }
                ],
                "ot" : "The total value of the projects, which includes community fundraising, contributions and volunteer time, is $1,488,711 and is focused on the rehabilitation of key Pacific salmon habitats and stock enhancement in the South Vancouver Island area.",
                "sm" : 2
             }
          ]
       },
       "u" : "123"
    }
