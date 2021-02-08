////////////////////////////////////////////////////////////////////////////////
// Load the json file contains list of pdf files from the import/ directory
//
CALL apoc.load.json($json_file)
  YIELD value
WITH COLLECT(value) AS file_list
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Extract text from the pdf file placed in the import/ directory
//
WITH input CALL apoc.load.jsonParams($extractor_service, {method: "POST"}, apoc.convert.toJson(file_list))
  YIELD value
WITH COLLECT(value) AS input
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Call the nlp micro service to process the documents.
//
WITH input CALL apoc.load.jsonParams($nlp_service, {method: "POST"}, apoc.convert.toJson(input))
    YIELD value
WITH value
  UNWIND value AS document
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Process each document and its sentences
// - create a D node with given uid AS key
// - create an S node for each sentence, update counter
//
WITH document
  MERGE (d:D {uid: document.u})
WITH d, document
  UNWIND document.p AS sentence
WITH d, sentence
  MERGE (s:S {c: sentence.c})
    ON CREATE SET s.n = 0, s.s = sentence.s
    ON MATCH SET s.n = s.n + 1
  MERGE (d)<-[r:S_IN_D]-(s)
    ON CREATE SET r.n = 0
    ON MATCH SET r.n = r.n + 1
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Process all entities of each sentence
// - create an NE node for each entity, update counter
// - add label (entity type) to the node
// - create list of LW nodes for lemmatized words, link them with the entity
//
WITH d, s, sentence
  UNWIND sentence.e AS entity
WITH d, s, sentence, entity
  MERGE (e:NE {c: entity.c})
    ON CREATE SET e.n = 0
    ON MATCH SET e.n = e.n + 1
  MERGE (s)<-[:E_IN_S]-(e)
  MERGE (d)<-[r:E_IN_D]-(e)
    ON CREATE SET r.n = 0
    ON MATCH SET r.n = r.n + 1
WITH d, s, sentence, e, entity
  CALL apoc.create.addLabels(e, [entity.t]) YIELD node
WITH d, s, sentence, node AS e, entity
  UNWIND entity.w AS word
    MERGE (w:LW {l: word.l})
      ON CREATE SET w.n = 0
      ON MATCH SET w.n = w.n + 1
    MERGE (e)<-[r:W_IN_E]-(w)

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Process all key phrases of each sentence
// - create an KP node for each entity, update counter
// - create list of LW nodes for lemmatized words, link them with the entity
//
WITH d, s, sentence
  UNWIND sentence.k AS key_phrase
WITH d, s, sentence, key_phrase
  MERGE (k:KP {c: key_phrase.c})
    ON CREATE SET k.n = 0
    ON MATCH SET k.n = k.n + 1
  MERGE (s)<-[:K_IN_S]-(k)
  MERGE (d)<-[r:K_IN_D]-(k)
    ON CREATE SET r.n = 0
    ON MATCH SET r.n = r.n + 1
WITH d, s, sentence, k, key_phrase
  UNWIND key_phrase.w AS word
    MERGE (w:LW {l: word.l})
      ON CREATE SET w.n = 0
      ON MATCH SET w.n = w.n + 1
    MERGE (k)<-[r:W_IN_K]-(w)
      ON CREATE SET r.c = word.c;
////////////////////////////////////////////////////////////////////////////////
