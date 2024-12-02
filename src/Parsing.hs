{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Parsing (soClause) where

import Prelude
import HeadedMegaparsec 
import PostgresqlSyntax.Parsing
import Ast
import Data.List.NonEmpty

import Control.Applicative.Combinators hiding (some)
import Text.Megaparsec (Stream)
import qualified Text.Megaparsec as Megaparsec
import qualified Text.Megaparsec.Char as MegaparsecChar
import PostgresqlSyntax.Extras.HeadedMegaparsec(space, space1, sep1, string)
import Data.Text(pack)


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
