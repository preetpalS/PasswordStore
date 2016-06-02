CREATE TABLE targets(
    id INTEGER PRIMARY KEY NOT NULL,
    target TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME
);

CREATE TABLE hashes(
    id INTEGER PRIMARY KEY NOT NULL,
    hash TEXT NOT NULL,
    target_id INTEGER NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME,
    FOREIGN KEY (target_id) REFERENCES targets(id)
);
