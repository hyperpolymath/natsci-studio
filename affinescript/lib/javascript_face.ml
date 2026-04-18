(** javascript_face.ml — JavaScript syntax face for AffineScript
    Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
    SPDX-License-Identifier: PMPL-1.0-or-later

    Transforms JavaScript-style syntax into canonical AffineScript AST.
    This is a thin syntactic layer; all type checking and codegen happen
    in the core AffineScript compiler.
*)

open Ast
open Core

(* JavaScript keywords and mappings *)
let javascript_keywords = [
  ("function", "def");
  ("const", "let");
  ("let", "let");
  ("if", "if");
  ("else", "else");
  ("for", "for");
  ("in", "in");
  ("of", "of");
  ("while", "while");
  ("break", "break");
  ("continue", "continue");
  ("return", "return");
  ("try", "try");
  ("catch", "catch");
  ("finally", "finally");
  ("class", "type");
  ("extends", "extends");
  ("true", "true");
  ("false", "false");
  ("null", "()");
  ("&&", "&&");
  ("||", "||");
  ("!", "!");
  ("import", "use");
  ("from", "from");
  ("export", "export");
]

(* Transform JavaScript tokens to AffineScript tokens *)
let transform_token (tok : Token.t) : Token.t =
  let open Token in
  match tok with
  | Ident s when List.assoc_opt s javascript_keywords <> None ->
      Ident (List.assoc s javascript_keywords)
  | _ -> tok

(* Transform JavaScript AST to AffineScript AST *)
let transform_javascript (prog : Ast.program) : Ast.program =
  (* Apply token transformation to the entire AST *)
  let rec transform_expr (e : Ast.expr) : Ast.expr =
    match e with
    | EIdent (loc, s) ->
        let s' = match List.assoc_opt s javascript_keywords with
          | Some replacement -> replacement
          | None -> s
        in
        EIdent (loc, s')
    | EBinOp (loc, op, e1, e2) ->
        let op' = match op with
          | "&&" -> "&&"
          | "||" -> "||"
          | _ -> op
        in
        EBinOp (loc, op', transform_expr e1, transform_expr e2)
    | EUnOp (loc, op, e) ->
        let op' = match op with
          | "!" -> "!"
          | _ -> op
        in
        EUnOp (loc, op', transform_expr e)
    | EIf (loc, cond, thn, els) ->
        EIf (loc, transform_expr cond, transform_block thn, Option.map transform_block els)
    | EMatch (loc, scrut, cases) ->
        EMatch (loc, transform_expr scrut, List.map transform_case cases)
    | ELet (loc, pat, e1, e2) ->
        ELet (loc, transform_pat pat, transform_expr e1, transform_expr e2)
    | EApp (loc, f, args) ->
        EApp (loc, transform_expr f, List.map transform_expr args)
    | ETuple (loc, es) -> ETuple (loc, List.map transform_expr es)
    | EList (loc, es) -> EList (loc, List.map transform_expr es)
    | ERecord (loc, fields) -> ERecord (loc, List.map (fun (f, e) -> (f, transform_expr e)) fields)
    | EProj (loc, e, f) -> EProj (loc, transform_expr e, f)
    | ELit (loc, lit) -> ELit (loc, lit)
    | EUnit loc -> EUnit loc
    | EAnnot (loc, e, ty) -> EAnnot (loc, transform_expr e, ty)
    | EParen (loc, e) -> EParen (loc, transform_expr e)
    | ESeq (loc, es) -> ESeq (loc, List.map transform_expr es)
    | EBlock (loc, es) -> EBlock (loc, List.map transform_expr es)
    | EFor (loc, pat, e, body) -> EFor (loc, transform_pat pat, transform_expr e, transform_expr body)
    | EWhile (loc, cond, body) -> EWhile (loc, transform_expr cond, transform_expr body)
    | EBreak loc -> EBreak loc
    | EContinue loc -> EContinue loc
    | EReturn (loc, e) -> EReturn (loc, Option.map transform_expr e)
    | EThrow (loc, e) -> EThrow (loc, transform_expr e)
    | ETry (loc, body, handlers) -> ETry (loc, transform_expr body, List.map transform_handler handlers)
    | EEffect (loc, eff, args) -> EEffect (loc, eff, List.map transform_expr args)
    | EHandle (loc, e, handlers) -> EHandle (loc, transform_expr e, List.map transform_handler handlers)
    | EExternal (loc, s) -> EExternal (loc, s)
    | EHole loc -> EHole loc
  and transform_block (blk : Ast.block) : Ast.block =
    { blk with body = List.map transform_stmt blk.body }
  and transform_stmt (stmt : Ast.stmt) : Ast.stmt =
    match stmt with
    | SExpr e -> SExpr (transform_expr e)
    | SLet (loc, pat, e) -> SLet (loc, transform_pat pat, transform_expr e)
    | SDef (loc, name, params, ret, body) ->
        SDef (loc, name, List.map transform_param params, ret, transform_block body)
    | SType (loc, name, params, defn) -> SType (loc, name, params, transform_type_defn defn)
    | SEffect (loc, name, params, ops) -> SEffect (loc, name, params, List.map transform_effect_op ops)
    | SExternal (loc, name, ty) -> SExternal (loc, name, ty)
    | SImport (loc, path) -> SImport (loc, path)
    | SModule (loc, name, body) -> SModule (loc, name, transform_block body)
  and transform_param (p : Ast.param) : Ast.param =
    { p with ty = p.ty }
  and transform_pat (pat : Ast.pattern) : Ast.pattern =
    match pat with
    | PWild loc -> PWild loc
    | PVar (loc, s) -> PVar (loc, s)
    | PLit (loc, lit) -> PLit (loc, lit)
    | PConstr (loc, c, pats) -> PConstr (loc, c, List.map transform_pat pats)
    | PTuple (loc, pats) -> PTuple (loc, List.map transform_pat pats)
    | PRecord (loc, fields) -> PRecord (loc, List.map (fun (f, p) -> (f, transform_pat p)) fields)
    | PAnnot (loc, p, ty) -> PAnnot (loc, transform_pat p, ty)
    | POr (loc, p1, p2) -> POr (loc, transform_pat p1, transform_pat p2)
    | PParen (loc, p) -> PParen (loc, transform_pat p)
  and transform_type_defn (defn : Ast.type_defn) : Ast.type_defn =
    match defn with
    | TRecord fields -> TRecord (List.map (fun (f, ty) -> (f, ty)) fields)
    | TVariant cases -> TVariant (List.map (fun (c, tys) -> (c, tys)) cases)
    | TAlias ty -> TAlias ty
    | TOpaque -> TOpaque
  and transform_effect_op (op : Ast.effect_op) : Ast.effect_op =
    { op with ty = op.ty }
  and transform_handler (h : Ast.handler) : Ast.handler =
    { h with body = transform_expr h.body }
  and transform_case (c : Ast.case) : Ast.case =
    { c with pat = transform_pat c.pat; body = transform_expr c.body }
  in
  { prog with items = List.map transform_stmt prog.items }

(* Entry point for the JavaScript face *)
let transform_program (prog : Ast.program) : Ast.program =
  transform_javascript prog
