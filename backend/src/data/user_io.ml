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
open Prelude


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
			dt [pcdata "Login name:"];
			dd [pcdata user#nick];
			dt [pcdata "Full name:"];
			dd [pcdata user#fullname];
			];

		h2 [pcdata "User timezone:"];
		Timezone.output_full timezone;

		h2 [pcdata "List of stories:"];
		(match stories with
			| []	 -> p [pcdata "(This user has written no stories)"]
			| hd::tl -> ul ~a:[a_class ["list_of_stories"]] (Story_io.output_handle sp hd) (List.map (Story_io.output_handle sp) tl));

		h2 [pcdata "List of comments:"];
		match comments with
			| []	 -> p [pcdata "(This user has written no comments)"]
			| hd::tl -> ul ~a:[a_class ["list_of_comments"]] (Comment_io.output_handle sp hd) (List.map (Comment_io.output_handle sp) tl);
		]


(********************************************************************************)
(**	{1 Input-related function}						*)
(********************************************************************************)

let form_for_incipient ?user (enter_nick, (enter_fullname, (enter_password, (enter_password2, enter_timezone)))) =
	Database.get_timezones () >>= fun timezones ->
	let (nick, fullname, timezone) = match user with
		| Some u -> (Some u#nick, Some u#fullname, Some u#timezone)
		| None	 -> (None, None, None)
	in Lwt.return
		[
		fieldset ~a:[a_id "user_set"]
			[
			legend [pcdata "Information about new user:"];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_nick"] [pcdata "Login name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_nick"] ~input_type:`Text ~name:enter_nick ?value:nick ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_fullname"] [pcdata "Full name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ?value:fullname ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_password"] [pcdata "Password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password"] ~input_type:`Password ~name:enter_password ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_password2"] [pcdata "Confirm password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password2"] ~input_type:`Password ~name:enter_password2 ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_timezone"] [pcdata "Timezone:"];
				Timezone.select ~a:[a_id "enter_timezone"] ~name:enter_timezone ?value:timezone timezones;
				];
			]
		]


let form_for_changed_credentials (enter_old_password, (enter_new_password, enter_new_password2)) =
	Lwt.return
		[
		fieldset ~a:[a_id "user_set"]
			[
			legend [pcdata "Enter current password for verification, and then the new password:"];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_old_password"] [pcdata "Current password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_old_password"] ~input_type:`Password ~name:enter_old_password ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_new_password"] [pcdata "New password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password"] ~input_type:`Password ~name:enter_new_password ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_new_password2"] [pcdata "Confirm new password:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_new_password2"] ~input_type:`Password ~name:enter_new_password2 ();
				];
			]
		]


let form_for_changed_settings ~user (enter_fullname, enter_timezone) =
	Database.get_timezones () >>= fun timezones ->
	Lwt.return
		[
		fieldset ~a:[a_id "user_set"]
			[
			legend [pcdata "Edit account information:"];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_fullname"] [pcdata "Full name:"];
				Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_fullname"] ~input_type:`Text ~name:enter_fullname ~value:user#fullname ();
				];

			div ~a:[a_class ["inl_field"]]
				[
				label ~a:[a_for "enter_timezone"] [pcdata "Timezone:"];
				Timezone.select ~a:[a_id "enter_timezone"] ~name:enter_timezone ~value:user#timezone timezones;
				];
			]
		]

