module Collect where

import Control.Applicative
import JUnit.Parser
import System.FilePath
import Text.XML

gather :: [FilePath] -> IO [Either XMLException [TestSuiteResult]]
gather files = sequence $ fmap parseFromFile files




