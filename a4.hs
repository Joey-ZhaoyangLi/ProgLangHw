import System.IO
import System.Environment
import Data.List
import Data.Char

bracesColor   = "DarkBlue"
bracketsColor = "DarkViolet"
commaColor    = "Black"
colonColor    = "Maroon"
boolColor     = "DarkBlue"
escapeColor   = "Purple"
stringColor   = "FireBrick"
numberColor   = "SaddleBrown"

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

transform :: String -> String
transform "" = ""
transform (x:xs) | x == '<' = "&lt;" ++ transform xs
                 | x == '>' = "&gt;" ++ transform xs
                 | x == '&' = "&amp;" ++ transform xs
                 | x == '\'' = "&apos;" ++ transform xs
                 | x == '\"' = "&quot;" ++ transform xs
                 | otherwise = x : transform xs

formString :: [String] -> String
formString [] = ""
formString (x:xs) | head x == '\\' = "<span style=\"color:" ++ escapeColor ++ "\">" ++ transform x ++ "</span>" ++ formString xs
                  | otherwise = transform x ++ formString xs

toJsonHtml :: [String] -> Int -> String
toJsonHtml [] _ = ""
toJsonHtml (x:xs) indent
        | x == "{" = "<span style=\"color:" ++ bracesColor ++ "\">{</span>\n" ++
                    (concat ["    " | k <- replicate (indent+1) 1 ]) ++ toJsonHtml xs (indent+1)
        | x == "[" = "<span style=\"color:" ++ bracketsColor ++ "\">[</span>\n" ++
                    (concat ["    " | k <- replicate (indent+1) 1 ]) ++ toJsonHtml xs (indent+1)
        | x == "]" = "\n" ++ (concat ["    " | k <- replicate (indent-1) 1 ]) ++
                    "<span style=\"color:" ++ bracketsColor ++ "\">]</span>" ++ toJsonHtml xs (indent-1)
        | x == "}" = "\n" ++ (concat ["    " | k <- replicate (indent-1) 1 ]) ++
                    "<span style=\"color:" ++ bracketsColor ++ "\">}</span>" ++ toJsonHtml xs (indent-1)
        | x == "\"" =
            let (strs, rest) = break (== "\"") xs
            in "<span style=\"color:" ++ stringColor ++ "\">" ++ "&quot;" ++ formString strs ++ "&quot;" ++ "</span>" ++
                    toJsonHtml (tail rest) indent
        | x == ":" = "<span style=\"color:" ++ colonColor ++ "\"> : </span>" ++ toJsonHtml xs indent
        | x == "," = "<span style=\"" ++ commaColor ++ "\">,</span>\n" ++ (concat ["    " | k <- replicate indent 1 ]) ++ toJsonHtml xs indent
        | trim x == "true" || trim x == "false" || trim x == "null" = "<span style=\"color:" ++ boolColor ++ "\">" ++ trim x ++ "</span>" ++
                    toJsonHtml xs indent
        | otherwise = "<span style=\"color:" ++ numberColor ++ "\">" ++ trim x ++ "</span>" ++ toJsonHtml xs indent


endofStr :: Char -> Bool
endofStr c
           | c == '\\' = True
           | c == '\"' = True
           | c == ',' = True
           | c == ']' = True
           | c == '}' = True
           | otherwise = False

scan :: String -> [String]
scan "" = []
scan (x:xs)   | isSpace x = scan xs
              | x == '[' = "[" : scan xs
              | x == ']' = "]" : scan xs
              | x == '{' = "{" : scan xs
              | x == '}' = "}" : scan xs
              | x == ',' = "," : scan xs
              | x == ':' = ":" : scan xs
              | x == '\"' = "\"" : scan xs
              | x == '\\' =
                  let (esc, rest) =
                        if (xs !! 0) == 'u'
                            then splitAt 6 (x:xs)
                            else splitAt 2 (x:xs)
                    in let (str, remain) = break endofStr (rest)
                    in
                        if null str
                            then esc : scan remain
                            else esc : str : scan remain
              | otherwise =
                  let (str, rest) = break endofStr (x:xs)
                  in str : scan rest

main = do
    args <- getArgs
    content <- readFile (args !! 0)
    putStrLn "<!DOCTYPE html>"
    putStrLn "<html>"
    putStrLn "<body>"
    putStrLn ""
    putStrLn "<span style=\"font-family:monospace; white-space:pre\">"

    let tokens = scan content
    putStr ( toJsonHtml tokens 0)
    putStrLn ""
    putStrLn "</span>"
    putStrLn "</body>"
    putStrLn "</html>"
