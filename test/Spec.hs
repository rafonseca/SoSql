module Main(main) where

import Prelude
import Test.Hspec
import Test.Hspec.Golden

import Lib

main :: IO ()
main = hspec spec



spec :: Spec
spec = do
    golden "supports implicit CTE name" $ return $ toSql
       "so select 1"

    golden "supports stacked CTEs with implicit name" $ return $ toSql
      "so select 1 then select * from _t1"

    golden "supports stacked CTEs with implicit from clause" $ return $ toSql
      "so select 1 then select *"

    golden "supports named stacked CTEs" $ return $ toSql
      "so table1 <- select 1 then table2 <- select * then select * from table1"

    it "supports implicit select clause in named CTE" $ do  pending
    
    -- golden "supports implicit select clause in named CTE" $ return $ toSql
    --   "so t1 <- from auth_users"

    it "supports implicit select clause in unnamed CTE" $ do  pending
