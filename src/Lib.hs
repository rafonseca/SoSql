module Lib
    ( fromSql,
      toSql
    ) where

import PostgresqlSyntax.Parsing(run, preparableStmt)
import PostgresqlSyntax.Ast
import Ast
import qualified Parsing
import qualified PostgresqlSyntax.Rendering as Rendering
import Data.Text(Text,unpack,pack) 
import Data.Maybe
import Data.List.NonEmpty(NonEmpty((:|)),toList,fromList)


-- Helpers

withText :: (Text->Text) -> (String->String)
withText f = (unpack . f . pack)



-- Exported functions
fromSql :: String -> String
fromSql = withText fromSql'
  where
    fromSql' :: Text ->  Text
    fromSql' = render . parseSql
    
    parseSql :: Text -> Either String PreparableStmt
    parseSql = run preparableStmt

toSql :: String -> String
toSql = withText toSql'
  where
    toSql' :: Text ->  Text
    toSql' = render . transformSoSql . parseSoSql
    
    parseSoSql :: Text -> Either String SoClause
    parseSoSql = run Parsing.soClause

    transformSoSql :: Either String SoClause -> Either String PreparableStmt
    transformSoSql = fmap transformSoClause

-- Core logic
render ::  Either String PreparableStmt-> Text
render (Left msg) = pack msg
render (Right ast) = Rendering.toText $ Rendering.preparableStmt  ast


transformSoClause :: SoClause -> PreparableStmt
transformSoClause soClause = let
  SoClause ctes = soClause
  (newCtes,lastName) =  fillEmptyFromClauses ctes
  with = WithClause False newCtes
  asterisk = NormalTargeting (AsteriskTargetEl :| [])
  from = RelationExprTableRef (SimpleRelationExpr (SimpleQualifiedName lastName) False) Nothing Nothing
  simpleselect = NormalSimpleSelect (Just asterisk) Nothing (Just (from:|[])) Nothing Nothing Nothing Nothing
  select = SelectNoParens (Just with) (Left simpleselect) Nothing Nothing Nothing
  in SelectPreparableStmt (Left select)


fillEmptyFromClauses ::  NonEmpty CommonTableExpr' -> (NonEmpty CommonTableExpr,Ident)
fillEmptyFromClauses cteExprs = let
  ctesList' = toList cteExprs
  explicitNames = [name |CommonTableExpr' name _ _ _ <- ctesList']
  defaultNames = [UnquotedIdent  (pack ("_t" <> show n)) | n<- [1..]]
  names = zipWith fromMaybe defaultNames explicitNames
  ctesList = zipWith toCommonTableExpr ctesList' names
  firstCte:subsequentCtes = ctesList
  modifiedCtes = zipWith replaceIdentInSelect names subsequentCtes
  in
  (fromList (firstCte:modifiedCtes),last names)

toCommonTableExpr :: CommonTableExpr'-> Ident -> CommonTableExpr
toCommonTableExpr (CommonTableExpr' _ b c d) name = CommonTableExpr name b c d

replaceIdentInSelect :: Ident -> CommonTableExpr -> CommonTableExpr   
replaceIdentInSelect newIdent (CommonTableExpr a b c (SelectPreparableStmt stmt)) = let
  newFromClause = Just(
    RelationExprTableRef (SimpleRelationExpr
                           (SimpleQualifiedName newIdent)
                           False)
      Nothing
      Nothing :| [])
  loopStmt :: SelectStmt -> SelectStmt
  loopStmt stmt = case stmt of
    Left (SelectNoParens a select  c d e) ->
      case select of
        Left (NormalSimpleSelect targeting into from where' group' having window) ->
          case from of
            Nothing -> 
              Left (SelectNoParens
                            a
                            (Left (NormalSimpleSelect
                             targeting
                             into
                             newFromClause
                             where'
                             group'
                             having
                             window))
                            c
                            d
                            e)
            otherwise -> stmt
        otherwise -> stmt -- should add here selectWithParens case
    otherwise -> stmt -- should add here selectWithParens case          

  newStmt = loopStmt stmt
  in
  CommonTableExpr a b c (SelectPreparableStmt newStmt)
replaceIdentInSelect _ cte = cte


