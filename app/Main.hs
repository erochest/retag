module Main where


import           Control.Error

import           Retag.Actions

import           Opts


main :: IO ()
main = runScript . action =<< parseActions
