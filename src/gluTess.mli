(* $Id: gluTess.mli,v 1.3 1999-11-15 14:32:15 garrigue Exp $ *)

type t

val create : unit -> t

val begins : t -> unit
val ends : t -> unit

val vertex : t -> ?data:'a -> [`double] Raw.t -> unit

val next_contour : t -> type:[`ccw|`cw|`exterior|`interior|`unknown] -> unit

(* The following functions are only available in GLU version 1.2 *)

val begin_contour : t -> unit
val end_contour : t -> unit

val begin_polygon : ?data:'a -> t -> unit
val end_polygon : t -> unit

val normal : t -> Gl.vect3 -> unit

type property = [
    `winding_rule [`odd|`nonzero|`positive|`negative|`abs_geq_two]
  | `boundary_only bool
  | `tolerance float
]
val property : t -> property -> unit

