-- SPDX-License-Identifier: MIT
-- Copyright (c) 2020 Gennady Trafimenkov

CREATE DATABASE cphtest;
CREATE USER cphtestuser WITH /*ENCRYPTED*/ PASSWORD 'django';
ALTER ROLE cphtestuser SET client_encoding TO 'utf8';
ALTER ROLE cphtestuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE cphtestuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE cphtest TO cphtestuser;
