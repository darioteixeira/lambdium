(********************************************************************************)
(*	Comment.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Document

module Id : Id.ID32

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

type editable_t =
	< cid: Id.t;
	sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
	body_src: source_t;
	body_out: output_t >

type fresh_t =
	< sid: Story.Id.t;
	author: User.handle_t;
	title: string;
	timestamp: Timestamp.t;
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

val make_handle:
	Id.t -> string ->
	handle_t

val make_full:
	Id.t -> Story.Id.t -> User.handle_t -> string -> Timestamp.t -> output_t ->
	full_t

val make_editable:
	Id.t -> Story.Id.t -> User.handle_t -> string -> Timestamp.t -> source_t -> output_t ->
	editable_t

val make_fresh:
	Story.Id.t -> User.handle_t -> string -> source_t -> composition_t -> output_t ->
	fresh_t

val make_changed:
	Id.t -> Story.Id.t -> User.handle_t -> string -> source_t -> composition_t -> output_t ->
	changed_t

val handle_of_tuple:
	(Id.t * string) ->
	handle_t

val full_of_tuple:
	(Id.t * Story.Id.t * User.Id.t * string * string * Timestamp.t * string) ->
	full_t

val tuple_of_fresh:
	fresh_t ->
	(Story.Id.t * User.Id.t * string * string * string * string)

