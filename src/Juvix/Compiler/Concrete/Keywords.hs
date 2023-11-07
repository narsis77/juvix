module Juvix.Compiler.Concrete.Keywords
  ( module Juvix.Compiler.Concrete.Keywords,
    module Juvix.Data.Keyword,
    module Juvix.Data.Keyword.All,
  )
where

import Juvix.Data.Keyword
import Juvix.Data.Keyword.All
  ( -- delimiters
    delimBraceL,
    delimBraceR,
    delimDoubleBraceL,
    delimDoubleBraceR,
    delimJudocBlockEnd,
    delimJudocBlockStart,
    delimJudocExample,
    delimJudocStart,
    delimParenL,
    delimParenR,
    delimSemicolon,
    -- keywords

    kwAbove,
    kwAlias,
    kwAs,
    kwAssign,
    kwAssoc,
    kwAt,
    kwAtQuestion,
    kwAxiom,
    kwBelow,
    kwBinary,
    kwBracketL,
    kwBracketR,
    kwBuiltin,
    kwCase,
    kwCoercion,
    kwColon,
    kwEnd,
    kwEq,
    kwFixity,
    kwHiding,
    kwHole,
    kwImport,
    kwIn,
    kwInductive,
    kwInit,
    kwInstance,
    kwIterator,
    kwLambda,
    kwLeft,
    kwLet,
    kwMapsTo,
    kwModule,
    kwNone,
    kwOf,
    kwOpen,
    kwOperator,
    kwPipe,
    kwPositive,
    kwPublic,
    kwRange,
    kwRight,
    kwRightArrow,
    kwSame,
    kwSyntax,
    kwTerminating,
    kwTrait,
    kwType,
    kwUnary,
    kwUsing,
    kwWhere,
    kwWildcard,
  )
import Juvix.Prelude

allKeywordStrings :: HashSet Text
allKeywordStrings = keywordsStrings reservedKeywords

reservedKeywords :: [Keyword]
reservedKeywords =
  [ delimSemicolon,
    kwAssign,
    kwAt,
    kwAtQuestion,
    kwAxiom,
    kwCase,
    kwColon,
    kwEnd,
    kwHiding,
    kwHole,
    kwImport,
    kwIn,
    kwInductive,
    kwLambda,
    kwLet,
    kwModule,
    kwOf,
    kwOpen,
    kwPipe,
    kwPublic,
    kwRightArrow,
    kwSyntax,
    kwType,
    kwUsing,
    kwWhere,
    kwWildcard
  ]
