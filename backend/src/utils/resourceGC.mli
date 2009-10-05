(********************************************************************************)
(*	ResourceGC.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Global_pool_exhausted
exception Group_pool_exhausted


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type pool_t
type token_t
type cleaner_t = string -> unit


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val make_pool: name:string -> capacity:int -> period:int -> default_timeout:float option -> pool_t
val request_token: ?group:(string * int) -> ?timeout:float option -> pool_t -> cleaner_t -> token_t
val refresh_token: token_t -> unit
val retire_token: token_t -> unit
val uuid_of_token: token_t -> string
