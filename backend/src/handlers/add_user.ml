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


(********************************************************************************)
(**	{1 Wizard steps}							*)
(********************************************************************************)

let rec step1_handler ?user ?(errors = []) sp () () =
	let output_core maybe_login sp =
		let step2_service = Eliom_predefmod.Xhtml.register_new_post_coservice_for_session
			~sp
			~fallback: !!Services.add_user
			~post_params: Params.add_user
			step2_handler in
		Forms.Monatomic.make_form
			~service: step2_service
			~sp
			~content: (User_io.form_for_fresh ?user)
			~label: "Add user" >>= fun form ->
		Lwt.return (errors @ [form])
	in Page.login_agnostic_handler
		~sp
		~page_title: "Add User - Step 1/2"
		~output_core
		()


and step2_handler sp () (nick, (fullname, (password, (password2, timezone)))) =
	if password <> password2
	then
		step1_handler ~errors:[p [pcdata "Passwords do not match!"]] sp () ()
	else
		Lwt.catch
			(fun () ->
				let user = User.make_fresh nick fullname password timezone in
				Database.add_user user >>= fun () ->
				Page.login_agnostic_handler
					~sp
					~page_title: "Add User - Step 2/2"
					~output_core: (fun _ _ -> Lwt.return [p [pcdata "User has been added"]])
					())
			(function 
				| Database.Cannot_add_user -> step1_handler ~errors:[p [pcdata "Cannot add user!"]] sp () ()
				| exc -> Lwt.fail exc)

