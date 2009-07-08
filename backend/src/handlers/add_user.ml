(********************************************************************************)
(*	Add_user.ml
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
(**	{2 Exceptions}								*)
(********************************************************************************)

exception Passwords_mismatch


(********************************************************************************)
(**	{2 Step 2 of the wizard}						*)
(********************************************************************************)

let step2 =
	let carrier ~carry_in sp () (nick, (fullname, (password, (password2, timezone)))) =
		if password <> password2
		then Lwt.fail Passwords_mismatch
		else begin
			let user = User.make_fresh nick fullname password timezone in
			Database.add_user user >>= fun () ->
			Lwt.return (`Proceed ())
		end in
	let normal_content ~carry_in ~carry_out sp _ _ =
		Lwt.return
			(html
			(head (title (pcdata "Wizard step 2")) [])
			(body [p [pcdata "User has been added"]]))
	in Steps.make_last
		~fallback: Visible.add_user
		~carrier
		~normal_content
		~post_params: 
			(Eliom_parameters.string "nick" **
			 Eliom_parameters.string "fullname" **
			 Eliom_parameters.string "password" **
			 Eliom_parameters.string "password2" **
			 Timezone.param "timezone")
		()


(********************************************************************************)
(**	{2 Step 1 of the wizard}						*)
(********************************************************************************)

let step1_handler =
	let form_maker ~carry_in ~carry_out (enter_nick, (enter_fullname, (enter_password, (enter_password2, enter_timezone)))) =
		let option_of_tz tz = Eliom_predefmod.Xhtml.Option ([], Timezone.make_handle tz#tid, Some (Timezone_output.describe tz), false) in
		Database.get_timezones () >>= fun timezones ->
		Lwt.return
			[
			fieldset ~a:[a_class ["form_fields"]]
				[
				legend [pcdata "Information about new user:"];
				label ~a:[a_class ["input_label"]; a_for "enter_nick"] [pcdata "Enter login name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_nick"] ~input_type:`Text ~name:enter_nick ();
				label ~a:[a_class ["input_label"]; a_for "enter_fullname"] [pcdata "Enter full name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ();
				label ~a:[a_class ["input_label"]; a_for "enter_password"] [pcdata "Enter password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password"] ~input_type:`Password ~name:enter_password ();
				label ~a:[a_class ["input_label"]; a_for "enter_password2"] [pcdata "Confirm password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password2"] ~input_type:`Password ~name:enter_password2 ();
				label ~a:[a_class ["input_label"]; a_for "enter_timezone"] [pcdata "Choose timezone:"];
				Eliom_predefmod.Xhtml.user_type_select
					~a:[a_id "enter_timezone"]
					~name:enter_timezone
					(Eliom_predefmod.Xhtml.Option ([], Timezone.make_handle Timezone.utc#tid, Some (Timezone_output.describe Timezone.utc), true))
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
		~carrier: Carriers.none
		~form_maker
		~normal_content
		~next: step2
		()

