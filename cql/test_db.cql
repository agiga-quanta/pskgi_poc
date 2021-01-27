CALL dbms.components()
  YIELD name, versions, edition
UNWIND versions AS version
RETURN name, version, edition;

RETURN apoc.version();

RETURN apoc.version();

RETURN $my_param;
