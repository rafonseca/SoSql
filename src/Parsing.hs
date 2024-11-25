{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Parsing (soClause) where

import HeadedMegaparsec 
import PostgresqlSyntax.Parsing
import Ast
import Data.List.NonEmpty

import Control.Applicative.Combinators (many)

import Text.Megaparsec (Stream)
import qualified Text.Megaparsec as Megaparsec
import qualified Text.Megaparsec.Char as MegaparsecChar

import Data.Text(pack)

-- sep1 and space1 were extracted from hidden PostgresqlSyntax.Extras.HeadedMegaparsec
sep1 :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => HeadedParsec err strm separtor -> HeadedParsec err strm a -> HeadedParsec err strm (NonEmpty a)
sep1 separator parser = do
  head <- parser
  endHead
  tail <- many $ separator *> parser
  return (head :| tail)
-- |
-- Lifted megaparsec\'s `Megaparsec.space1`.
space1 :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => HeadedParsec err strm ()
space1 = parse MegaparsecChar.space1

soClause :: Parser SoClause
soClause = label "so clause" $ do
  _ <- keyword "also"
  space1
  cteList <- sep1 commaSeparator commonTableExpr
  return (SoClause cteList)
