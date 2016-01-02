open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let uniq =
  let x = ref 0 in
  fun start ->
    x := !x + 1;
    start ^ string_of_int !x

let rec list_of_sequence ?(acc=[]) = function
  | [%expr [%e? name] = [%e? value]] -> (name, value) :: acc
  | [%expr [%e? name] = [%e? value]; [%e? rest]] -> list_of_sequence ~acc:((name, value) :: acc) rest
  | _ -> acc

let rec make_assign ?(acc=[]) = function
  | ({ pexp_desc = Pexp_ident name; _ }, choice) :: rest ->
    make_assign ~acc:((name, choice) :: acc) rest
  | _ -> acc

let gen_include loc mod_ assignments = (* Why is `mod` a syntax error? *)
  Str.include_ ~loc
    (Incl.mk ~loc
      (Mod.apply ~loc mod_
        (Mod.structure ~loc
          [Str.value ~loc Nonrecursive
            [Vb.mk ~loc (Pat.var ~loc {txt = "s"; loc = loc})
              (Exp.record ~loc assignments (Some
                (Exp.ident ~loc { loc = loc;
                  txt = Ldot ((Lident "ModularSelectors"), "default") })))]])))

let json_type_mapper argv =
  { default_mapper with
    structure_item = begin fun mapper stri ->
      match stri with
      | { pstr_loc; pstr_desc = Pstr_include { pincl_mod; pincl_attributes; _ } } ->
        let payloads = List.filter (fun ({ txt = name; _ }, _) -> name = "select") pincl_attributes in
        begin match List.nth payloads 0 |> fun (_, payload) -> payload with
        | PStr [{ pstr_desc = Pstr_eval ({ pexp_desc = Pexp_sequence (l, r); _ }, _)}] ->
          let patterns = list_of_sequence (Exp.sequence l r) in
          let assignments = make_assign patterns in
          gen_include pstr_loc pincl_mod assignments
        | PStr [{ pstr_desc = Pstr_eval ([%expr [%e? name] = [%e? value]], _) }] ->
          let name' = begin match name with 
            | { pexp_desc = Pexp_ident name; _ } -> name
            | _ -> failwith "Invalid input to [@@select ...]"
          end in gen_include pstr_loc pincl_mod [(name', value)]
        | _ -> failwith "Invalid input to [@@select ...]"
        end
      | x -> default_mapper.structure_item mapper x
    end;
  }

let _ = register "json_type" json_type_mapper
