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
open Prelude
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?nick ?fullname ?timezone sp () () =
	let output_core maybe_login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_user
			~post_params: Params.add_user
			step2_handler in
		Forms.Monatomic.make_form
			~label: "Add user"
			~service: step2_service
			~sp
			~content: (User_io.form_for_fresh ?nick ?fullname ?timezone)
			() >>= fun form ->
		Lwt.return [form]
	in Page.login_agnostic_handler
		~sp
		~page_title: "Add User - Step 1/2"
		~output_core
		()


and step2_handler sp () (nick, (fullname, (password, (password2, timezone)))) =
	if password <> password2
	then begin
		Status.failure ~sp [pcdata "Passwords do not match!"] [];
		step1_handler ~nick ~fullname ~timezone sp () ()
	end
	else
		try_lwt
			let user = User.make_fresh nick fullname password timezone in
			Database.add_user user >>= fun _ ->
			Status.success ~sp [pcdata "User has been added"] [];
			Page.login_agnostic_handler ~sp ~page_title: "Add User - Step 2/2" ()
		with
			| Database.Cannot_add_user ->
				Status.failure ~sp [pcdata "Cannot add user!"] [];
				Page.login_agnostic_handler ~sp ~page_title: "Add User - Step 2/2" ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler = step1_handler

