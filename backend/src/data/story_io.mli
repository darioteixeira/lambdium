(********************************************************************************)
(*	Story_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Invalid_intro of Document.output_t
exception Invalid_body of Document.output_t
exception Invalid_intro_and_body of Document.output_t * Document.output_t


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

val parse: string -> string -> (Document.composition_t * Document.output_t * Document.manuscript_t * Document.output_t * string list) Lwt.t

val form_for_fresh:
	?title:string ->
	?intro_src:string ->
	?body_src:string ->
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name) ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

val form_for_images:
	aliases:string list ->
	[< Ocsigen_extensions.file_info Eliom_parameters.setoneradio ] Eliom_parameters.param_name ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

