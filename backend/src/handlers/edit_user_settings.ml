(********************************************************************************)
(*	Edit_user_settings.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.	
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Eliom_parameters
open Litiom_wizard
open Common


(********************************************************************************)
(**	{2 Step 2 of the wizard}						*)
(********************************************************************************)

let step2 =
	let carrier ~carry_in:user sp () (fullname, timezone) =
		let settings = User.make_changed_settings user#uid fullname timezone
		in Database.edit_user_settings settings >>= fun () ->
		Lwt.return (`Proceed ()) in
	let normal_content ~carry_in ~carry_out sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 2")) [])
			(body [p [pcdata "User settings have been changed"]]))
	in Steps.make_last
		~fallback: Visible.edit_user_settings
		~carrier
		~normal_content
		~post_params: (Eliom_parameters.string "fullname" ** Timezone.param "timezone")
		()


(********************************************************************************)
(**	{2 Step 1 of the wizard.}						*)
(********************************************************************************)

let step1_handler =
	let carrier ~carry_in sp () () =
		Session.get_login sp >>= fun login ->
		Database.get_user (Login.uid login) >>= fun user ->
		Lwt.return (`Proceed user) in
	let form_maker ~carry_in ~carry_out:user (enter_fullname, enter_timezone) =
		let right_tz tz = user#timezone#tid = tz#tid in
		let option_of_tz tz = Eliom_predefmod.Xhtml.Option ([], Timezone.make_handle tz#tid, Some (Timezone_output.describe tz), right_tz tz) in
		Database.get_timezones () >>= fun timezones ->
		Lwt.return
			[
			fieldset ~a:[a_class ["form_fields"]]
				[
				legend [pcdata "Edit account information:"];
				label ~a:[a_class ["input_label"]; a_for "enter_fullname"] [pcdata "Enter full name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ~value:user#fullname ();
				label ~a:[a_class ["input_label"]; a_for "enter_timezone"] [pcdata "Choose timezone:"];
				Eliom_predefmod.Xhtml.user_type_select
					~name:enter_timezone
					(Eliom_predefmod.Xhtml.Option ([], Timezone.make_handle Timezone.utc#tid, Some (Timezone_output.describe Timezone.utc), right_tz Timezone.utc))
					(List.map option_of_tz timezones)
					Timezone.to_string
				]
			] in
	let normal_content ~carry_in ~carry_out ~form sp () () =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 1")) [])
			(body [form]))
	in Steps.make_first_handler
		~carrier
		~form_maker
		~normal_content
		~next: step2
		()

