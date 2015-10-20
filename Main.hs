{-# LANGUAGE OverloadedStrings #-} -- Data.JSString words exactly like standard strings, except it is JS string :)
{-# LANGUAGE JavaScriptFFI, GHCForeignImportPrim #-} -- second extension is required for using Exts.Any in foreign import
module Main (main) where

import qualified GHC.Exts as Exts
import Unsafe.Coerce

import Data.JSString
import GHCJS.Types

-- | Go ahead with invoking cabal run from console,
--   or opening dist/build/Hello-HaskellerZ/Hello-HaskellerZ.jsexe/index.html in your favorite browser
main :: IO ()
main = do
    keeper <- createObjectWithSecret "Our little secret :)"
    putStrLn "The secret:"
    print $ tellMeTheSecret keeper

    putStrLn "\nprintAny"
    putStrLn "Number:"
    printAny (5 :: Int)
    putStrLn "\nString:"
    printAny ("Hello String!" :: String)
    putStrLn "\nJSString:"
    printAny ("Hello JSString!" :: JSString)
    putStrLn "\nObjectWithSecret - heap object with our JS object inside:"
    printAny keeper

    putStrLn "\nprintAnyVal"
    putStrLn "Number:"
    printAnyVal (5 :: Int)
    putStrLn "\nString:"
    printAnyVal ("Hello String!" :: String)
    putStrLn "\nJSString:"
    printAnyVal ("Hello JSString!" :: JSString)
    putStrLn "\nObjectWithSecret - just JS object (we have unwrapped it from a heap object):"
    printAnyVal keeper

-- | Printing anything without conversion of types
printAny :: a -> IO ()
printAny = printAny' . unsafeCoerce

foreign import javascript safe "console.log($1)"
    printAny' :: Exts.Any -> IO ()

-- | Printing anything without conversion of types, attempting to get value from the heap object
printAnyVal :: a -> IO ()
printAnyVal = printVal' . unsafeCoerce

foreign import javascript safe "console.log($1)"
    printVal' :: JSVal -> IO ()

-- | define our own type mapped directly onto JS object
newtype ObjectWithSecret = ObjectWithSecret JSVal
instance IsJSVal ObjectWithSecret

-- | Creating the data mapped directly onto JS object
foreign import javascript safe "$r = { secret: $1 }"
    createObjectWithSecret :: JSString -> IO (ObjectWithSecret)

-- | Accessing JS object properties.
--   Note that there is no IO (), since we assume our function is pure.
--   It is the responsibility of a user, to preserve immutability of the object.
foreign import javascript safe "$r = $1.secret"
    tellMeTheSecret :: ObjectWithSecret -> JSString
