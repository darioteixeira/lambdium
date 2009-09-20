(********************************************************************************)
(*	Comment.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open CalendarLib
open Document


module Id = Id.Id32

type handle_t =
	< cid: Id.t;
	title: string >

type full_t =
	< cid: Id.t;
	sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	body_out: output_t >

type editable_t =
	< cid: Id.t;
	sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	body_src: source_t;
	body_out: output_t >

type fresh_t =
	< sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	body_src: source_t;
	body_doc: composition_t;
	body_out: output_t >

type changed_t =
	< cid: Id.t;
	sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	body_src: source_t;
	body_doc: composition_t;
	body_out: output_t >

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

let make_editable cid sid author title timestamp body_src body_out =
	object
		method cid = cid
		method sid = sid
		method author = author
		method title = title
		method timestamp = timestamp
		method body_src = body_src
		method body_out = body_out
	end

let make_fresh sid author title body_src body_doc body_out =
	object
		method sid = sid
		method author = author
		method title = title
		method timestamp = Calendar.now ()
		method body_src = body_src
		method body_doc = body_doc
		method body_out = body_out
	end

let make_changed cid sid author title body_src body_doc body_out =
	object
		method cid = cid
		method sid = sid
		method author = author
		method title = title
		method body_src = body_src
		method body_doc = body_doc
		method body_out = body_out
	end

let handle_of_tuple (cid, title) =
	make_handle cid title

let full_of_tuple (cid, sid, author_uid, author_nick, title, timestamp, body_out) =
	let author = User.make_handle author_uid author_nick
	and body_out = Document.output_of_string body_out
	in make_full cid sid author title timestamp body_out

let tuple_of_fresh comment =
	let body_pickle = Document.serialise_composition comment#body_doc
	and body_out = Document.string_of_output comment#body_out
	in (comment#sid, comment#author#uid, comment#title, comment#body_src, body_pickle, body_out)

