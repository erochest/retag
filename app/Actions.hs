{-# LANGUAGE RecordWildCards #-}


module Actions where


import           Control.Error

import           Retag
import           Retag.Types


action :: Actions -> Script ()
action Retag{..}   = retag retagInput retagOutput retagTagNames
                           retagEmptyTags
