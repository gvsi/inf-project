-- Informatics 1 - Functional Programming 
-- Tutorial 8
--
-- Week 11 - due: 28/29 Nov.

import Data.List
import Test.QuickCheck

-- Type declarations

type FSM q = ([q], Alphabet, q, [q], [Transition q])
type Alphabet = [Char]
type Transition q = (q, Char, q)



-- Example machines

m1 :: FSM Int
m1 = ([0,1,2,3,4],
      ['a','b'],
      0,
      [4],
      [(0,'a',1), (0,'b',1), (0,'a',2), (0,'b',2),
       (1,'b',4), (2,'a',3), (2,'b',3), (3,'b',4),
       (4,'a',4), (4,'b',4)])

m2 :: FSM Char
m2 = (['A','B','C','D'],
      ['0','1'],
      'B',
      ['A','B','C'],
      [('A', '0', 'D'), ('A', '1', 'B'),
       ('B', '0', 'A'), ('B', '1', 'C'),
       ('C', '0', 'B'), ('C', '1', 'D'),
       ('D', '0', 'D'), ('D', '1', 'D')])

dm1 :: FSM [Int] 
dm1 =  ([[],[0],[1,2],[3],[3,4],[4]],
        ['a','b'],
        [0],
        [[3,4],[4]],
        [([],   'a',[]),
         ([],   'b',[]),
         ([0],  'a',[1,2]),
         ([0],  'b',[1,2]),
         ([1,2],'a',[3]),
         ([1,2],'b',[3,4]),
         ([3],  'a',[]),
         ([3],  'b',[4]),
         ([3,4],'a',[4]),
         ([3,4],'b',[4]),
         ([4],  'a',[4]),
         ([4],  'b',[4])])



-- 1.
states :: FSM q -> [q]
alph   :: FSM q -> Alphabet
start  :: FSM q -> q
final  :: FSM q -> [q]
trans  :: FSM q -> [Transition q]


states (u,a,s,f,t) = u
alph (u,a,s,f,t) = a
start (u,a,s,f,t) = s
final (u,a,s,f,t) = f
trans (u,a,s,f,t) = t


-- 2.
delta :: (Eq q) => FSM q -> q -> Char -> [q]
delta m source_state symbol = [ q' | (q, s, q')<-(trans m), q == source_state && s == symbol]

-- 3.
accepts :: (Eq q) => FSM q -> String -> Bool
accepts m xs  =  acceptsFrom m (start m) xs
acceptsFrom :: (Eq q) => FSM q -> q -> String -> Bool
acceptsFrom m q [] = q `elem` final m
acceptsFrom m q (x:xs) = any (\q' -> acceptsFrom m q' xs) (delta m q x)


-- 4.
canonical :: (Ord q) => [q] -> [q]
canonical = sort . nub


-- 5.
ddelta :: (Ord q) => FSM q -> [q] -> Char -> [q]
ddelta m qs s = canonical $ concat (map (\q -> delta m q s) qs)


-- 6.
next :: (Ord q) => FSM q -> [[q]] -> [[q]]
next m qss = canonical $ [ddelta m qs s | qs <- qss, s <- alph m] ++ qss


-- 7.
reachable :: (Ord q) => FSM q -> [[q]] -> [[q]]
reachable m qss | qss /= next m qss = reachable m (next m qss)
                | otherwise = qss


-- 8.
dfinal :: (Ord q) => FSM q -> [[q]] -> [[q]]
dfinal m qss = filter (\qs -> any (\f -> elem f qs) (final m)) qss


-- 9.
dtrans :: (Ord q) => FSM q -> [[q]] -> [Transition [q]]
dtrans m qss = [ (qs, s, ddelta m qs s) | s <- alph m, qs <- qss ]


-- 10.
deterministic :: (Ord q) => FSM q -> FSM [q]
deterministic m = (states, alph m, [start m], dfinal m states, dtrans m (reachable m states))
  where
    states = reachable m [[start m]]


