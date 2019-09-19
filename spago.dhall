{ name =
    "vectors"
, dependencies =
    [ "arrays"
    , "console"
    , "distributive"
    , "effect"
    , "foldable-traversable"
    , "maybe"
    , "prelude"
    , "psci-support"
    , "test-unit"
    , "unfoldable"
    , "typelevel"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}