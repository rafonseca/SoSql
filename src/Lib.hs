module Lib
    ( fromSql,
      fromSql'
    ) where

import PostgresqlSyntax.Parsing(run, preparableStmt)
import qualified Ast
import qualified PostgresqlSyntax.Rendering as Rendering
import Data.Text 

fromSql :: String -> String
fromSql inp  = unpack $ fromSql' $ pack inp

fromSql' :: Text ->  Text
fromSql' = render . parse

parse :: Text -> Either String Ast.PreparableStmt
parse = run preparableStmt

render :: Either String Ast.PreparableStmt -> Text
render (Left msg) = pack msg
render (Right ast) = Rendering.toText $ Rendering.preparableStmt  ast
