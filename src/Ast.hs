{-# LANGUAGE DeriveGeneric #-}

module Ast (SoClause(..),TargetEl(..),CommonTableExpr'(..))
  where

import Prelude

import PostgresqlSyntax.Ast
import Data.List.NonEmpty
import GHC.Generics (Generic)

data CommonTableExpr' = CommonTableExpr' (Maybe Ident) (Maybe (NonEmpty Ident)) (Maybe Bool) PreparableStmt
  deriving (Show, Generic, Eq, Ord)


data SoClause = SoClause (NonEmpty CommonTableExpr')
  deriving (Show, Generic,  Eq, Ord)

