(** python_face.mli — Python syntax face for AffineScript
    Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
    SPDX-License-Identifier: PMPL-1.0-or-later

    Transforms Python-style syntax into canonical AffineScript AST.
    This is a thin syntactic layer; all type checking and codegen happen
    in the core AffineScript compiler.
*)

open Ast

(* Transform Python AST to AffineScript AST *)
val transform_program : Ast.program -> Ast.program
