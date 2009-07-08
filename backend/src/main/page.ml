(********************************************************************************)
(**	Outputs a standard page.

	Copyright (c) 2007-2008 Dario Teixeira (dario.teixeira@yahoo.com)

	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let page_template ~sp ~page_title ~header ~footer ~credits ~main_menu ~user_menu ~canvas =
	let css_uri = Eliom_predefmod.Xhtml.make_uri (Eliom_services.static_dir sp) sp ["css"; "default"; "main.css"]
	and js_uri = Eliom_predefmod.Xhtml.make_uri (Eliom_services.static_dir sp) sp ["scripts"; "lambdium.js"]
	in (html
		(head	~a: [a_profile (uri_of_string "http://www.w3.org/2005/11/profile")]
			(title (pcdata page_title))
			[
			meta ~a: [a_http_equiv "content-type"] ~content: "text/html; charset=utf-8" ();
			meta ~a: [a_name "keywords"] ~content: "lambdium, ocsigen, eliom, forum, ocaml" ();
			Eliom_predefmod.Xhtml.css_link ~a:[(a_media [`All]); (a_title "Default")] ~uri:css_uri ();
			Eliom_predefmod.Xhtml.js_script ~a:[] ~uri:js_uri ();
			])
		(body [div ~a:[a_class ["root"]]
			[
			header;
			canvas;
			div ~a:[a_class ["mainnav"]]
				[
				credits;
				main_menu;
				user_menu;
				];
			footer;
			]]))


let handler_template ~sp ~page_title ~canvas_maker =
	Session.get_maybe_login sp >>= fun maybe_login ->
	let header_thread = Boxes.output_header maybe_login sp
	and footer_thread = Boxes.output_footer maybe_login sp
	and credits_thread = Boxes.output_credits maybe_login sp
	and main_menu_thread = Boxes.output_main_menu maybe_login sp
	and user_menu_thread = Boxes.output_user_menu maybe_login sp
	and canvas_thread = canvas_maker maybe_login sp in
	header_thread >>= fun header ->
	footer_thread >>= fun footer ->
	credits_thread >>= fun credits ->
	main_menu_thread >>= fun main_menu ->
	user_menu_thread >>= fun user_menu ->
	canvas_thread >>= fun canvas ->
	Lwt.return (page_template ~sp ~page_title ~header ~footer ~credits ~main_menu ~user_menu ~canvas)


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

(**	Creates a standard handler.
*)
let standard_handler ~sp ~page_title ~canvas_maker =
	handler_template ~sp ~page_title ~canvas_maker


(**	Creates a special handler that enforces that the user must be logged in.
*)
(*
let enforce_logged_handler ~sp ~page_title ~canvas_maker =
	let canvas_tree = enforcer nop (sink canvas, sink Canvas.output_identity_failure)
	in handler_template sp page_title canvas_tree
*)

