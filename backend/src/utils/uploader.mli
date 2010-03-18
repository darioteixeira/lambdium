(********************************************************************************)
(*	Uploader.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception User_pool_exhausted
exception Global_pool_exhausted
exception Invalid_token


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type token_t
type status_t = (string * bool) list


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val init: unit -> unit
val request: sp:Eliom_sessions.server_params -> uid:User.Id.t -> limit:int -> token_t Lwt.t
val discard: token_t -> unit Lwt.t
val commit: path:string list -> token_t -> unit Lwt.t

val add_files: string list -> Ocsigen_lib.file_info list -> token_t -> bool Lwt.t
val get_status: string list -> token_t -> status_t
val get_path: token_t -> string list

