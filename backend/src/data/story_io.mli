(********************************************************************************)
(*	Story_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Prelude


(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

val output_handle:
	Eliom_sessions.server_params ->
	Story.handle_t ->
	[> `Li ] XHTML.M.elt

val output_blurb:
	?localiser:(Timestamp.t -> string) ->
	Login.t option ->
	Eliom_sessions.server_params ->
	Story.blurb_t ->
	[> `Li ] XHTML.M.elt

val output_full:
	?localiser:(Timestamp.t -> string) ->
	Login.t option ->
	Eliom_sessions.server_params ->
	Story.full_t ->
	Comment.full_t list ->
	[> `Div ] XHTML.M.elt

val output_fresh:
	?localiser:(Timestamp.t -> string) ->
	Login.t ->
	Eliom_sessions.server_params ->
	Story.fresh_t ->
	[> `Div ] XHTML.M.elt


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

val form_for_fresh:
	?title:string ->
	?intro_src:string ->
	?body_src:string ->
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name) ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

val form_for_images:
	sp:Eliom_sessions.server_params ->
	path:string list ->
	status:Uploader.status_t ->
	[< Ocsigen_lib.file_info Eliom_parameters.setoneradio ] Eliom_parameters.param_name ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

