(********************************************************************************)
(*	Comment.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open Document


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Id = Id.Id32

type handle_t =
	< cid: Id.t;
	title: string >

type full_t =
	< cid: Id.t;
	sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	body_out: output_t >

type fresh_t =
	< sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	body_mrk: Markup.t;
	body_src: source_t;
	body_doc: composition_t;
	body_out: output_t >

type incipient_t =
	< title: string;
	body_mrk: Markup.t;
	body_src: source_t >


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let make_handle cid title =
	object
		method cid = cid
		method title = title
	end


let make_full cid sid author title timestamp body_out =
	object
		method cid = cid
		method sid = sid
		method author = author
		method title = title
		method timestamp = timestamp
		method body_out = body_out
	end


let make_fresh sid author title body_mrk body_src body_doc body_out =
	object
		method sid = sid
		method author = author
		method title = title
		method timestamp = Timestamp.soon ()
		method body_mrk = body_mrk
		method body_src = body_src
		method body_doc = body_doc
		method body_out = body_out
	end


let make_incipient title body_mrk body_src =
	object
		method title = title
		method body_mrk = body_mrk
		method body_src = body_src
	end

