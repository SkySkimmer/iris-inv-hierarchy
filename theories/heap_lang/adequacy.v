From iris.proofmode Require Import tactics.
From iris.algebra Require Import auth.
From iris.program_logic Require Export weakestpre adequacy.
From iris.heap_lang Require Import proofmode notation.
From iris Require Import options.

Class heapPreG Σ := HeapPreG {
  heap_preG_iris :> invPreG Σ;
  heap_preG_crash :> crashPreG Σ;
  heap_preG_heap :> gen_heapPreG loc (option val) Σ;
  heap_preG_inv_heap :> inv_heapPreG loc (option val) Σ;
  heap_preG_proph :> proph_mapPreG proph_id (val * val) Σ;
}.

Definition heapΣ : gFunctors :=
  #[invΣ; crashΣ; gen_heapΣ loc (option val); inv_heapΣ loc (option val); proph_mapΣ proph_id (val * val)].
Instance subG_heapPreG {Σ} : subG heapΣ Σ → heapPreG Σ.
Proof. solve_inG. Qed.

Definition heap_adequacy Σ `{!heapPreG Σ} s e σ φ :
  (∀ `{!heapG Σ}, ⊢ inv_heap_inv -∗ WP e @ s; ⊤ {{ v, ⌜φ v⌝ }}) →
  adequate s e σ (λ v _, φ v).
Proof.
  intros Hwp; eapply (wp_adequacy _ _); iIntros (???) "".
  iMod (gen_heap_init σ.(heap)) as (?) "Hh".
  iMod (inv_heap_init loc (option val)) as (?) ">Hi".
  iMod (proph_map_init κs σ.(used_proph_id)) as (?) "Hp".
  iModIntro. iExists
    (λ σ κs, (gen_heap_interp σ.(heap) ∗ proph_map_interp κs σ.(used_proph_id))%I),
    (λ _, True%I).
  iFrame. iApply (Hwp (HeapG _ _ _ _ _ _)). done.
Qed.
