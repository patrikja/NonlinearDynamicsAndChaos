import Data.Complex
import Data.List
import Graphics.Gloss
import System.Environment
import Graphics.Gloss.Data.Color (Color)
import Graphics.Gloss.Data.Display (Display(InWindow))
import Graphics.Gloss.Interface.Pure.Animate (animate)
import Graphics.Gloss.Data.Picture
import Graphics.Gloss.Raster.Field (animateField, rgbI)
type C=Complex Float
type Width=Int
type Height=Int
type X=Float
type Y=Float
type Time=Float

----- Main, using frametestfexample and different constants

main=test

test :: IO ()
test = do
  animateField
    (InWindow "fractal" windowSize (50, 10))
    (pixelSize, pixelSize)
    plot
  where
    windowSize = (1000, 1000)
    pixelSize = 1

------Parameterized polynomial and its derivative
f::C->C->C
f a z=(z^2-(1:+0))*(z^2+a)

f'::C->C->C
f' a z=(4:+0)*z^3+(2:+0)*a*z-(2:+0)*z

------Newtons iteration function for the polynomial
newton::(C->C)->(C->C)->C->C
newton f f' z=z-(f z)/(f' z)

fnewton a = newton (f a) (f' a)

-----The critical point c_1
c_1::C->C
c_1 a=1

-----The critical point c_2
c_2::C->C
c_2 a =sqrt((1-a)/6)

----The critical point c_3
c_3::C->C
c_3 a =(-sqrt((1-a)/6))

----The orbit for the critical point
criticalorbit::C->[C]
criticalorbit a = take 25 (iterate (fnewton a) (c_2 a))

toplot1::C->Int
toplot1 a = testf a (c_1 a)

toplot2::C->Int
toplot2 a = testf a (c_2 a)

toplot3::C->Int
toplot3 a = testf a (c_3 a)

plot::Time->Point->Color
plot t a= rgbI c c c
  where c=20*(toplot3 (pointToComplex a))

----Plot the difference between toplot2 and toplot3 to see if they are identical
plotdifference::Time->Point->Color
plotdifference t a= rgbI c c c
  where c=20*(toplot3 (pointToComplex a)- toplot2 (pointToComplex a))

-----Helpfunctions for framtestfexample
eps=1e-6

-----Fixerar a och varierar seed för varje plot, sen varierar a med tiden
testf::C->C->Int
testf a seed= length (take 100 (takeWhile (>eps) skillnader))
  where 
    skillnader = map (\(x1,x2)-> magnitude (x1-x2)) grannpar
    grannpar = zip orbit (tail orbit)
    orbit = iterate fa seed
    fa=fnewton a
      
frametestf::C->Point->Color
frametestf a p= rgbI c c c
  where c=20*(testf a (pointToComplex p))

frametestfexample::Time->Point->Color
frametestfexample t =frametestf (t:+0)

-------

i::C
i=0:+1

complexToPoint::C->Point
complexToPoint c=(realPart c,imagPart c)

pointToComplex::Point->C
pointToComplex (a,b)=((2*a):+(2*b))

--standard=(-1:+-1) (1:+1)

--scale::((C->C)->C)->C
--scale (bottomLeftReal:+bottomLeftImag) (upperRightReal:+upperRightImag) (a:+b)=(x*a:y*b)
     -- where x
      --	    middle=(((bottomLeftReal+upperRightReal)/2):+((bottomLeftImag+upperLeftImag)/2))

--to get fig 18.4a
fig184a::C->C
fig184a  z=z^2+1

fig184a'::C->C
fig184a' z=2*z

a=newton fig184a fig184a'

testa= length . take 100 . takeWhile (\z->magnitude z<4) . iterate a

testa' c = length (take 100 (takeWhile (>eps) skillnader))
  where 
    skillnader = map (\(x1,x2)-> magnitude (x1-x2)) grannpar
    grannpar = zip as (tail as)
    as = iterate a c
      

frametesta::Time->Point->Color
frametesta time p= rgbI c c c
  where c=40*(testa' (pointToComplex p))
----------------------------------------------------------------------
--to get 18.4b
fig184b::C->C
fig184b  z=z^3-1

fig184b'::C->C
fig184b' z=3*z^2

b=newton fig184b fig184b'

testb= length . take 100 . takeWhile (\z->magnitude z<4) . iterate b

testb' c = length (take 100 (takeWhile (>eps) skillnader))
  where 
    skillnader = map (\(x1,x2)-> magnitude (x1-x2)) grannpar
    grannpar = zip bs (tail bs)
    bs = iterate b c
      

frametestb::Time->Point->Color
frametestb time p= rgbI c c c
  where c=20*(testb' (pointToComplex p))

---------------------------------------------------------------------------------------



----------------------------------------------------------------------
disc::C->Bool
disc a = (magnitude a)<=1 

func::Point->Int
func a=if disc (pointToComplex a) then 255
         else 0

myframe::Time->Point->Color
myframe time p= rgbI c c c
  where c=func p
          --cycleColorF (time*(fromIntegral (func p)))
-------------------------------------------------------------------------
{-
Gammal version som inte varierar a

frametestf::Float->Time->Point->Color
frametestf a time p= rgbI c c c
  where c=20*(testf' (pointToComplex p) a)

frametestfexample::Time->Point->Color
frametestfexample t =frametestf 1
-}

{-
Gammal version som kollar om magnituden på det komplexa talet är mindre än 4 iställer för algoritmen som boken föreslår

testf'::C->(C->Int)
testf' a = length . take 100 . takeWhile (\z->magnitude z<4) . iterate (fnewton a)
-}