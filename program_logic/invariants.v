From iris.program_logic Require Export pviewshifts.
From iris.program_logic Require Export namespaces.
From iris.program_logic Require Import ownership.
From iris.algebra Require Import gmap.
From iris.proofmode Require Import pviewshifts.
Import uPred.

(** Derived forms and lemmas about them. *)
Definition inv_def `{irisG Λ Σ} (N : namespace) (P : iProp Σ) : iProp Σ :=
  (∃ i, ■ (i ∈ nclose N) ∧ ownI i P)%I.
Definition inv_aux : { x | x = @inv_def }. by eexists. Qed.
Definition inv {Λ Σ i} := proj1_sig inv_aux Λ Σ i.
Definition inv_eq : @inv = @inv_def := proj2_sig inv_aux.
Instance: Params (@inv) 4.
Typeclasses Opaque inv.

Section inv.
Context `{irisG Λ Σ}.
Implicit Types i : positive.
Implicit Types N : namespace.
Implicit Types P Q R : iProp Σ.
Implicit Types Φ : val Λ → iProp Σ.

Global Instance inv_contractive N : Contractive (inv N).
Proof.
  rewrite inv_eq=> n ???. apply exist_ne=>i. by apply and_ne, ownI_contractive.
Qed.

Global Instance inv_persistent N P : PersistentP (inv N P).
Proof. rewrite inv_eq /inv; apply _. Qed.

Lemma inv_alloc N E P : ▷ P ={E}=> inv N P.
Proof.
  rewrite inv_eq /inv_def pvs_eq /pvs_def. iIntros "HP [Hw $]".
  iVs (ownI_alloc (∈ nclose N) P with "[HP Hw]") as (i) "(% & $ & ?)"; auto.
  - intros Ef. exists (coPpick (nclose N ∖ coPset.of_gset Ef)).
    rewrite -coPset.elem_of_of_gset comm -elem_of_difference.
    apply coPpick_elem_of=> Hfin.
    eapply nclose_infinite, (difference_finite_inv _ _), Hfin.
    apply of_gset_finite.
  - by iFrame.
  - rewrite /uPred_now_True; eauto.
Qed.

Lemma inv_open E N P :
  nclose N ⊆ E → inv N P ={E,E∖N}=> ▷ P ★ (▷ P ={E∖N,E}=★ True).
Proof.
  rewrite inv_eq /inv_def pvs_eq /pvs_def; iDestruct 1 as (i) "[Hi #HiP]".
  iDestruct "Hi" as % ?%elem_of_subseteq_singleton.
  rewrite {1 4}(union_difference_L (nclose N) E) // ownE_op; last set_solver.
  rewrite {1 5}(union_difference_L {[ i ]} (nclose N)) // ownE_op; last set_solver.
  iIntros "(Hw & [HE $] & $)"; iVsIntro; iRight.
  iDestruct (ownI_open i P with "[Hw HE]") as "($ & $ & HD)"; first by iFrame.
  iIntros "HP [Hw $] !==>"; iRight. iApply ownI_close; by iFrame.
Qed.

Lemma inv_open_timeless E N P `{!TimelessP P} :
  nclose N ⊆ E → inv N P ={E,E∖N}=> P ★ (P ={E∖N,E}=★ True).
Proof.
  iIntros (?) "Hinv". iVs (inv_open with "Hinv") as "[>HP Hclose]"; auto.
  iIntros "!==> {$HP} HP". iApply "Hclose"; auto.
Qed.
End inv.
