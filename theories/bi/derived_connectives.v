From iris.bi Require Export interface.
From iris.algebra Require Import monoid.
From stdpp Require Import hlist.

Definition bi_iff {PROP : bi} (P Q : PROP) : PROP := ((P → Q) ∧ (Q → P))%I.
Arguments bi_iff {_} _%I _%I : simpl never.
Instance: Params (@bi_iff) 1.
Infix "↔" := bi_iff : bi_scope.

Definition bi_wand_iff {PROP : bi} (P Q : PROP) : PROP :=
  ((P -∗ Q) ∧ (Q -∗ P))%I.
Arguments bi_wand_iff {_} _%I _%I : simpl never.
Instance: Params (@bi_wand_iff) 1.
Infix "∗-∗" := bi_wand_iff (at level 95, no associativity) : bi_scope.

Class Persistent {PROP : bi} (P : PROP) := persistent : P ⊢ <pers> P.
Arguments Persistent {_} _%I : simpl never.
Arguments persistent {_} _%I {_}.
Hint Mode Persistent + ! : typeclass_instances.
Instance: Params (@Persistent) 1.

Definition bi_affinely {PROP : bi} (P : PROP) : PROP := (emp ∧ P)%I.
Arguments bi_affinely {_} _%I : simpl never.
Instance: Params (@bi_affinely) 1.
Typeclasses Opaque bi_affinely.
Notation "'<affine>' P" := (bi_affinely P)
  (at level 20, right associativity) : bi_scope.

Class Affine {PROP : bi} (Q : PROP) := affine : Q ⊢ emp.
Arguments Affine {_} _%I : simpl never.
Arguments affine {_} _%I {_}.
Hint Mode Affine + ! : typeclass_instances.

Class BiAffine (PROP : bi) := absorbing_bi (Q : PROP) : Affine Q.
Hint Mode BiAffine ! : typeclass_instances.
Existing Instance absorbing_bi | 0.

Class BiPositive (PROP : bi) :=
  bi_positive (P Q : PROP) : <affine> (P ∗ Q) ⊢ <affine> P ∗ Q.
Hint Mode BiPositive ! : typeclass_instances.

Definition bi_absorbingly {PROP : bi} (P : PROP) : PROP := (True ∗ P)%I.
Arguments bi_absorbingly {_} _%I : simpl never.
Instance: Params (@bi_absorbingly) 1.
Typeclasses Opaque bi_absorbingly.
Notation "'<absorb>' P" := (bi_absorbingly P)
  (at level 20, right associativity) : bi_scope.

Class Absorbing {PROP : bi} (P : PROP) := absorbing : <absorb> P ⊢ P.
Arguments Absorbing {_} _%I : simpl never.
Arguments absorbing {_} _%I.
Hint Mode Absorbing + ! : typeclass_instances.

Definition bi_persistently_if {PROP : bi} (p : bool) (P : PROP) : PROP :=
  (if p then <pers> P else P)%I.
Arguments bi_persistently_if {_} !_ _%I /.
Instance: Params (@bi_persistently_if) 2.
Typeclasses Opaque bi_persistently_if.
Notation "'<pers>?' p P" := (bi_persistently_if p P)
  (at level 20, p at level 9, P at level 20,
   right associativity, format "'<pers>?' p  P") : bi_scope.

Definition bi_affinely_if {PROP : bi} (p : bool) (P : PROP) : PROP :=
  (if p then <affine> P else P)%I.
Arguments bi_affinely_if {_} !_ _%I /.
Instance: Params (@bi_affinely_if) 2.
Typeclasses Opaque bi_affinely_if.
Notation "'<affine>?' p P" := (bi_affinely_if p P)
  (at level 20, p at level 9, P at level 20,
   right associativity, format "'<affine>?' p  P") : bi_scope.

Definition bi_intuitionistically {PROP : bi} (P : PROP) : PROP :=
  (<affine> <pers> P)%I.
Arguments bi_intuitionistically {_} _%I : simpl never.
Instance: Params (@bi_intuitionistically) 1.
Typeclasses Opaque bi_intuitionistically.
Notation "□ P" := (bi_intuitionistically P)%I
  (at level 20, right associativity) : bi_scope.

Definition bi_intuitionistically_if {PROP : bi} (p : bool) (P : PROP) : PROP :=
  (if p then □ P else P)%I.
Arguments bi_intuitionistically_if {_} !_ _%I /.
Instance: Params (@bi_intuitionistically_if) 2.
Typeclasses Opaque bi_intuitionistically_if.
Notation "'□?' p P" := (bi_intuitionistically_if p P)
  (at level 20, p at level 9, P at level 20,
   right associativity, format "'□?' p  P") : bi_scope.

Fixpoint bi_hexist {PROP : bi} {As} : himpl As PROP → PROP :=
  match As return himpl As PROP → PROP with
  | tnil => id
  | tcons A As => λ Φ, ∃ x, bi_hexist (Φ x)
  end%I.
Fixpoint bi_hforall {PROP : bi} {As} : himpl As PROP → PROP :=
  match As return himpl As PROP → PROP with
  | tnil => id
  | tcons A As => λ Φ, ∀ x, bi_hforall (Φ x)
  end%I.

Definition sbi_laterN {PROP : sbi} (n : nat) (P : PROP) : PROP :=
  Nat.iter n sbi_later P.
Arguments sbi_laterN {_} !_%nat_scope _%I.
Instance: Params (@sbi_laterN) 2.
Notation "▷^ n P" := (sbi_laterN n P)
  (at level 20, n at level 9, P at level 20, format "▷^ n  P") : bi_scope.
Notation "▷? p P" := (sbi_laterN (Nat.b2n p) P)
  (at level 20, p at level 9, P at level 20, format "▷? p  P") : bi_scope.

Definition sbi_except_0 {PROP : sbi} (P : PROP) : PROP := (▷ False ∨ P)%I.
Arguments sbi_except_0 {_} _%I : simpl never.
Notation "◇ P" := (sbi_except_0 P) (at level 20, right associativity) : bi_scope.
Instance: Params (@sbi_except_0) 1.
Typeclasses Opaque sbi_except_0.

Class Timeless {PROP : sbi} (P : PROP) := timeless : ▷ P ⊢ ◇ P.
Arguments Timeless {_} _%I : simpl never.
Arguments timeless {_} _%I {_}.
Hint Mode Timeless + ! : typeclass_instances.
Instance: Params (@Timeless) 1.
