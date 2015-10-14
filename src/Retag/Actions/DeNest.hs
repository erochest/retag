module Retag.Actions.DeNest where


import           Control.Error
import qualified Data.Text         as T
import qualified Data.Text.IO      as TIO
import           Data.Traversable
import           Text.HTML.TagSoup

import           Retag.Balance


deNest :: FilePath -> FilePath -> T.Text -> Script ()
deNest inputFile outputFile tagName =
    scriptIO . TIO.writeFile outputFile
                 . renderTags
                 . concat
                 . snd
                 . mapAccumL (denestTag tagName) []
                 . parseTags
        =<< scriptIO (TIO.readFile inputFile)
