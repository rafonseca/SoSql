module Main (main) where

import Lib


main :: IO ()
main = do
  inp <- getContents
  putStr $ fromSql inp 
             


