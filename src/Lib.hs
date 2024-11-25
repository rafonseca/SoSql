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
transformSoClause soClause = let
  Ast.SoClause ctes = soClause
  with = WithClause False (fillEmptyFromClauses ctes)
  asterisk = NormalTargeting (AsteriskTargetEl :| [])
  from = RelationExprTableRef (SimpleRelationExpr (SimpleQualifiedName (QuotedIdent (pack "mystatement"))) False) Nothing Nothing
  simpleselect = NormalSimpleSelect (Just asterisk) Nothing (Just (from:|[])) Nothing Nothing Nothing Nothing
  select = SelectNoParens (Just with) (Left simpleselect) Nothing Nothing Nothing
  in SelectPreparableStmt (Left select)
   
fillEmptyFromClauses ::  NonEmpty CommonTableExpr -> NonEmpty CommonTableExpr
fillEmptyFromClauses cteExprs = let
  ctesList = toList cteExprs
  names = [name |CommonTableExpr name _ _ _ <- ctesList]
  firstCte:subsequentCtes = ctesList
  modifiedCtes = Prelude.zipWith replaceIdentInSelect names subsequentCtes
  in
  fromList (firstCte:modifiedCtes)


replaceIdentInSelect :: Ident -> CommonTableExpr -> CommonTableExpr   
replaceIdentInSelect newIdent (CommonTableExpr a b c (SelectPreparableStmt stmt)) = let
  -- WIP
  -- destructure stmt
  newStmt = undefined
  in
  CommonTableExpr a b c (SelectPreparableStmt newStmt)
replaceIdentInSelect _ cte = cte


render ::  Either String PreparableStmt-> Text
render (Left msg) = pack msg
render (Right ast) = Rendering.toText $ Rendering.preparableStmt  ast


