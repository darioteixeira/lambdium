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

exception Token_unavailable


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type cleaner_t = unit -> unit

type token_t

type pool_t


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val make_pool: string -> int -> float -> pool_t
val get_token: pool_t -> cleaner_t -> token_t
val put_token: pool_t -> token_t -> unit
val refresh_token: pool_t -> token_t -> unit

