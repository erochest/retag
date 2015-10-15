module Retag.Actions.DeNest where


import           Control.Error
import qualified Data.Set          as S
import qualified Data.Text         as T
import qualified Data.Text.IO      as TIO
import           Data.Traversable
import           Text.HTML.TagSoup

import           Retag.Balance
import           Retag.Types


deNest :: FilePath -> FilePath -> T.Text -> Script ()
deNest inputFile outputFile tagName =
    scriptIO . TIO.writeFile outputFile
                 . renderTags
                 . concat
                 . snd
                 . mapAccumL (denestTag trans) []
                 . parseTags
        =<< scriptIO (TIO.readFile inputFile)
    where
      trans = DeNestTrans (S.singleton tagName) S.empty
