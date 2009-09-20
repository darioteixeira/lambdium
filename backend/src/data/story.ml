(********************************************************************************)
(*	Story.ml
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
	< sid: Id.t;
	title: string >

type blurb_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	num_comments: Id.t;
	intro_out: output_t >

type full_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	num_comments: Id.t;
	intro_out: output_t;
	body_out: output_t >

type editable_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	num_comments: Id.t;
	intro_src: source_t;
	intro_out: output_t;
	body_src: source_t;
	body_out: output_t >

type fresh_t =
	< author: User.handle_t;
	title: string;
	timestamp: timestamp_t;
	intro_src: source_t;
	intro_doc: composition_t;
	intro_out: output_t;
	body_src: source_t;
	body_doc: manuscript_t;
	body_out: output_t >

type changed_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	intro_src: source_t;
	intro_doc: composition_t;
	intro_out: output_t;
	body_src: source_t;
	body_doc: manuscript_t;
	body_out: output_t >

let make_handle sid title =
	object
		method sid = sid
		method title = title
	end

let make_blurb sid author title timestamp num_comments intro_out =
	object
		method sid = sid
		method author = author
		method title = title
		method timestamp = timestamp
		method num_comments = num_comments
		method intro_out = intro_out
	end

let make_full sid author title timestamp num_comments intro_out body_out =
	object
		method sid = sid
		method author = author
		method title = title
		method timestamp = timestamp
		method num_comments = num_comments
		method intro_out = intro_out
		method body_out = body_out
	end

let make_editable sid author title timestamp num_comments intro_src intro_out body_src body_out =
	object
		method sid = sid
		method author = author
		method title = title
		method timestamp = timestamp
		method num_comments = num_comments
		method intro_src = intro_src
		method intro_out = intro_out
		method body_src = body_src
		method body_out = body_out
	end


let make_fresh author title intro_src intro_doc intro_out body_src body_doc body_out =
	object
		method author = author
		method title = title
		method timestamp = Calendar.now ()
		method intro_src = intro_src
		method intro_doc = intro_doc
		method intro_out = intro_out
		method body_src = body_src
		method body_doc = body_doc
		method body_out = body_out
	end

let make_changed sid author title intro_src intro_doc intro_out body_src body_doc body_out =
	object
		method sid = sid
		method author = author
		method title = title
		method intro_src = intro_src
		method intro_doc = intro_doc
		method intro_out = intro_out
		method body_src = body_src
		method body_doc = body_doc
		method body_out = body_out
	end


let handle_of_tuple (sid, title) =
	make_handle sid title


let blurb_of_tuple (sid, author_uid, author_nick, title, timestamp, num_comments, intro_out) =
	let author = User.make_handle author_uid author_nick
	and intro_out = Document.output_of_string intro_out
	in make_blurb sid author title timestamp num_comments intro_out


let full_of_tuple (sid, author_uid, author_nick, title, timestamp, num_comments, intro_out, body_out) =
	let author = User.make_handle author_uid author_nick
	and intro_out = Document.output_of_string intro_out
	and body_out = Document.output_of_string body_out
	in make_full sid author title timestamp num_comments intro_out body_out


let tuple_of_fresh story =
	let intro_pickle = Document.serialise_composition story#intro_doc
	and intro_out = Document.string_of_output story#intro_out
	and body_pickle = Document.serialise_manuscript story#body_doc
	and body_out = Document.string_of_output story#body_out
	in (story#author#uid, story#title, story#intro_src, intro_pickle, intro_out, story#body_src, body_pickle, body_out)

