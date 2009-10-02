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
open Common
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?user ~status sp () () =
	let output_core login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.edit_user_settings
			~post_params: Params.edit_user_settings
			(step2_handler ~login) in
		(match user with
			| Some u -> Lwt.return u
			| None   -> Database.get_user (Login.uid login)) >>= fun user ->
		Forms.Monatomic.make_form
			~label: "Change settings"
			~service: step2_service
			~sp
			~content: (User_io.form_for_changed_settings ~user)
			() >>= fun form ->
		Lwt.return (status, Some [form])
	in Page.login_enforced_handler
		~sp
		~page_title: "Edit settings - Step 1/2"
		~output_core
		()


and step2_handler ~login sp () (fullname, timezone) =
	try_lwt
		let status = Stat_success [p [pcdata "User settings have been changed"]] in
		let output_core login sp = Lwt.return (status, None) in
		let settings = User.make_changed_settings (Login.uid login) fullname timezone in
		Database.edit_user_settings settings >>= fun () ->
		Session.update_login sp login >>= fun () ->
		Page.login_enforced_handler ~sp ~page_title:"Edit settings - Step 2/2" ~output_core ()
	with
		| Database.Cannot_edit_user_settings ->
			let status = Stat_failure [p [pcdata "Error!"]]
			in step1_handler ~status sp () ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	step1_handler ~status:Stat_nothing sp () ()

