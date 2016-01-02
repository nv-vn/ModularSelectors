open ModularSelectors

module TestModuleStable = struct
  let show_version () = print_endline "TestModule, Version Stable [1.0]"
  let do_stuff () = print_endline "Doing stuff..."
end

module TestModuleLegacy = struct
  let show_version () = print_endline "TestModule, Version Legacy [0.9]"
  let do_stuff () = failwith "Not yet implemented"
end

module TestModule (S : SELECTOR) = struct
  let stable = match S.s.version with
    | `Stable -> true
    | `Legacy -> false
    | x when x >= `V (1, 0, 0) -> true
    | x when x <  `V (1, 0, 0) -> false
    | _ -> failwith "Unknown selection"

  let show_version =
    if stable then
      TestModuleStable.show_version
    else
      TestModuleLegacy.show_version

  let do_stuff =
    if stable then
      TestModuleStable.do_stuff
    else
      TestModuleLegacy.do_stuff
end

include TestModule [@@select version = `Stable]

let _ =
  show_version ();
  do_stuff ()
