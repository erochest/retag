{-# LANGUAGE RecordWildCards #-}


module Retag.Actions where


import           Control.Error

import           Retag.Actions.Report
import           Retag.Types


action :: Actions -> Script ()
action Report = report
action DeNest{..} = undefined
action CloseTag{..} = undefined
