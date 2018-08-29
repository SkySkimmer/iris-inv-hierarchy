From iris.heap_lang Require Export lifting notation.
From iris.base_logic.lib Require Export invariants.
From iris.program_logic Require Export atomic.
From iris.proofmode Require Import tactics.
From iris.heap_lang Require Import proofmode notation par.
From iris.bi.lib Require Import fractional.
Set Default Proof Using "Type".

(** Nondeterminism and Speculation:
    Implementing "Late choice versus early choice" example from
    Logical Relations for Fine-Grained Concurrency by Turon et al. (POPL'13) *)

Definition rand: val :=
    λ: "_",
       let: "y" := ref #false in
       Fork ("y" <- #true) ;;
       !"y".

Definition earlyChoice: val :=
  λ: "x",
  let: "r" := rand #() in
  "x" <- #0 ;;
      "r".

Definition lateChoice: val :=
  λ: "x",
  let: "p" := NewProph in
  "x" <- #0 ;;
      let: "r" := rand #() in
      resolve_proph: "p" to: "r" ;;
      "r".

Section coinflip.
  Context `{!heapG Σ} (N: namespace).

  Lemma rand_spec :
    {{{ True }}} rand #() {{{ (b : bool), RET #b; True }}}.
  Proof using N.
    iIntros (Φ) "_ HP".
    wp_lam. wp_alloc l as "Hl". wp_lam.
    iMod (inv_alloc N _ (∃ (b: bool), l ↦ #b)%I with "[Hl]") as "#Hinv"; first by eauto.
    wp_apply wp_fork.
    - iInv N as (b) ">Hl". wp_store. iModIntro. iSplitL; eauto.
    - wp_lam. iInv N as (b) ">Hl". wp_load. iModIntro. iSplitL "Hl"; first by eauto.
      iApply "HP". done.
  Qed.

  Lemma earlyChoice_spec (x: loc) :
    <<< x ↦ - >>>
        earlyChoice #x
        @ ⊤
    <<< ∃ (b: bool), x ↦ #0, RET #b >>>.
  Proof using N.
    iApply wp_atomic_intro. iIntros (Φ) "AU". wp_lam.
    wp_bind (rand _)%E. iApply rand_spec; first done.
    iIntros (b) "!> _". wp_let.
    wp_bind (_ <- _)%E.
    iMod "AU" as "[Hl [_ Hclose]]".
    iDestruct "Hl" as (v) "Hl".
    wp_store.
    iMod ("Hclose" with "[Hl]") as "HΦ"; first by eauto.
    iModIntro. wp_seq. done.
  Qed.

  Definition val_to_bool v : bool :=
    match v with
    | Some (LitV (LitBool b)) => b
    | _                       => true
    end.

  Lemma lateChoice_spec (x: loc) :
    <<< x ↦ - >>>
        lateChoice #x
        @ ⊤
    <<< ∃ (b: bool), x ↦ #0, RET #b >>>.
  Proof using N.
    iApply wp_atomic_intro. iIntros (Φ) "AU". wp_lam.
    wp_apply wp_new_proph; first done.
    iIntros (p) "Hp". iDestruct "Hp" as (v) "Hp".
    wp_let.
    wp_bind (_ <- _)%E.
    iMod "AU" as "[Hl [_ Hclose]]".
    iDestruct "Hl" as (v') "Hl".
    wp_store.
    iMod ("Hclose" $! (val_to_bool v) with "[Hl]") as "HΦ"; first by eauto.
    iModIntro. wp_seq. wp_apply rand_spec; try done.
    iIntros (b') "_". wp_let.
    wp_apply (wp_resolve_proph with "Hp").
    iIntros (->). wp_seq. done.
  Qed.

End coinflip.
