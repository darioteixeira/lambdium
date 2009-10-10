(********************************************************************************)
(*	Uploader.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type t
type status_t = (string * bool) list


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val init: unit -> unit
val request: sp:Eliom_sessions.server_params -> login:Login.t -> t
val refresh: t -> unit
val discard: t -> unit Lwt.t
val commit: string -> t -> unit Lwt.t

val add_files: t -> string list -> Ocsigen_extensions.file_info list -> bool
val get_status: t -> string list -> status_t

