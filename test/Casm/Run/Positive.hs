module Casm.Run.Positive where

import Base
import Casm.Run.Base

data PosTest = PosTest
  { _name :: String,
    _runVM :: Bool,
    _relDir :: Path Rel Dir,
    _file :: Path Rel File,
    _expectedFile :: Path Rel File,
    _inputFile :: Maybe (Path Rel File)
  }

root :: Path Abs Dir
root = relToProject $(mkRelDir "tests/Casm/positive")

testDescr :: PosTest -> TestDescr
testDescr PosTest {..} =
  let tRoot = root <//> _relDir
      file' = tRoot <//> _file
      expected' = tRoot <//> _expectedFile
      input' = fmap (tRoot <//>) _inputFile
   in TestDescr
        { _testName = _name,
          _testRoot = tRoot,
          _testAssertion = Steps $ casmRunAssertion True _runVM file' input' expected'
        }

filterTests :: [String] -> [PosTest] -> [PosTest]
filterTests incl = filter (\PosTest {..} -> _name `elem` incl)

allTests :: TestTree
allTests =
  testGroup
    "CASM run positive tests"
    (map (mkTest . testDescr) tests)

tests :: [PosTest]
tests =
  [ PosTest
      "Test001: Sum of numbers"
      True
      $(mkRelDir ".")
      $(mkRelFile "test001.casm")
      $(mkRelFile "out/test001.out")
      Nothing,
    PosTest
      "Test002: Factorial"
      True
      $(mkRelDir ".")
      $(mkRelFile "test002.casm")
      $(mkRelFile "out/test002.out")
      Nothing,
    PosTest
      "Test003: Direct call"
      True
      $(mkRelDir ".")
      $(mkRelFile "test003.casm")
      $(mkRelFile "out/test003.out")
      Nothing,
    PosTest
      "Test004: Indirect call"
      True
      $(mkRelDir ".")
      $(mkRelFile "test004.casm")
      $(mkRelFile "out/test004.out")
      Nothing,
    PosTest
      "Test005: Exp function"
      True
      $(mkRelDir ".")
      $(mkRelFile "test005.casm")
      $(mkRelFile "out/test005.out")
      Nothing,
    PosTest
      "Test006: Branch"
      True
      $(mkRelDir ".")
      $(mkRelFile "test006.casm")
      $(mkRelFile "out/test006.out")
      Nothing,
    PosTest
      "Test007: Closure extension"
      True
      $(mkRelDir ".")
      $(mkRelFile "test007.casm")
      $(mkRelFile "out/test007.out")
      Nothing,
    PosTest
      "Test008: Integer arithmetic"
      False -- integer division not yet supported
      $(mkRelDir ".")
      $(mkRelFile "test008.casm")
      $(mkRelFile "out/test008.out")
      Nothing,
    PosTest
      "Test009: Recursion"
      True
      $(mkRelDir ".")
      $(mkRelFile "test009.casm")
      $(mkRelFile "out/test009.out")
      Nothing,
    PosTest
      "Test010: Functions returning functions"
      True
      $(mkRelDir ".")
      $(mkRelFile "test010.casm")
      $(mkRelFile "out/test010.out")
      Nothing,
    PosTest
      "Test011: Lists"
      True
      $(mkRelDir ".")
      $(mkRelFile "test011.casm")
      $(mkRelFile "out/test011.out")
      Nothing,
    PosTest
      "Test012: Recursion through higher-order functions"
      True
      $(mkRelDir ".")
      $(mkRelFile "test012.casm")
      $(mkRelFile "out/test012.out")
      Nothing,
    PosTest
      "Test013: Currying and uncurrying"
      True
      $(mkRelDir ".")
      $(mkRelFile "test013.casm")
      $(mkRelFile "out/test013.out")
      Nothing,
    PosTest
      "Test014: Field arithmetic"
      True
      $(mkRelDir ".")
      $(mkRelFile "test014.casm")
      $(mkRelFile "out/test014.out")
      Nothing,
    PosTest
      "Test015: Input"
      True
      $(mkRelDir ".")
      $(mkRelFile "test015.casm")
      $(mkRelFile "out/test015.out")
      (Just $(mkRelFile "in/test015.json"))
  ]
