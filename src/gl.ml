(* $Id: gl.ml,v 1.19 1998-01-23 13:30:17 garrigue Exp $ *)

(* Register an exception *)

exception GLerror of string

let _ = Callback.register_exception "glerror" (GLerror "")

(* Plenty of small C wrappers *)

type rgb = float * float * float
type rgba = float * float * float * float

type point2 = float * float
type point3 = float * float * float
type point4 = float * float * float * float

type clampf = float
type glist = int

type gltype = [bitmap byte ubyte short ushort int uint float]
type pixels_format =
    [ color_index stencil_index depth_component rgba
      red green blue alpha rgb luminance luminance_alpha ]
type ('a,'b) image = { format: 'a ; width: int ; height:int ; raw: 'b Raw.t }
let format_size (format : #pixels_format) =
  match format with
    `rgba -> 4
  | `rgb -> 3
  | `luminance_alpha -> 2
  | _ -> 1

type curve_type =
    [vertex_3 vertex_4 index color_4 normal texture_coord_1 texture_coord_2
     texture_coord_3 texture_coord_4 trim_2 trim_3]
let target_size (target : #curve_type) =
    match target with
      `index|`normal|`texture_coord_1 -> 1
    | `texture_coord_2|`trim_2 -> 2
    | `vertex_3|`texture_coord_3|`trim_3 -> 3
    | `vertex_4|`color_4|`texture_coord_4 -> 4

type cmp_func = [ never less equal lequal greater notequal gequal always ]
type face = [front back both]
type cap = [
      alpha_test
      auto_normal
      blend
      clip_plane0
      clip_plane1
      clip_plane2
      clip_plane3
      clip_plane4
      clip_plane5
   (* color_logic_op *)
      color_material
      cull_face
      depth_test
      dither
      fog
   (* index_logic_op *)
      light0
      light1
      light2
      light3
      light4
      light5
      light6
      light7
      lighting
      line_smooth
      line_stipple
      logic_op
      map1_color_4
      map1_index
      map1_normal
      map1_texture_coord_1
      map1_texture_coord_2
      map1_texture_coord_3
      map1_texture_coord_4
      map1_vertex_3
      map1_vertex_4
      map2_color_4
      map2_index
      map2_normal
      map2_texture_coord_1
      map2_texture_coord_2
      map2_texture_coord_3
      map2_texture_coord_4
      map2_vertex_3
      map2_vertex_4
      normalize
(*    polygon_offset_fill
      polygon_offset_line
      polygon_offset_point *)
      point_smooth
      polygon_smooth
      polygon_stipple
      scissor_test
      stencil_test
      texture_1d
      texture_2d
      texture_gen_q
      texture_gen_r
      texture_gen_s
      texture_gen_t
  ]

type accum_op = [accum load add mult return]
external accum : op:accum_op -> float -> unit = "ml_glAccum"
external alpha_func : cmp_func -> ref:clampf -> unit = "ml_glAlphaFunc"

type begin_enum =
    [ points lines polygon triangles quads line_strip
      line_loop triangle_strip triangle_fan quad_strip ]
external begin_block : begin_enum -> unit = "ml_glBegin"
external bitmap :
    width:int -> height:int -> orig:point2 -> move:point2 ->
    [bitmap] Raw.t -> unit
    = "ml_glBitmap"
type bitmap = ([color_index],[bitmap]) image
let bitmap (img : bitmap) =
  bitmap width:img.width height:img.height img.raw

type sfactor = [
      zero
      one
      dst_color
      one_minus_dst_color
      src_alpha
      one_minus_src_alpha
      dst_alpha
      one_minus_dst_alpha
      src_alpha_saturate
      constant_color_ext
      one_minus_constant_color_ext
      constant_alpha_ext
      one_minus_constant_alpha_ext
  ]
type dfactor = [
      zero
      one
      src_color
      one_minus_src_color
      src_alpha
      one_minus_src_alpha
      dst_alpha
      one_minus_dst_alpha
      constant_color_ext
      one_minus_constant_color_ext
      constant_alpha_ext
      one_minus_constant_alpha_ext
  ]
external blend_func : src:sfactor -> dst:dfactor -> unit = "ml_glBlendFunc"

external clear_accum : float -> float -> float -> float -> unit
    = "ml_glClearAccum"
let clear_accum (r,g,b : rgb) ?:alpha [< 1. >] =
  clear_accum r g b alpha
type buffer = [color depth accum stencil]
external clear : buffer list -> unit = "ml_glClear"
external clear_color :
    red:float -> green:float -> blue:float -> alpha:float -> unit
    = "ml_glClearColor"
let clear_color (red, green, blue : rgb) ?:alpha [< 1. >] =
  clear_color :red :green :blue :alpha
external clear_depth : clampf -> unit = "ml_glClearDepth"
external clear_index : float -> unit = "ml_glClearIndex"
external clear_stencil : int -> unit = "ml_glClearStencil"
external clip_plane : plane:int -> equation:float array -> unit
    = "ml_glClipPlane"
let clip_plane :plane :equation =
  if plane < 0 or plane > 5 or Array.length equation <> 4
  then invalid_arg "Gl.clip_plane";
  clip_plane :plane :equation
external color :
    red:float -> green:float -> blue:float -> alpha:float -> unit
    = "ml_glColor4d"
let color (red, green, blue : rgb) ?:alpha [< 1. >] =
  color :red :green :blue :alpha

external color_mask : bool -> bool -> bool -> bool -> unit
    = "ml_glColorMask"
let color_mask ?:red [< false >] ?:green [< false >] ?:blue [< false >]
    ?:alpha [< false >] =
  color_mask red green blue alpha

type color_material = [emission ambient diffuse specular ambient_and_diffuse]
external color_material : :face -> color_material -> unit
    = "ml_glColorMaterial"

external copy_pixels :
    x:int -> y:int -> width:int -> height:int ->
    type:[color depth stencil] -> unit
    = "ml_glCopyPixels"

external cull_face : face -> unit = "ml_glCullFace"

external depth_func : cmp_func -> unit = "ml_glDepthFunc"
external depth_mask : bool -> unit = "ml_glDepthMask"
external depth_range : near:float -> far:float -> unit = "ml_glDepthRange"
external disable : cap -> unit = "ml_glDisable"
type draw_buffer_mode =
    [ none front_left front_right back_left back_right
      front back left right front_and_back aux(int) ] 
external draw_buffer : draw_buffer_mode -> unit = "ml_glDrawBuffer"
external draw_pixels :
    width:int -> height:int -> format:#pixels_format -> #gltype Raw.t -> unit
    = "ml_glDrawPixels"
let draw_pixels img =
  draw_pixels img.raw width:img.width height:img.height format:img.format

external edge_flag : bool -> unit = "ml_glEdgeFlag"
external enable : cap -> unit = "ml_glEnable"
external end_block : unit -> unit = "ml_glEnd"
external eval_coord1 : float -> unit = "ml_glEvalCoord1d"
external eval_coord2 : float -> float -> unit = "ml_glEvalCoord1d"
external eval_mesh1 : mode:[point line] -> int -> int -> unit
    = "ml_glEvalMesh1"
external eval_mesh2 :
    mode:[point line fill] -> int -> int -> int -> int -> unit
    = "ml_glEvalMesh2"
external eval_point1 : int -> unit = "ml_glEvalPoint1"
external eval_point2 : int -> int -> unit = "ml_glEvalPoint2"

external flush : unit -> unit = "ml_glFlush"
external finish : unit -> unit = "ml_glFinish"
type fog_param = [
      mode ([linear exp exp2])
      density (float)
      start (float)
      End (float)
      index (float)
      color (rgba)
  ]
external fog : fog_param -> unit = "ml_glFog"
external front_face : [cw ccw] -> unit = "ml_glFrontFace"
external frustum :
    x:(float * float) -> y:(float * float) -> z:(float * float) -> unit
    = "ml_glFrustum"

external get_string : [vendor renderer version extensions] -> string
    = "ml_glGetString"

type hint_target =
    [fog line_smooth perspective_correction point_smooth polygon_smooth]
type hint = [fastest nicest dont_care]
external hint : target:hint_target -> hint -> unit = "ml_glHint"

external index_mask : int -> unit = "ml_glIndexMask"
external index : float -> unit = "ml_glIndexd"
external init_names : unit -> unit = "ml_glInitNames"
external is_enabled : cap -> bool = "ml_glIsEnabled"

type light_param = [
      ambient (rgba)
      diffuse (rgba)
      specular (rgba)
      position (point4)
      spot_direction (point4)
      spot_exponent (float)
      spot_cutoff (float)
      constant_attenuation (float)
      linear_attenuation (float)
      quadratic_attenuation (float)
  ] 
external light : num:int -> light_param -> unit
    = "ml_glLight"
type light_model_param =
    [ ambient (rgba) local_viewer (float) two_side (float) ]
external light_model : light_model_param -> unit = "ml_glLightModel"
external line_width : float -> unit = "ml_glLineWidth"
external line_stipple : factor:int -> pattern:int -> unit = "ml_glLineStipple"
external load_name : int -> unit = "ml_glLoadName"
external load_identity : unit -> unit = "ml_glLoadIdentity"
external load_matrix : [double] Raw.t -> unit = "ml_glLoadMatrixd"
let load_matrix m =
  if Raw.length m <> 16 then invalid_arg "Gl.load_matrix";
  load_matrix m
type logic_op =
    [ clear set copy copy_inverted noop invert And nand Or nor
      xor equiv and_reverse and_inverted or_reverse or_inverted ]
external logic_op : logic_op -> unit = "ml_glLogicOp"

type map_target =
    [ vertex_3 vertex_4 index color_4 normal texture_coord_1 texture_coord_2
      texture_coord_3 texture_coord_4 ]
external map1 :
    target:map_target -> (float*float) -> order:int -> [double] Raw.t -> unit
    = "ml_glMap1d"
external map2 :
    target:map_target -> (float*float) -> order:int ->
    (float*float) -> order:int -> [double] Raw.t -> unit
    = "ml_glMap2d_bc" "ml_glMap2d"
external map_grid1 : n:int -> range:(float * float) -> unit
    = "ml_glMapGrid1d"
external map_grid2 :
    n:int -> range:(float * float) -> n:int -> range:(float * float) -> unit
    = "ml_glMapGrid2d"
type material_param = [
      ambient (rgba)
      diffuse (rgba)
      specular (rgba)
      emission (rgba)
      shininess (float)
      ambient_and_diffuse (rgba)
      color_indexes (float * float * float)
  ] 
external material : face:face -> material_param -> unit
    = "ml_glMaterial"
external matrix_mode : [modelview projection texture] -> unit
    = "ml_glMatrixMode"
external mult_matrix : [double] Raw.t -> unit = "ml_glMultMatrixd"
let mult_matrix m =
  if Raw.length m <> 16 then invalid_arg "Gl.mult_matrix";
  mult_matrix m

external normal : x:float -> y:float -> z:float -> unit
    = "ml_glNormal3d"
let normal ?:x [< 0.0 >] ?:y [< 0.0 >] ?:z [< 0.0 >] = normal :x :y :z
and normal3 (x,y,z) = normal :x :y :z

external ortho :
    x:(float * float) -> y:(float * float) -> z:(float * float) -> unit
    = "ml_glOrtho"

external pass_through : float -> unit = "ml_glPassThrough"

type pixel_map =
    [i_to_i i_to_r i_to_g i_to_b i_to_a s_to_s r_to_r g_to_g b_to_b a_to_a]
external pixel_map : map:pixel_map -> float array -> unit
    = "ml_glPixelMapfv"

type pixel_store = [
      pack_swap_bytes (bool)
      pack_lsb_first (bool)
      pack_row_length (int)
      pack_skip_pixels (int)
      pack_skip_rows (int)
      pack_alignment (int)
      unpack_swap_bytes (bool)
      unpack_lsb_first (bool)
      unpack_row_length (int)
      unpack_skip_pixels (int)
      unpack_skip_rows (int)
      unpack_alignment (int)
  ]
external pixel_store : pixel_store -> unit = "ml_glPixelStorei"

type pixel_transfer = [
      map_color (bool)
      map_stencil (bool)
      index_shift (int)
      index_offset (int)
      red_scale (float)
      red_bias (float)
      green_scale (float)
      green_bias (float)
      blue_scale (float)
      blue_bias (float)
      alpha_scale (float)
      alpha_bias (float)
      depth_scale (float)
      depth_bias (float)
  ]
external pixel_transfer : pixel_transfer -> unit = "ml_glPixelTransfer"

external pixel_zoom : x:float -> y:float -> unit = "ml_glPixelZoom"
external point_size : float -> unit = "ml_glPointSize"
external polygon_mode : face:face -> mode:[point line fill] -> unit
    = "ml_glPolygonMode"
external polygon_stipple : mask:string -> unit = "ml_glPolygonStipple"
external pop_attrib : unit -> unit = "ml_glPopAttrib"
external pop_matrix : unit -> unit = "ml_glPopMatrix"
external pop_name : unit -> unit = "ml_glPopName"
type attrib_bit =
    [ accum_buffer color_buffer current depth_buffer enable eval fog
      hint lighting line list pixel_mode point polygon polygon_stipple
      scissor stencil_buffer texture transform viewport ]
external push_attrib : attrib_bit list -> unit = "ml_glPushAttrib"
external push_matrix : unit -> unit = "ml_glPushMatrix"
external push_name : int -> unit = "ml_glPushName"

external raster_pos : x:float -> y:float -> ?z:float -> ?w:float -> unit
    = "ml_glRasterPos"
type read_buffer =
    [ front_left front_right back_left back_right front back
      left right aux(int) ]
external read_buffer : read_buffer -> unit = "ml_glReadBuffer"
external read_pixels :
    x:int -> y:int -> width:int -> height:int ->
    format:#pixels_format -> #gltype Raw.t -> unit
    = "ml_glReadPixels_bc" "ml_glReadPixels"
let read_pixels :x :y :width :height :format type:t =
  let raw = Raw.create t len:(width * height * format_size format) in
  read_pixels :x :y :width :height :format raw;
  { raw = raw; width = width; height = height; format = format }
external rect : point2 -> point2 -> unit = "ml_glRectd"
external render_mode : [render select feedback] -> int = "ml_glRenderMode"
external rotate : angle:float -> x:float -> y:float -> z:float -> unit
    = "ml_glRotated"
let rotate :angle ?:x [< 0. >] ?:y [< 0. >] ?:z [< 0. >] =
  rotate :angle :x :y :z

external scale : x:float -> y:float -> z:float -> unit = "ml_glScaled"
let scale ?:x [< 1. >] ?:y [< 1. >] ?:z [< 1. >] = scale :x :y :z
external select_buffer : [uint] Raw.t -> unit = "ml_glSelectBuffer"
external shade_model : [flat smooth] -> unit = "ml_glShadeModel"
external stencil_func : cmp_func -> ref:int -> mask:int -> unit
    = "ml_glStencilFunc"
external stencil_mask : int -> unit = "ml_glStencilMask"
type stencil_op = [ keep zero replace incr decr invert ]
external stencil_op :
    fail:stencil_op -> zfail:stencil_op -> zpass:stencil_op -> unit
    = "ml_glStencilOp"
let stencil_op ?:fail [< `keep >] ?:zfail [< `keep >] ?:zpass [< `keep >] =
  stencil_op :fail :zfail :zpass

external tex_coord1 : float -> unit = "ml_glTexCoord1d"
external tex_coord2 : float -> float -> unit = "ml_glTexCoord2d"
external tex_coord3 : float -> float -> float -> unit = "ml_glTexCoord3d"
external tex_coord4 : float -> float -> float -> float -> unit
    = "ml_glTexCoord4d"
let default x = function Some x -> x | None -> x
let tex_coord :s ?:t ?:r ?:q =
  match q with
    Some q -> tex_coord4 s (default 0.0 t) (default 0.0 r) q
  | None -> match r with
      Some r -> tex_coord3 s (default 0.0 t) r
    | None -> match t with
	Some t -> tex_coord2 s t
      |	None -> tex_coord1 s
let tex_coord2 (s,t) = tex_coord2 s t
let tex_coord3 (s,t,r) = tex_coord3 s t r
let tex_coord4 (s,t,r,q) = tex_coord4 s t r q
type tex_env_param =
    [mode([modulate decal blend replace]) color(rgba)]
external tex_env : tex_env_param -> unit = "ml_glTexEnv"
type tex_coord = [s t r q]
type tex_gen_param = [
      mode([object_linear eye_linear sphere_map])
      object_plane(point4)
      eye_plane(point4)
  ]
external tex_gen : coord:tex_coord -> tex_gen_param -> unit = "ml_glTexGen"
type tex_format =
    [ color_index red green blue alpha rgb rgba luminance luminance_alpha ]
external tex_image1d :
    proxy:bool -> level:int -> internal:int ->
    width:int -> border:bool -> format:#tex_format -> #gltype Raw.t -> unit
    = "ml_glTexImage1D_bc""ml_glTexImage1D"
let tex_image1d img ?:proxy [< false >] ?:level [< 0 >]
    ?:internal [< format_size img.format >] ?:border [< false >] =
  if img.width mod 2 <> 0 then raise (GLerror "Gl.tex_image1d : bad width");
  if img.height < 1 then raise (GLerror "Gl.tex_image1d : bad height");
  tex_image1d :proxy :level :internal width:img.width :border
    format:img.format img.raw
external tex_image2d :
    proxy:bool -> level:int -> internal:int -> width:int ->
    height:int -> border:bool -> format:#tex_format -> #gltype Raw.t -> unit
    = "ml_glTexImage2D_bc""ml_glTexImage2D"
let tex_image2d img ?:proxy [< false >] ?:level [< 0 >]
    ?:internal [< format_size img.format >] ?:border [< false >] =
  if img.width mod 2 <> 0 then raise (GLerror "Gl.tex_image2d : bad width");
  if img.height mod 2 <> 0 then raise (GLerror "Gl.tex_image2d : bad height");
  tex_image2d :proxy :level :internal :border
    width:img.width height:img.height format:img.format img.raw
type tex_filter =
    [ nearest linear nearest_mipmap_nearest linear_mipmap_nearest
      nearest_mipmap_linear linear_mipmap_linear ]
type tex_wrap = [clamp repeat]
type tex_param =
    [ min_filter(tex_filter) mag_filter([nearest linear])
      wrap_s(tex_wrap) wrap_t(tex_wrap) border_color(rgba)
      priority(clampf) ]
external tex_parameter : target:[texture_1d texture_2d] -> tex_param -> unit
    = "ml_glTexParameter"
external translate : x:float -> y:float -> z:float -> unit = "ml_glTranslated"
let translate ?:x [< 0. >] ?:y [< 0. >] ?:z [< 0. >] = translate :x :y :z

external vertex : x:float -> y:float -> ?z:float -> ?w:float -> unit
    = "ml_glVertex"
let vertex2 (x,y : point2) = vertex :x :y
and vertex3 (x,y,z : point3) = vertex :x :y :z
and vertex4 (x,y,z,w : point4) = vertex :x :y :z :w

external viewport : x:int -> y:int -> w:int -> h:int -> unit
    = "ml_glViewport"

(* List functions *)

let shift_list : glist -> by:int -> glist = fun l :by -> l+by
external is_list : glist -> bool = "ml_glIsList"
external gen_lists : int -> glist = "ml_glGenLists"
external delete_lists : from:glist -> range:int -> unit = "ml_glDeleteLists"
external new_list :
    glist -> mode:[compile compile_and_execute] -> unit
    = "ml_glNewList"
external end_list : unit -> unit = "ml_glEndList"
external call_list : glist -> unit = "ml_glCallList"
external call_lists : [byte(string) int(int array)] -> unit
    = "ml_glCallLists"
external list_base : glist -> unit = "ml_glListBase"
