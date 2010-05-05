(********************************************************************************)
(*	Page.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Prelude


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output_box (maybe_id, classes, head, body) =
	let id' = match maybe_id with
		| Some id -> [a_id id]
		| None	  -> []
	and head' = match head with
		| [] -> []
		| xs -> [h1 ~a:[a_class ["box_head"]] xs]
	and body' = match body with
		| [] -> []
		| xs -> [div ~a:[a_class ["box_body"]] xs]
	in div ~a:(a_class ("box" :: classes) :: id') (head' @ body')


let output_floatbox (id, head, body) =
	output_box (Some id, [], head, body)


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


let output_credits _ sp =
	let body =
		[
		p [pcdata "The Lambdium forum is powered by:"];
		ul (li [Eliom_predefmod.Xhtml.a External.lambdium sp [External.lambdium_img sp] ()])
			[
			li [Eliom_predefmod.Xhtml.a External.ocsigen sp [External.ocsigen_img sp] ()];
			li [Eliom_predefmod.Xhtml.a External.ocaml sp [External.ocaml_img sp] ()];
			]
		]
	in Lwt.return ("credits", [pcdata "About"], body)


let output_main_menu _ sp =
	let item svc txt =
		li ~a:[a_class ["menu_item"]] [Eliom_predefmod.Xhtml.a svc sp [pcdata txt] ()] in
	let body =
		[
		ul ~a:[a_class ["menu"]]
			(item !!Services.view_stories "View all stories")
			[
			item !!Services.view_users "View all users";
			item !!Services.add_story "Submit new story";
			item !!Services.add_user "Create new account";
			]
		]
	in Lwt.return ("main_menu", [pcdata "Main Menu"], body)


let output_user_menu maybe_login sp =
	let session_fragment =
		let personal_fragment login =
			[
			p ~a:[a_class ["success_msg"]] [pcdata ("Hello " ^ (Login.nick login) ^ "!")];
			ul	(li [Eliom_predefmod.Xhtml.a !!Services.edit_user_settings sp [pcdata "Account settings"] ()])
				[li [Eliom_predefmod.Xhtml.a !!Services.edit_user_credentials sp [pcdata "Change password"] ()]];
			Eliom_predefmod.Xhtml.post_form !!Services.logout sp logout_form ()
			]
		and public_fragment () =
			[
			Eliom_predefmod.Xhtml.post_form !!Services.login sp login_form ();
			]
		in match maybe_login with
			| Some login	-> personal_fragment login
			| None		-> public_fragment ()
	in Lwt.return ("user_menu", [pcdata "User Menu"], session_fragment)


let output_header _ _ =
	Lwt.return [h1 [pcdata "Lambdium"]]


let output_footer _ sp =
	Lwt.return [h1 [pcdata "Footer"]]


let base_page ~sp ~page_title ~page_content ~page_content_id =
	let css_uri = Eliom_predefmod.Xhtml.make_uri ~service:(External.static ["css"; "main.css"]) ~sp ()
	and js_uri = Eliom_predefmod.Xhtml.make_uri ~service:(External.static ["scripts"; "main.js"]) ~sp ()
	in (html
		(head ~a:[a_profile (uri_of_string "http://www.w3.org/2005/11/profile")] (title (pcdata page_title))
			[
			meta ~a:[a_http_equiv "content-type"] ~content:"text/html; charset=utf-8" ();
			meta ~a:[a_name "keywords"] ~content:"lambdium, ocsigen, eliom, ocaml" ();
			Eliom_predefmod.Xhtml.css_link ~a:[(a_media [`All]); (a_title "Default")] ~uri:css_uri ();
			Eliom_predefmod.Xhtml.js_script ~a:[] ~uri:js_uri ();
			])
		(body [div ~a:[a_id page_content_id] page_content]))


let regular_page ~sp ~page_title ~header ~core_body ~nav ~context ~footer =
	let output_status (stat, head, body) = output_box (None, ["status_" ^ (Status.string_of_stat stat)], head, body) in
	let status = match Status.get sp with
		| [] -> []
		| xs -> List.map output_status xs
	and core = match core_body with
		| [] ->
			[]
		| xs ->
			[
			h1 ~a:[a_id "core_head"] [pcdata page_title];
			div ~a:[a_id "core_body"] core_body;
			] in
	let page_content =
		[
		div ~a:[a_id "header"] header;
		div ~a:[a_id "core"] (status @ core);
		div ~a:[a_id "nav"] (List.map output_floatbox nav);
		div ~a:[a_id "context"] (List.map output_floatbox context);
		div ~a:[a_id "footer"] footer;
		]
	in base_page ~sp ~page_title ~page_content ~page_content_id:"root"


let failure_page ~sp ~page_title ~msg =
	let page_content = [p [pcdata msg]]
	in base_page ~sp ~page_title ~page_content ~page_content_id:"failure"


let regular_handler ~maybe_login ~sp ~page_title ?(output_core = fun _ -> Lwt.return []) ?(output_context = fun _ _ -> Lwt.return []) () =
	let header_thread = output_header maybe_login sp
	and footer_thread = output_footer maybe_login sp
	and credits_thread = output_credits maybe_login sp
	and main_menu_thread = output_main_menu maybe_login sp
	and user_menu_thread = output_user_menu maybe_login sp
	and core_thread = output_core sp
	and context_thread = output_context maybe_login sp in
	header_thread >>= fun header ->
	footer_thread >>= fun footer ->
	credits_thread >>= fun credits ->
	main_menu_thread >>= fun main_menu ->
	user_menu_thread >>= fun user_menu ->
	core_thread >>= fun core_body ->
	context_thread >>= fun custom_context ->
	let nav = [main_menu; user_menu]
	and context = [credits] @ custom_context
	in Lwt.return (regular_page ~sp ~page_title ~header ~core_body ~nav ~context ~footer)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Handlers}								*)
(********************************************************************************)

let login_agnostic_handler ~sp ~page_title ?output_core ?output_context () =
	Session.get_maybe_login sp >>= fun maybe_login ->
	let output_core = match output_core with
		| Some f -> Some (f maybe_login)
		| None	 -> None
	in regular_handler ~maybe_login ~sp ~page_title ?output_core ?output_context ()


let login_enforced_handler ~sp ~page_title ?output_core ?output_context () =
	Session.get_maybe_login sp >>= fun maybe_login ->
	let output_core = match maybe_login with
		| Some login -> (match output_core with Some f -> Some (f login) | None -> None)
		| None	     -> (Status.failure ~sp [pcdata "You are not logged in!"] []; None)
	in regular_handler ~maybe_login ~sp ~page_title ?output_core ?output_context ()


let fallback_handler ~sp ~page_title =
	let msg = "Some POST parameters would be nice..."
	in Lwt.return (failure_page ~sp ~page_title ~msg)


let exception_handler sp exc =
	let (msg, code) = match exc with
		| Eliom_common.Eliom_404 ->
			("Page not found!", Some 404)
		| End_of_file ->
			("Problem with database connection", Some 500)
		| exc ->
			("Internal server error: " ^ (Printexc.to_string exc), Some 500)
	in Eliom_predefmod.Xhtml.send ?code ~sp (failure_page ~sp ~page_title:"Exception" ~msg)

