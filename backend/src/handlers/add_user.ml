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
open Common
open Page


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?nick ?fullname ?timezone ~status sp () () =
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
		Lwt.return (status, Some [form])
	in Page.login_agnostic_handler
		~sp
		~page_title: "Add User - Step 1/2"
		~output_core
		()


and step2_handler sp () (nick, (fullname, (password, (password2, timezone)))) =
	if password <> password2
	then
		let status = Stat_failure [p [pcdata "Passwords do not match!"]]
		in step1_handler ~nick ~fullname ~timezone ~status sp () ()
	else
		try_lwt
			let user = User.make_fresh nick fullname password timezone in
			Database.add_user user >>= fun () ->
			let output_core _ _ = Lwt.return (Stat_success [p [pcdata "User has been added"]], None)
			in Page.login_agnostic_handler ~sp ~page_title: "Add User - Step 2/2" ~output_core ()
		with
			| Database.Cannot_add_user ->
				let output_core _ _ = Lwt.return (Stat_failure [p [pcdata "Cannot add user!"]], None)
				in Page.login_agnostic_handler ~sp ~page_title: "Add User - Step 2/2" ~output_core ()


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp () () =
	step1_handler ~status:Stat_nothing sp () ()

