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
    in conf/app.ini, section `key_phrase`, entry `grammar`.

    Extracted data of a document is represented by a list of sentences,
    each is a dictionary:
    {
        'ot': the original text of the sentence,
        'sm': the sentiment score (0, 1, 2), as a string,
        'et': list of extracted entities (see below),
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

    def filter_key_phrases(self, words):
        key_phrases = []
        id_xpos_list = ' '.join('%s_%s' % (w.id, w.xpos) for w in words)

        debug_str = ' '.join('%s_%s_%s' % (w.id, w.xpos, w.text) for w in words)
        print(debug_str)

        match = self.grammar.search(id_xpos_list)
        while match:
            s, e = match.start(), match.end()
            good_words = self.collect.findall(id_xpos_list[s:e])

            key_phrase = ' '.join(words[int(w[0])-1].text for w in good_words)
            lemma_list = [words[int(w[0])-1].lemma.lower() for w in good_words]
            key_phrases.append({'c': key_phrase, 'l': lemma_list})

            match = self.grammar.search(id_xpos_list, e+1)

        return key_phrases

    def extract_entities(self, entities):
        return [
            {'t': e.type, 'c': e.text, 'l': [w.lemma.lower() for w in e.words]}
            for e in entities
        ]

    def process(self, document):
        return [
            {
                'ot': sentence.text,
                'sm': sentence.sentiment,
                'et': self.extract_entities(document.entities),
                'kp': self.filter_key_phrases(sentence.words)
            } for sentence in document.sentences
        ]
