(********************************************************************************)
(*	User_output.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

val output_full:
	Eliom_sessions.server_params ->
	User.full_t ->
	Timezone.full_t ->
	Story.handle_t list ->
	Comment.handle_t list ->
	[> `Div ] XHTML.M.elt

val output_handle:
	Eliom_sessions.server_params ->
	User.handle_t ->
	[> `Li ] XHTML.M.elt

