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

reportOpts :: Parser Actions
reportOpts = pure Report

denestOpts :: Parser Actions
denestOpts = DeNest
             <$> inputFile
             <*> outputFile
             <*> fmap S.fromList (many tagName)
             <*> fmap S.fromList (many emptyName)

opts' :: Parser Actions
opts' = subparser
        (  command "report" (info (helper <*> reportOpts)
                             (progDesc "Report on the document's structure\
                                       \ and the tags that are closed\
                                       \ implicitly."))
        <> command "denest" (info (helper <*> denestOpts)
                             (progDesc "Denest a tag that's implicitly closed\
                                       \ everywhere it is left open."))
        )

opts :: ParserInfo Actions
opts = info (helper <*> opts')
       (  fullDesc
       <> progDesc "Works on closing tags."
       <> header "retag - utility for reporting on and closing implicit end\
                 \ tags.")

parseActions :: IO Actions
parseActions = execParser opts
