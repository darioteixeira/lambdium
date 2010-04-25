(********************************************************************************)
(*	Story.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Document


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Id: Id.ID32

type handle_t =
	< sid: Id.t;
	title: string >

type blurb_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	num_comments: Id.t;
	intro_out: output_t >

type full_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	num_comments: Id.t;
	intro_out: output_t;
	body_out: output_t >

type editable_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	num_comments: Id.t;
	intro_mrk: Markup.t;
	intro_src: source_t;
	intro_out: output_t;
	body_mrk: Markup.t;
	body_src: source_t;
	body_out: output_t >

type fresh_t =
	< author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	intro_mrk: Markup.t;
	intro_src: source_t;
	intro_doc: composition_t;
	intro_out: output_t;
	body_mrk: Markup.t;
	body_src: source_t;
	body_doc: manuscript_t;
	body_out: output_t >

type changed_t =
	< sid: Id.t;
	author: User.handle_t;
	title: string;
	intro_mrk: Markup.t;
	intro_src: source_t;
	intro_doc: composition_t;
	intro_out: output_t;
	body_mrk: Markup.t;
	body_src: source_t;
	body_doc: manuscript_t;
	body_out: output_t >

type incipient_t =
	< title: string;
	intro_mrk: Document.Markup.t;
	intro_src:string;
	body_mrk:Document.Markup.t;
	body_src:string >


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

val make_handle:
	Id.t -> string ->
	handle_t

val make_blurb:
	Id.t -> User.handle_t -> string -> Timestamp.t -> Id.t -> output_t ->
	blurb_t

val make_full:
	Id.t -> User.handle_t -> string -> Timestamp.t -> Id.t -> output_t -> output_t ->
	full_t

val make_editable:
	Id.t -> User.handle_t -> string -> Timestamp.t -> Id.t -> Markup.t -> source_t -> output_t -> Markup.t -> source_t -> output_t ->
	editable_t

val make_fresh:
	User.handle_t -> string -> Markup.t -> source_t -> composition_t -> output_t -> Markup.t -> source_t -> manuscript_t -> output_t ->
	fresh_t

val make_changed:
	Id.t -> User.handle_t -> string -> Markup.t -> source_t -> composition_t -> output_t -> Markup.t -> source_t -> manuscript_t -> output_t ->
	changed_t

val make_incipient:
	string -> Markup.t -> source_t -> Markup.t -> source_t ->
	incipient_t

