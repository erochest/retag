{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Data.Foldable
import qualified Data.Set          as S
import qualified Data.Text.IO      as TIO
import           System.IO
import           Text.HTML.TagSoup

import           Retag.Balance
import           Retag.Types


main :: IO ()
main =
    mapM_ TIO.putStrLn
              . imbalancedTags
              . foldl' trackTag (TagStack [] S.empty)
              . parseTags
        =<< TIO.hGetContents stdin
