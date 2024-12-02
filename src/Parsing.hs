{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Parsing (soClause) where

import HeadedMegaparsec 
import PostgresqlSyntax.Parsing
import Ast
import Data.List.NonEmpty

import Control.Applicative.Combinators hiding (some)
import Text.Megaparsec (Stream)
import qualified Text.Megaparsec as Megaparsec
import qualified Text.Megaparsec.Char as MegaparsecChar

import Data.Text(pack)


-- sep1, space1, space were extracted from hidden PostgresqlSyntax.Extras.HeadedMegaparsec
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
-- |
-- Lifted megaparsec\'s `Megaparsec.space`.
space :: (Ord err, Stream strm, Megaparsec.Token strm ~ Char) => HeadedParsec err strm ()
space = parse MegaparsecChar.space

-- |
-- Lifted megaparsec\'s `Megaparsec.string`.
string :: (Ord err, Stream strm) => Megaparsec.Tokens strm -> HeadedParsec err strm (Megaparsec.Tokens strm)
string = parse . MegaparsecChar.string



commonTableExpr' = label "sosql cte" $ named_cte <|> unnamed_cte
  where
    named_cte = do
      name <- ident
      space
      string "<-"
      space
      stmt <- preparableStmt
      return (CommonTableExpr' (Just name) Nothing Nothing stmt)

    unnamed_cte = do
      space
      stmt <- preparableStmt
      return (CommonTableExpr' Nothing Nothing Nothing stmt)      


soClause :: Parser SoClause
soClause = label "so clause" $ do
  _ <- keyword "so"
  space1
  cteList <- sep1 (space *> keyword "then" *> space) commonTableExpr'
  space
  return (SoClause cteList)
