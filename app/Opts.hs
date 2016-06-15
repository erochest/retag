{-# LANGUAGE OverloadedStrings #-}


module Opts where


import qualified Data.Set            as S
import qualified Data.Text           as T
import           Options.Applicative

import           Retag.Types


inputFile :: Parser String
inputFile = strOption (  short 'i' <> long "input" <> metavar "INPUT_FILE"
                      <> help "The input file to process.")

outputFile :: Parser String
outputFile = strOption (  short 'o' <> long "output" <> metavar "OUTPUT_FILE"
                       <> help "The output file to write to.")

tagName :: Parser T.Text
tagName = option (T.pack <$> str)
          (  short 't' <> long "tag" <> metavar "TAG_NAME"
          <> help "The tag name to process.")

emptyName :: Parser T.Text
emptyName = option (T.pack <$> str)
            (  short 'e' <> long "empty" <> metavar "TAG_NAME"
            <> help "The name of tags to close.")

retagOpts :: Parser Actions
retagOpts =   Retag
          <$> inputFile
          <*> outputFile
          <*> fmap S.fromList (many tagName)
          <*> fmap S.fromList (many emptyName)

opts :: ParserInfo Actions
opts = info (helper <*> retagOpts)
       (  fullDesc
       <> progDesc "Works on closing tags."
       <> header "retag - utility for closing implicit end tags.")

parseOpts :: IO Actions
parseOpts = execParser opts
