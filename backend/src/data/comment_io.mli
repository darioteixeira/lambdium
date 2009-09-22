(********************************************************************************)
(*	Comment_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Output-related function}						*)
(********************************************************************************)

val output_handle:
	Eliom_sessions.server_params ->
	Comment.handle_t ->
	[> `Li ] XHTML.M.elt

val output_full:
	?localiser:(Timestamp.t -> string) ->
	Login.t option ->
	Eliom_sessions.server_params ->
	Comment.full_t ->
	[> `Div ] XHTML.M.elt

val output_fresh:
	?localiser:(Timestamp.t -> string) ->
	Login.t option ->
	Eliom_sessions.server_params ->
	Comment.fresh_t ->
	[> `Div ] XHTML.M.elt


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

val form_for_fresh:
	sid:Story.Id.t ->
	title:string ->
	body_src: string ->
	[< Story.Id.t Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name) ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

