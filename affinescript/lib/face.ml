(** face.ml — Face selection and error vocabulary
    Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
    SPDX-License-Identifier: PMPL-1.0-or-later

    Dispatches to the appropriate face transformer and provides
    face-specific error messages.
*)

open Ast
open Core

(* Available faces *)
type face = 
  | Python
  | Pseudocode
  | JavaScript
  | Canonical

(* Face-specific error messages *)
let face_error_vocab (face : face) : string * string =
  match face with
  | Python -> ("Python", "rattle")
  | Pseudocode -> ("Pseudocode", "pseudo")
  | JavaScript -> ("JavaScript", "jaffa")
  | Canonical -> ("AffineScript", "affinescript")

(* Transform program based on face *)
let transform_for_face (face : face) (prog : Ast.program) : Ast.program =
  match face with
  | Python -> Python_face.transform_program prog
  | Pseudocode -> Pseudocode_face.transform_program prog
  | JavaScript -> Javascript_face.transform_program prog
  | Canonical -> prog

(* Detect face from file extension *)
let detect_face (filename : string) : face =
  if Filename.check_suffix filename ".rattle" || Filename.check_suffix filename ".pyaff" then
    Python
  else if Filename.check_suffix filename ".pseudo" then
    Pseudocode
  else if Filename.check_suffix filename ".jaffa" then
    JavaScript
  else
    Canonical
