{-# LANGUAGE OverloadedStrings #-}


module Main where


import           Control.Error

import           Actions
import           Opts


main :: IO ()
main = runScript . action =<< parseOpts