(********************************************************************************)
(*	Preview_comment.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Offers a comment preview service.  Note that this module is typically only
	accessed via an XmlHttpRequest, and is therefore invisible to users.  Also,
	the reply is not an XHTML page, but instead a JSON object containing two
	fields: the first indicating whether the story can be successfully previewed,
	and the second containing the XHTML fragment to be displayed.
*)

open Lwt
open XHTML.M
open Eliom_parameters
open Document


(********************************************************************************)
(**	{1 Public service}							*)
(********************************************************************************)

let make_reply ~success fragment_xhtml =
	let fragment_str = Xhtmlpretty.xhtml_list_print [fragment_xhtml] in
	let json_obj =
		Json_type.Object
			[
			("success", Json_type.Bool success);
			("content", Json_type.String fragment_str)
			] in
	(Json_io.string_of_json json_obj, "application/json")


let handler sp () (sid, (title, body_src)) =
	try_lwt
		Session.get_login sp >>= fun login ->
		Document.parse_composition_exc ~markup:Markup.Lambtex body_src >>= fun (body_doc, _) ->
		let body_out = Document.output_of_composition ~sp ~path:[] body_doc in
		let author = Login.to_user login in
		let comment = Comment.make_fresh sid author title Markup.Lambtex body_src body_doc body_out in
		let comment_xhtml = Comment_io.output_fresh (Some login) sp comment
		in Lwt.return (make_reply ~success:true comment_xhtml)
	with
		| Session.No_login -> Lwt.return (make_reply ~success:false (pcdata "Not logged in!"))


(********************************************************************************)
(**	{1 Fallback}								*)
(********************************************************************************)

let fallback_handler sp () () =
	Page.fallback_handler ~sp ~page_title: "Preview Comment"

