(********************************************************************************)
(*	User_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Output-related functions}						*)
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


(********************************************************************************)
(**	{1 Input-related functions}						*)
(********************************************************************************)

val form_for_incipient:
	?user:User.incipient_t ->
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< `One of Timezone.handle_t ] Eliom_parameters.param_name))) ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

val form_for_changed_credentials:
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	([< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name) ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

val form_for_changed_settings:
	user:< fullname: string; timezone: Timezone.handle_t; .. > ->
	[< string Eliom_parameters.setoneradio ] Eliom_parameters.param_name *
	[< `One of Timezone.handle_t ] Eliom_parameters.param_name ->
	[> `Fieldset ] XHTML.M.elt list Lwt.t

