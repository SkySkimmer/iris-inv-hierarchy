From iris.bi Require Export bi.
From iris.proofmode Require Import tactics.
From iris.prelude Require Import options.

(** The class of laterable assertions *)
Class Laterable {PROP : bi} (P : PROP) := laterable :
  P -∗ ∃ Q, ▷ Q ∗ □ (▷ Q -∗ ◇ P).
Global Arguments Laterable {_} _%I : simpl never.
Global Arguments laterable {_} _%I {_}.
Global Hint Mode Laterable + ! : typeclass_instances.

Section instances.
  Context {PROP : bi}.
  Implicit Types P : PROP.
  Implicit Types Ps : list PROP.

  Global Instance laterable_proper : Proper ((⊣⊢) ==> (↔)) (@Laterable PROP).
  Proof. solve_proper. Qed.

  Global Instance later_laterable P : Laterable (▷ P).
  Proof.
    rewrite /Laterable. iIntros "HP". iExists P. iFrame.
    iIntros "!> HP !>". done.
  Qed.

  Global Instance timeless_laterable P :
    Timeless P → Laterable P.
  Proof.
    rewrite /Laterable. iIntros (?) "HP". iExists P%I. iFrame.
    iSplitR; first by iNext. iIntros "!> >HP !>". done.
  Qed.

  (** This lemma is not very useful: It needs a strange assumption about
      emp, and most of the time intuitionistic propositions can be just kept
      around anyway and don't need to be "latered".  The lemma exists
      because the fact that it needs the side-condition is interesting;
      it is not an instance because it won't usually get used. *)
  Lemma intuitionistic_laterable P :
    Timeless (PROP:=PROP) emp → Affine P → Persistent P → Laterable P.
  Proof.
    rewrite /Laterable. iIntros (???) "#HP".
    iExists emp%I. iSplitL; first by iNext.
    iIntros "!> >_". done.
  Qed.

  Global Instance sep_laterable P Q :
    Laterable P → Laterable Q → Laterable (P ∗ Q).
  Proof.
    rewrite /Laterable. iIntros (LP LQ) "[HP HQ]".
    iDestruct (LP with "HP") as (P') "[HP' #HP]".
    iDestruct (LQ with "HQ") as (Q') "[HQ' #HQ]".
    iExists (P' ∗ Q')%I. iSplitL; first by iFrame.
    iIntros "!> [HP' HQ']". iSplitL "HP'".
    - iApply "HP". done.
    - iApply "HQ". done.
  Qed.

  Global Instance exist_laterable {A} (Φ : A → PROP) :
    (∀ x, Laterable (Φ x)) → Laterable (∃ x, Φ x).
  Proof.
    rewrite /Laterable. iIntros (LΦ). iDestruct 1 as (x) "H".
    iDestruct (LΦ with "H") as (Q) "[HQ #HΦ]".
    iExists Q. iIntros "{$HQ} !> HQ". iExists x. by iApply "HΦ".
  Qed.

  Global Instance big_sepL_laterable Ps :
    Timeless (PROP:=PROP) emp →
    TCForall Laterable Ps →
    Laterable ([∗] Ps).
  Proof. induction 2; simpl; apply _. Qed.

  (* A wrapper to obtain a weaker, laterable form of any assertion. *)
  Definition make_laterable (Q : PROP) : PROP :=
    (∃ P, ▷ P ∗ □ (▷ P -∗ Q))%I.

  Global Instance make_laterable_ne : NonExpansive make_laterable.
  Proof. solve_proper. Qed.
  Global Instance make_laterable_proper : Proper ((≡) ==> (≡)) make_laterable := ne_proper _.
  Global Instance make_laterable_mono' : Proper ((⊢) ==> (⊢)) make_laterable.
  Proof. solve_proper. Qed.
  Global Instance make_laterable_flip_mono' :
    Proper (flip (⊢) ==> flip (⊢)) make_laterable.
  Proof. solve_proper. Qed.

  Lemma make_laterable_mono Q1 Q2 :
    (Q1 ⊢ Q2) → (make_laterable Q1 ⊢ make_laterable Q2).
  Proof. by intros ->. Qed.

  (** A stronger version of [make_laterable_mono] that lets us keep persistent
  resources. *)
  Lemma make_laterable_wand Q1 Q2 :
    □ (Q1 -∗ Q2) -∗ (make_laterable Q1 -∗ make_laterable Q2).
  Proof.
    iIntros "#HQ HQ1". iDestruct "HQ1" as (P) "[HP #HQ1]".
    iExists P. iFrame. iIntros "!> HP". iApply "HQ". iApply "HQ1". done.
  Qed.

  Global Instance make_laterable_laterable Q :
    Laterable (make_laterable Q).
  Proof.
    rewrite /Laterable. iIntros "HQ". iDestruct "HQ" as (P) "[HP #HQ]".
    iExists P. iFrame. iIntros "!> HP !>". iExists P. by iFrame.
  Qed.

  Lemma make_laterable_elim Q :
    make_laterable Q -∗ Q.
  Proof.
    iIntros "HQ". iDestruct "HQ" as (P) "[HP #HQ]". by iApply "HQ".
  Qed.

  (** Written internally (as an entailment of wands) to reflect
      that persistent assertions can be kept unchanged. *)
  Lemma make_laterable_intro P Q :
    Laterable P →
    □ (◇ P -∗ Q) -∗ P -∗ make_laterable Q.
  Proof.
    iIntros (?) "#HQ HP".
    iDestruct (laterable with "HP") as (P') "[HP' #HPi]". iExists P'.
    iFrame. iIntros "!> HP'". iApply "HQ". iApply "HPi". done.
  Qed.

End instances.

Typeclasses Opaque make_laterable.
