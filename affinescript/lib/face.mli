(** face.mli — Face selection and error vocabulary
    Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
    SPDX-License-Identifier: PMPL-1.0-or-later

    Dispatches to the appropriate face transformer and provides
    face-specific error messages.
*)

open Ast

(* Available faces *)
type face = 
  | Python
  | Pseudocode
  | JavaScript
  | Canonical

(* Face-specific error messages *)
val face_error_vocab : face -> string * string

(* Transform program based on face *)
val transform_for_face : face -> Ast.program -> Ast.program

(* Detect face from file extension *)
val detect_face : string -> face
