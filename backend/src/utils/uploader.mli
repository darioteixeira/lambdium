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


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val request: sp:Eliom_sessions.server_params -> login:Login.t -> t
val retire: t -> unit
val refresh: t -> unit

