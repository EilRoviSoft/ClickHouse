-- Tags: no-parallel, zookeeper

DROP TABLE IF EXISTS test_mutations_author_in_regular_table;
DROP TABLE IF EXSIST test_mutations_author_in_replicated_table;

CREATE TABLE test_mutations_author_in_regular_table (id UInt64, value String) ENGINE = MergeTree ORDER BY id;
CREATE TABLE test_mutations_author_in_replicated_table (id UInt64, value String) ENGINE = ReplicatedMergeTree ('/clickhouse/test_max_num_to_warn_02931/{database}/{table}', '1') ORDER BY id;

INSERT INTO test_mutations_author_in_regular_table VALUES (1, 'a'), (2, 'b'), (3, 'c');
INSERT INTO test_mutations_author_in_replicated_table VALUES (4, 'e'), (5, 'f'), (6, 'g');

SELECT name, type FROM system.columns WHERE database = 'system' AND table = 'mutations' AND name = 'author';

ALTER TABLE test_mutations_author_in_regular_table UPDATE value = 'x' WHERE id = 1;
ALTER TABLE test_mutations_author_in_replicated_table UPDATE value = 'y' WHERE id = 4;

SELECT database, table, is_done, author FROM system.mutations WHERE database = currentDatabase() AND (table = 'test_mutations_author_in_regular_table' OR table = 'test_mutations_author_in_replicated_table') ORDER BY mutation_id;

DROP TABLE test_mutations_author_in_regular_table;
DROP TABLE test_mutations_author_in_replicated_table;
