////////////////////////////////////////////////////////////////////////
//
// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
// CONSTRAINTS AND INDEXES
//
// 1. Create unique constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT n.property IS UNIQUE;
//
// 2. Create a single-property index
// CREATE INDEX ON :Label(property);
//
// 3. Create a composite index
// CREATE INDEX ON :Label(prop1, …​, propN);
//
// 4. Create node property existence constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT EXISTS(n.property);
//
// 5. Create relationship property existence constraint
// CREATE CONSTRAINT ON ()-[r:relationshipType]-() ASSERT EXISTS(r.property);
//
// 6. Create a Node Key
// ASSERT (variable.propertyName_1, …​, variable.propertyName_n) IS NODE KEY;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Document
CREATE CONSTRAINT ON (n:D) ASSERT n.uid IS UNIQUE;
// - uid: the unique identifier of a document (e.g. file name)
//
// Sentence
CREATE CONSTRAINT ON (n:S) ASSERT n.c IS UNIQUE;
// - c is the textual content, it is unique and indexed
CREATE INDEX ON :S(s);
// - s is the sentiment score, it is an indexed integer
CREATE INDEX ON :S(n);
// - n is the numner of occurences of the sentence
//
// Named Entity
CREATE CONSTRAINT ON (n:NE) ASSERT n.c IS UNIQUE;
// - c is the textual content, it is unique and indexed
CREATE CONSTRAINT ON (n:CARDINAL) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:DATE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:EVENT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:FAC) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:GPE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:LAW) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:LANGUAGE) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:LOC) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:MONEY) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:NORP) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:ORDINAL) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:ORG) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:PERCENT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:PERSON) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:PRODUCT) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:QUANTITY) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:TIME) ASSERT n.c IS UNIQUE;
CREATE CONSTRAINT ON (n:WORK_OF_ART) ASSERT n.c IS UNIQUE;
// - the entity type label (18 named entity types, e.g. PERSON)
CREATE INDEX ON :NE(n);
// - n is the number of occurences of the entity
//
// Key Phrase
CREATE CONSTRAINT ON (n:KP) ASSERT n.c IS UNIQUE;
// - c is the textual content, it is unique and indexed
CREATE INDEX ON :KP(n);
// - n is the numner of occurences of the key phrase
//
// Lemmatized word
CREATE CONSTRAINT ON (n:LW) ASSERT n.l IS UNIQUE;
// - l is the lemma form of the text, it is unique and indexed
CREATE INDEX ON :LW(n);
// - n is the numner of occurences of the key phrase
//
// Note: (d:D)-[:HAS_NE {n: 2}]->(e:E) means
// that the entity appears twice in the document
//
// Note: (d:D)-[:HAS_KP {n: 2}]->(k:KP) means
// that the key phrase appears twice in the sentence
//
// Note: (e:E)-[:HAS_LW {c: "communities"}]->(w:Word {l: "community"})
// means the word "communities" appears in the entity and stored as lemmatized
//
// Note: (k:KP)-[:HAS_LW {c: "communities"}]->(w:Word {l: "community"})
// means the word "communities" appears in the entity and stored as lemmatized
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all constraints
CALL db.constraints();
//
// List all indexes
CALL db.indexes();
//
// Wait for all indexes online
CALL db.awaitIndexes();
//
////////////////////////////////////////////////////////////////////////
