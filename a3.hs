count_emirps :: Int -> Int
count_emirps n | n < 13 = 0
count_emirps x | is_emirp(x) = count_emirps (x-1) + 1
				| otherwise = count_emirps (x-1)

is_emirp :: Int -> Bool
is_emirp n | n < 13 = False
            | n /= rn && isPrime n && isPrime rn = True where rn = reverseInt n
is_emirp _ = False

isPrime :: Int -> Bool
isPrime n | n < 2 = False
isPrime n = length [x | x <- [2..floor . sqrt $ fromIntegral n], n `mod` x == 0] == 0

reverseInt :: Int -> Int
reverseInt n = read(reverse (show n)) :: Int

greatest :: (a -> Int) -> [a] -> a
greatest f [x] = x
greatest f (x:xs) = if (f x) > f (greatest f xs) then x else greatest f xs

is_bit :: Int -> Bool
is_bit x | x == 0 || x == 1 = True
        | otherwise = False

invert_bits1 :: [Int] -> [Int]
invert_bits1 [] = []
invert_bits1 (x:xs) = if x == 0 then 1 : invert_bits1 xs else
    0 : invert_bits1 xs

invert_bits2 :: [Int] -> [Int]
invert_bits2 xs = map flip01 xs

invert_bits3 :: [Int] -> [Int]
invert_bits3 xs = [flip01 k | k <- xs ]

flip01 :: Int -> Int
flip01 x | x == 0 = 1
        | x == 1 = 0

data Bit = Zero | One
    deriving (Show, Eq)

invert :: [Bit] -> [Bit]
invert xs = map flipBit xs

flipBit :: Bit -> Bit
flipBit Zero = One
flipBit One = Zero

all_bit_seqs :: Int -> [[Bit]]
all_bit_seqs n = foldl generate [[]] [1..n]

generate :: [[Bit]] -> Int -> [[Bit]]
generate xss _ = [Zero : xs | xs <- xss] ++ [One : xs| xs <- xss]

data List a = Empty | Cons a (List a)
    deriving Show

toList :: [a] -> List a
toList [] = Empty
toList (x:xs) = Cons x (toList xs)

toHaskellList :: List a -> [a]
toHaskellList Empty = []
toHaskellList (Cons first rest) = first : (toHaskellList rest)

append :: List a -> List a -> List a
append Empty x = x
append x Empty = x
append (Cons first rest) x = Cons first (append rest x)

removeAll :: (a -> Bool) -> List a -> List a
removeAll f Empty = Empty
removeAll f (Cons first rest) = if f first then (removeAll f rest)
    else Cons first (removeAll f rest)
