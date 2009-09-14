(********************************************************************************)
(*	Story_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

val output_handle:
	Eliom_sessions.server_params ->
	Story.handle_t ->
	[> `Li ] XHTML.M.elt

val output_blurb:
	Login.t option ->
	Eliom_sessions.server_params ->
	Story.blurb_t ->
	[> `Li ] XHTML.M.elt

val output_full:
	Login.t option ->
	Eliom_sessions.server_params ->
	Story.full_t ->
	Comment.full_t list ->
	[> `Div ] XHTML.M.elt

val output_fresh:
	Login.t ->
	Eliom_sessions.server_params ->
	Story.fresh_t ->
	[> `Div ] XHTML.M.elt


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

val form_for_fresh:
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name) ->
	[> `Fieldset ] XHTML.M.elt Lwt.t

