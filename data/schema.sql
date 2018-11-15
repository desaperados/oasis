CREATE TABLE IF NOT EXISTS public.offer (
  id      integer PRIMARY KEY,
  lot     decimal not null default 0,
  lotGem  character varying(40),
  bid     decimal not null default 0,
  bidGem  character varying(40),
  maker   character varying(40),
  era     integer
);

CREATE SCHEMA IF NOT EXISTS api;

CREATE OR REPLACE VIEW api.offer AS (
  SELECT
    o.id,
    o.lot,
    o.lotGem,
    o.bid,
    o.bidGem,
    o.maker,
    o.era
  FROM public.offer o
);

CREATE SCHEMA IF NOT EXISTS dict;

DROP TABLE IF EXISTS dict.market;

CREATE TABLE dict.market (
  id    character varying(10) primary key,
  base  character varying(10),
  quote character varying(10)
);

INSERT INTO dict.market (id, base, quote) VALUES
  ('WETHDAI', 'WETH', 'DAI'),
  ('MKRDAI', 'MKR', 'DAI'),
  ('MKRWETH', 'MKR', 'WETH');

DROP TABLE IF EXISTS dict.token;

CREATE TABLE dict.token (
  symbol   character varying(5) unique not null,
  key      character varying(42) unique not null,
  decimals integer,
  chain    character varying(10)
);

INSERT INTO dict.token (symbol, key, decimals, chain) VALUES
  ('WETH', '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 18, 'mainnet'),
  ('DAI',  '0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359', 18, 'mainnet'),
  ('MKR',  '0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2', 18, 'mainnet');
