{-# LANGUAGE DeriveGeneric #-}

module Ast (SoClause(..),TargetEl(..))
  where

import PostgresqlSyntax.Ast
import Data.List.NonEmpty
import GHC.Generics (Generic)

data SoClause = SoClause (NonEmpty CommonTableExpr)
  deriving (Show, Generic,  Eq, Ord)

