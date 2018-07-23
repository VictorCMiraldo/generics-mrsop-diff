{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE GADTs #-}
-- Annotates a source an destination tree
-- by zipping a 'GDiff' patch with a Fix
module Generics.MRSOP.Diff.Annotate where
import Generics.MRSOP.Base
import Generics.MRSOP.GDiff
import Generics.MRSOP.Util

import Data.Maybe (fromJust)

data Ann = Modify | Copy

injCofAnn ::
     Cof ki codes a c
  -> ann
  -> PoA ki (AnnFix ki codes ann) (Tyof codes c)
  -> NA ki (AnnFix ki codes ann) a
injCofAnn (ConstrI c) ann xs = NA_I (AnnFix ann $ inj c xs)
injCofAnn (ConstrK k) ann xs = NA_K k

  
-- lemma needed for inserting an annotation at the place of 
-- a constructor
insCofAnn ::
     Cof ki codes a c
  -> ann
  -> ListPrf (Tyof codes c)
  -> PoA ki (AnnFix ki codes ann) (Tyof codes c :++: as)
  -> PoA ki (AnnFix ki codes ann) (a ': as)
insCofAnn c ann prf xs =
  let (xs0, xs1) = split prf xs
   in injCofAnn c ann xs0 :* xs1


{-
 - In Agda, it would be the following. However, I'm not sure
 - it is possible to carry around the IsJust constraint in Haskell
 - hence, we will be partial instead
 -  ann-source : ∀{txs tys}(xs : ⟦ txs ⟧A*)(p : ES txs tys)
 -           → (hip : IsJust (applyES p xs))
 -           → ⟦ txs ⟧Aₐ*
 -
 - However, it's morally total if you know beforehand that the
 - patch is gonna apply. Which we know by construction everywhere we use this
 - , so we can just `fromJust` it where appropriate
 -}


annSrc ::
     forall ki codes xs ys.
     Eq1 ki => 
     PoA ki (Fix ki codes) xs
  -> ES ki codes xs ys
  -> PoA ki (AnnFix ki codes Ann) xs
annSrc xs ES0 = NP0
annSrc xs (Ins c es) = annSrc xs es
annSrc (x :* xs) (Del c es) =
  -- Morally dubious, but we know that this edit script was
  -- generated hte same time as the datatype, so it should never
  -- fail to apply
  let poa = fromJust $ matchCof c x
  in undefined

    
    
annSrc xs (Cpy c es) = undefined