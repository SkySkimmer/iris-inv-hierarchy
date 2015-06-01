Require Import Ssreflect.ssreflect.
Require Import Setoid SetoidClass.
Require Import Eqdep_dec.

Ltac find_rewrite1 t0 t1 := match goal with
                            | H: t0 = t1 |- _ => rewrite-> H
                            | H: t0 == t1 |- _ => rewrite-> H
                            | H: t1 = t0 |- _ => rewrite<- H
                            | H: t1 == t0 |- _ => rewrite<- H
                            end.
Ltac find_rewrite2 t0 t1 t2 := find_rewrite1 t0 t1; find_rewrite1 t1 t2.
Ltac find_rewrite3 t0 t1 t2 t3 := find_rewrite2 t0 t1 t2; find_rewrite1 t2 t3.


(* A tactic for dependant destruct. Essentially, the tactic allows you to declare which
   occurences of a term you want to be replaced by the destructed form. If you choose
   correctly, the result will be a well-typed term.
   Usually, you can obtain the list of indices as follows:
   * List the indices of occurences of T that are *outisde* of the return function
     of a dependant match.
   * Increrment every index by 2, and add 1 to the list
   The last step is necessary because ddes adds two more occurences of the term before doing
   the actual pattern-matching, of which you only want to replace the first. *)
Tactic Notation "ddes" constr(T) "at" integer_list(pos) "as" simple_intropattern(pat) "deqn:" ident(EQ) :=
  (generalize (@eq_refl _ (T)) as EQ; pattern (T) at pos;
   destruct (T) as pat; move => EQ).

Ltac split_conjs := repeat (match goal with [ |- _ /\ _ ] => split end).

Lemma de_ft_eq: false = true <-> False.
Proof.
  split; tauto || discriminate.
Qed.
Lemma de_tf_eq: true = false <-> False.
Proof.
  split; tauto || discriminate.
Qed.
Lemma de_tt_eq: true = true <-> True.
Proof.
  split; intros; tauto || reflexivity.
Qed.
Lemma de_ff_eq: false = false <-> True.
Proof.
  split; intros; tauto || reflexivity.
Qed.

(* TODO RJ: Is this already defined somewhere? *)
Class DecEq (T : Type) := dec_eq : forall (t1 t2: T), {t1 = t2} + {t1 <> t2}.

Lemma DecEq_refl {T: Type} {eqT: DecEq T} t:
  dec_eq t t = left eq_refl.
Proof.
  destruct (dec_eq t t) as [EQ|NEQ]; last (exfalso; now apply NEQ).
  f_equal. apply eq_proofs_unicity.
  move=>t1 t2. clear -eqT. destruct (dec_eq t1 t2); tauto.
Qed.

Global Instance DecEqBool: DecEq bool.
Proof.
  move=>b1 b2. decide equality.
Qed.

Global Instance DecEqNat: DecEq nat.
Proof.
  move=>n1 n2. decide equality.
Qed.

Ltac contradiction_eq := match goal with
                         | [ H : ?i <> ?i |- _ ] => exfalso; now apply H
                         end.

(* Well-founded induction. *)
Definition wf_nat_ind := well_founded_induction Wf_nat.lt_wf.

  