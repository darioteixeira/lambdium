(********************************************************************************)
(*	Comment_output.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M
open Common


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let output_metadata maybe_login sp comment =
	div ~a:[a_class ("comment_meta" :: (Login.own_element comment#author maybe_login))]
		[
		h1 ~a:[a_class ["comment_author"]] [Eliom_predefmod.Xhtml.a !!Visible.show_user sp [pcdata comment#author#nick] comment#author#uid];
		h1 ~a:[a_class ["comment_title"]] [pcdata comment#title];
		h1 ~a:[a_class ["comment_timestamp"]] [pcdata comment#timestamp];
		]


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let output_handle sp comment =
	li ~a:[a_class ["comment_handle"]]
		[
		Eliom_predefmod.Xhtml.a !!Visible.show_comment sp [pcdata comment#title] comment#cid
		]


let output_full maybe_login sp comment =
	div ~a:[a_class ["comment_full"]]
		[
		output_metadata maybe_login sp comment;
		comment#body_out
		]


let output_fresh sp comment =
	div ~a:[a_class ["comment_full"; "comment_preview"]]
		[
		output_metadata None sp comment;
		comment#body_out
		]

