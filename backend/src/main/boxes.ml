(********************************************************************************)
(*	Boxes implementation.
	Copyright (c) 2007-2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.	
*)
(********************************************************************************)

open XHTML.M
open Common


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let output_floatbox id header contents =
	div ~a:[a_id id; a_class ["floatbox"]]
		[
		h1 ~a:[a_class ["floatbox_header"]] [pcdata header];
		div ~a:[a_class ["floatbox_body"]] contents
		]


let login_form (username, (password, remember)) =
	[
	fieldset
		[
		label ~a:[a_for "enter_username"] [pcdata "Username:"];
		Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_username"] ~input_type:`Text ~name:username ();
		label ~a:[a_for "enter_password"] [pcdata "Password:"];
		Eliom_predefmod.Xhtml.string_input ~a:[a_id "enter_password"] ~input_type:`Password ~name:password ();
		label ~a:[a_for "enter_remember"] [pcdata "Remember me?"];
		Eliom_predefmod.Xhtml.bool_checkbox ~a:[a_id "enter_remember"] ~name:remember ();
		Eliom_predefmod.Xhtml.string_input ~input_type:`Submit ~value:"Login" ()
		]
	]


let logout_form enter_global =
	[
	fieldset
		[
		Eliom_predefmod.Xhtml.string_input ~input_type:`Submit ~value:"Logout" ();
		label ~a:[a_for "enter_global"] [pcdata "Global logout?"];
		Eliom_predefmod.Xhtml.bool_checkbox ~a:[a_id "enter_global"] ~name:enter_global ()
		]
	]


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

(**	Outputs the credits box.
*)
let output_credits _ _ =
	let contents = [p [pcdata "Welcome to the Lambdium-light CMS system!"]]
	in Lwt.return (output_floatbox "credits_box" "About" contents)


(**	Outputs the main menu.
*)
let output_main_menu _ sp =
	let contents =
		[
		ul ~a:[a_class ["menu"]]
			(li [Eliom_predefmod.Xhtml.a !!Visible.view_stories sp [pcdata "View all stories"] ()])
			[
			li [Eliom_predefmod.Xhtml.a !!Visible.view_users sp [pcdata "View all users"] ()];
			li [Eliom_predefmod.Xhtml.a !!Visible.add_story sp [pcdata "Submit new story"] ()];
			li [Eliom_predefmod.Xhtml.a !!Visible.add_user sp [pcdata "Create new account"] ()]
			]
		]
	in Lwt.return (output_floatbox "main_menu" "Main Menu" contents)


(**	Outputs the user menu.
*)
let output_user_menu maybe_login sp =
	let session_fragment =
		let personal_fragment login =
			[
			p ~a:[a_class ["success_msg"]] [pcdata ("Hello " ^ (Login.nick login) ^ "!")];
			ul	(li [Eliom_predefmod.Xhtml.a !!Visible.edit_user_settings sp [pcdata "Account settings"] ()])
				[li [Eliom_predefmod.Xhtml.a !!Visible.edit_user_credentials sp [pcdata "Change password"] ()]];
			Eliom_predefmod.Xhtml.post_form !!Actions.logout sp logout_form ()
			]
		and public_fragment () =
			[
			Eliom_predefmod.Xhtml.post_form !!Actions.login sp login_form ();
			]
		in match maybe_login with
			| Some login	-> personal_fragment login
			| None		-> public_fragment ()
	and error_fragment =
		let exnlist = Eliom_sessions.get_exn sp in
		if List.mem Session.Invalid_login exnlist
		then [p ~a:[a_class ["error_msg"]] [pcdata "Invalid login!"]]
		else []
	and varying_fragment =
		let personal_fragment user = []
		and public_fragment () = []
		in match maybe_login with
			| Some login	-> personal_fragment login
			| None		-> public_fragment () in
	let contents = session_fragment @ error_fragment @ varying_fragment
	in Lwt.return (output_floatbox "user_menu" "User Menu" contents)


(**	Outputs a standard page header.
*)
let output_header _ _ =
	Lwt.return (div ~a:[a_id "header"] [h1 [pcdata "Lambdium-light CMS"]])


(**	Outputs a standard page footer.
*)
let output_footer _ sp =
	Lwt.return
		(div ~a:[a_id "footer"]
			[
			h1	[pcdata "Powered by:"];
			ul	(li [Eliom_predefmod.Xhtml.a !!External.lambdium_light sp [External.lambdium_light_img sp] ()])
				[
				li [Eliom_predefmod.Xhtml.a !!External.ocsigen sp [External.ocsigen_img sp] ()];
				li [Eliom_predefmod.Xhtml.a !!External.ocaml sp [External.ocaml_img sp] ()];
				]
			])

