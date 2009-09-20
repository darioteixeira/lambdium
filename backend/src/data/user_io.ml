(********************************************************************************)
(*	User_io.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Eliom_parameters
open Common


(********************************************************************************)
(**	{1 Output-related function}						*)
(********************************************************************************)

let output_handle sp user =
	li ~a:[a_class ["user_handle"]]
		[
		Eliom_predefmod.Xhtml.a !!Services.show_user sp [pcdata user#nick] user#uid
		]


let output_full sp user timezone stories comments =
	div ~a:[a_class ["user"]]
		[
		h1 [pcdata "User information:"];

		dl ~a:[a_class ["user_info"]]
			(dt [pcdata "ID:"])
			[
			dd [pcdata (User.Id.to_string user#uid)];
			dt [pcdata "Login name:"]; dd [pcdata user#nick];
			dt [pcdata "Full name:"]; dd [pcdata user#fullname]
			];

		h1 [pcdata "User timezone:"];

		Timezone_io.output_full timezone;

		h1 [pcdata "List of stories:"];
		(match stories with
			| []	 -> p [pcdata "(This user has written no stories)"]
			| hd::tl -> ul ~a:[a_class ["list_of_stories"]]
					(Story_io.output_handle sp hd)
					(List.map (Story_io.output_handle sp) tl));

		h1 [pcdata "List of comments:"];
		match comments with
			| []	 -> p [pcdata "(This user has written no comments)"]
			| hd::tl -> ul ~a:[a_class ["list_of_comments"]]
					(Comment_io.output_handle sp hd)
					(List.map (Comment_io.output_handle sp) tl);
		]


(********************************************************************************)
(**	{1 Input-related function}						*)
(********************************************************************************)

let option_of_tz default tz =
	let correct_tz tz = match default with
		| Some x -> tz#tid = x#tid
		| None	 -> tz#tid = Timezone.utc#tid
	in Eliom_predefmod.Xhtml.Option ([], Timezone.make_handle tz#tid, Some (Timezone_io.describe tz), correct_tz tz)


let form_for_fresh ?nick ?fullname ?timezone (enter_nick, (enter_fullname, (enter_password, (enter_password2, enter_timezone)))) =
	Database.get_timezones () >>= fun timezones ->
	Lwt.return
		[fieldset
			[
			legend [pcdata "Information about new user:"];

			label ~a:[a_class ["input_label"]; a_for "enter_nick"] [pcdata "Enter login name:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_nick"] ~input_type:`Text ~name:enter_nick ?value:nick ();
			label ~a:[a_class ["input_label"]; a_for "enter_fullname"] [pcdata "Enter full name:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ?value:fullname ();
			label ~a:[a_class ["input_label"]; a_for "enter_password"] [pcdata "Enter password:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password"] ~input_type:`Password ~name:enter_password ();
			label ~a:[a_class ["input_label"]; a_for "enter_password2"] [pcdata "Confirm password:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password2"] ~input_type:`Password ~name:enter_password2 ();
			label ~a:[a_class ["input_label"]; a_for "enter_timezone"] [pcdata "Choose timezone:"];
			Eliom_predefmod.Xhtml.user_type_select
				~a:[a_id "enter_timezone"]
				~name:enter_timezone
				(option_of_tz timezone Timezone.utc)
				(List.map (option_of_tz timezone) timezones)
				Timezone.to_string
			]]


let form_for_changed_credentials (enter_old_password, (enter_new_password, enter_new_password2)) =
	Lwt.return
		[fieldset
			[
			legend [pcdata "Enter current password for verification, and then the new password:"];

			label ~a:[a_class ["input_label"]; a_for "enter_old_password"] [pcdata "Enter current password:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_old_password"] ~input_type:`Password ~name:enter_old_password ();
			label ~a:[a_class ["input_label"]; a_for "enter_new_password"] [pcdata "Enter new password:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password"] ~input_type:`Password ~name:enter_new_password ();
			label ~a:[a_class ["input_label"]; a_for "enter_new_password2"] [pcdata "Confirm new password:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password2"] ~input_type:`Password ~name:enter_new_password2 ();
			]]


let form_for_changed_settings ~user (enter_fullname, enter_timezone) =
	Database.get_timezones () >>= fun timezones ->
	Lwt.return
		[fieldset
			[
			legend [pcdata "Edit account information:"];

			label ~a:[a_class ["input_label"]; a_for "enter_fullname"] [pcdata "Enter full name:"];
			Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ~value:user#fullname ();
			label ~a:[a_class ["input_label"]; a_for "enter_timezone"] [pcdata "Choose timezone:"];
			Eliom_predefmod.Xhtml.user_type_select
				~a:[a_id "enter_timezone"]
				~name:enter_timezone
				(option_of_tz (Some user#timezone) Timezone.utc)
				(List.map (option_of_tz (Some user#timezone)) timezones)
				Timezone.to_string
			]]

