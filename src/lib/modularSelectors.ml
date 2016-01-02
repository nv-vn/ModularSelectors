type 'a version =
  [> `Any
   | `V of int * int * int
   | `Stable
   | `Legacy
   | `Testing ] as 'a

type language = Native | ML

type 'a os =
  [> `Any
   | `Linux
   | `OSX
   | `BSD
   | `UNIX
   | `Windows ] as 'a

type 'a arch =
  [> `Any
   | `Amd64
   | `X86 ] as 'a

type ('version, 'os, 'arch, 'info) t =
  { version : 'version version;
    language : language;
    os : 'os os;
    arch : 'arch arch;
    info : 'info list }

let default =
  { version = `Any;
    language = ML;
    os = `Any;
    arch = `Any;
    info = [] }

module type SELECTOR = sig
  val s : ('a, 'b, 'c, 'd) t
end
