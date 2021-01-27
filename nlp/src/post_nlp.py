__author__ = "Nghia Doan"
__copyright__ = "Copyright 2021"
__version__ = "0.1.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re


class PostProcessor(object):
    """
    PostProcessor receives document and nested objects, described in detailed
    here https://stanfordnlp.github.io/stanza/data_objects.html#document.

    PostProcessor extracts from the document:
    - sentiment score
    - named entities (supported by default to produce 18 named entity types
    described here https://stanfordnlp.github.io/stanza/available_models.html)
    - noun phrases based on given Tree Bank Grammar that is configurable
    in conf/nlp.ini, section `key_phrase`, entry `grammar`.

    Extracted data of a list of document is represented by a list of sentences,
    each sentence is a dictionary:
    {
        'c': the original text of the sentence,
        's': the sentiment score (0, 1, 2), as a string,
        'e': list of extracted entities (see below),
        'k': list of extracted key phrases, for format see below
    }

    Extracted entities of a sentence is a list of dictionaries:
    {
        't': the entity type, one of the 18 named entity types, e.g. PERSON
        'c': the textual content, for example `First Nations`
        'k': indicates if the entity also appears as a key phrase
        'w': list of words, each is a dictionary, see below
    }

    Extracted key phrases of a sentence is a list of dictionaries:
    {
        'c': the textual content, e.g. `restoration stock assessment activities`
        'w': list of words, each is a dictionary, see below
    }

    Extracted word in format of {'c': word text, 'l': lemmatized form}

    Note 1: a key phrase is collected from a sentence by using treebank-specific
    grammar on the `xpos` property of each word in a sentence:
        JJ? ((VB[G|N|D]|NN[P]?[S]?) (HYPH|IN|POS)*)* NN[P]?[S]?

    Note 2: the second grammar, namely `collect` is used for collecing only some
    Part-of-Speech (POS) tags and ignoring the rest. For example VBN, NN tags
    are collected but HYPN or CC are discarded when forming the key phrase.
    """

    def __init__(self, config):
        self.grammar = re.compile(config.get_config_option('key_phrase', 'grammar'))
        self.collect = re.compile(config.get_config_option('key_phrase', 'collect'))
        self.cleanup = re.compile(config.get_config_option('key_phrase', 'cleanup'))
        self.ignored = config.get_config_option('key_phrase', 'ignored').split(';')

    def filter_key_phrases(self, words):
        key_phrases = []

        # Create a list of (word index, xpos_tag), e.g. 1_NN 2_VB 3_CC 4_NNS
        id_xpos_list = ' '.join('%s_%s' % (int(w.id)-1, w.xpos) for w in words)

        match = self.grammar.search(id_xpos_list)  # Lookup based on `grammar`
        while match:
            s, e = match.start(), match.end()

            # Collect matched pair (word index, xpos_tag) based on `collect`
            good_words = [{
                'c': words[int(i)].text.lower() if 'P' not in x else words[int(i)].text,
                'l': words[int(i)].lemma.lower()
            } for i, x in self.collect.findall(id_xpos_list[s:e])]

            # Create new key phrase
            key_phrases.append({
                'c': ' '.join(w['c'] for w in good_words),
                'w': good_words
            })

            match = self.grammar.search(id_xpos_list, e+1)

        return key_phrases

    def extract_entities(self, entities):
        return [
            {
                't': e.type,
                'c': self.cleanup.sub('', e.text),
                'w': [
                    {'c': w.text, 'l': w.lemma.lower()}
                    for w in e.words if w.text.lower() not in self.ignored
                ]
            } for e in entities
        ]

    def process(self, document):
        return [
            {
                'c': sentence.text,
                's': sentence.sentiment,
                'e': self.extract_entities(document.entities),
                'k': self.filter_key_phrases(sentence.words)
            } for sentence in document.sentences
        ]
