CREATE TABLE IF NOT EXISTS public.offer (
  id      integer PRIMARY KEY,
  lot     decimal not null default 0,
  lotGem  character varying(40),
  bid     decimal not null default 0,
  bidGem  character varying(40),
  maker   character varying(40),
  era     integer
);

CREATE SCHEMA IF NOT EXISTS dict;

DROP TABLE IF EXISTS dict.market CASCADE;

CREATE TABLE dict.market (
  id    character varying(10) primary key,
  base  character varying(10),
  quote character varying(10)
);

INSERT INTO dict.market (id, base, quote) VALUES
  ('WETHDAI', 'WETH', 'DAI'),
  ('MKRDAI', 'MKR', 'DAI'),
  ('MKRWETH', 'MKR', 'WETH');

DROP TABLE IF EXISTS dict.token CASCADE;

CREATE TABLE dict.token (
  symbol   character varying(5) unique not null,
  key      character varying(42) unique not null,
  decimals integer,
  chain    character varying(10)
);

INSERT INTO dict.token (symbol, key, decimals, chain) VALUES
  ('WETH', 'C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 18, 'mainnet'),
  ('DAI',  '89d24A6b4CcB1B6fAA2625fE562bDD9a23260359', 18, 'mainnet'),
  ('MKR',  '9f8F72aA9304c8B593d555F12eF6589cC3A579A2', 18, 'mainnet');

CREATE SCHEMA IF NOT EXISTS api;

CREATE OR REPLACE VIEW api.offer AS (
  SELECT
    o.id,
    o.lot,
    o.lotGem,
    o.bid,
    o.bidGem,
    o.maker,
    o.era,
    COALESCE(lotToken.symbol, 'XXX') AS lotSymbol,
    COALESCE(bidToken.symbol, 'XXX') AS bidSymbol,
    (
      CASE WHEN m.base = lotToken.symbol THEN o.bid / o.lot
      WHEN m.base = bidToken.symbol THEN o.lot / o.bid
      ELSE NULL
      END
    ) AS price,
    (
      CASE WHEN m.base = lotToken.symbol THEN 'ask'
      WHEN m.base = bidToken.symbol THEN 'bid'
      ELSE NULL
      END
    ) AS type,
    m.id as market
  FROM public.offer o
  LEFT JOIN dict.token lotToken ON LOWER(lotToken.key) = o.lotGem
  LEFT JOIN dict.token bidToken ON LOWER(bidToken.key) = o.bidGem
  LEFT JOIN dict.market m
  ON (lotToken.symbol = m.base AND bidToken.symbol = m.quote)
  OR (bidToken.symbol = m.base AND lotToken.symbol = m.quote)
);

