-- =============================================================================
-- Core Schema: People, Organizations, and Relationships
-- Version: 001
-- Description: Core entities shared across all plugins. Based on CEDS.
-- =============================================================================

CREATE TABLE IF NOT EXISTS Person (
    PersonIdentifier            TEXT NOT NULL PRIMARY KEY,
    FirstName                   TEXT NOT NULL,
    LastName                    TEXT NOT NULL,
    Birthdate                   TEXT,
    Sex                         TEXT,
    CreatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_Person_Sex CHECK (Sex IS NULL OR Sex IN ('Male', 'Female', 'Not Selected'))
);

CREATE TABLE IF NOT EXISTS Organization (
    OrganizationIdentifier      TEXT NOT NULL PRIMARY KEY,
    Name                        TEXT NOT NULL,
    Street                      TEXT,
    City                        TEXT,
    State                       TEXT,
    PostalCode                  TEXT,
    CreatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt                   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS GuardianRelationship (
    StudentPersonIdentifier     TEXT NOT NULL,
    GuardianPersonIdentifier    TEXT NOT NULL,
    RelationshipToStudent       TEXT NOT NULL,
    PRIMARY KEY (StudentPersonIdentifier, GuardianPersonIdentifier),
    FOREIGN KEY (StudentPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    FOREIGN KEY (GuardianPersonIdentifier) REFERENCES Person(PersonIdentifier) ON DELETE CASCADE,
    CONSTRAINT chk_GuardianRelationship CHECK (RelationshipToStudent IN ('Mother', 'Father', 'Guardian', 'Grandparent', 'Other'))
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_person_name ON Person (LastName, FirstName);
