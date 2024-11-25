module Lib
    ( fromSql,
      toSql
    ) where

import PostgresqlSyntax.Parsing(run, preparableStmt)
import PostgresqlSyntax.Ast
import qualified Ast
import qualified Parsing
import qualified PostgresqlSyntax.Rendering as Rendering
import Data.Text 
import Data.List.NonEmpty

fromSql :: String -> String
fromSql = withText fromSql'

toSql :: String -> String
toSql = withText toSql'

withText :: (Text->Text) -> (String->String)
withText f = (unpack . f . pack)

fromSql' :: Text ->  Text
fromSql' = render . parseSql

toSql' :: Text ->  Text
toSql' = render . transformSoSql . parseSoSql 

parseSql :: Text -> Either String PreparableStmt
parseSql = run preparableStmt

parseSoSql :: Text -> Either String Ast.SoClause
parseSoSql = run Parsing.soClause

transformSoSql :: Either String Ast.SoClause -> Either String PreparableStmt
transformSoSql = fmap transformSoClause

transformSoClause :: Ast.SoClause -> PreparableStmt

render ::  Either String PreparableStmt-> Text
render (Left msg) = pack msg
render (Right ast) = Rendering.toText $ Rendering.preparableStmt  ast


