(********************************************************************************)
(*	User.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

module Id : Id.ID32

type handle_t =
	< uid: Id.t;
	nick: string >

type full_t =
	< uid: Id.t;
	nick: string;
	fullname: string;
	timezone: Timezone.handle_t >

type fresh_t =
	< nick: string;
	fullname: string;
	new_password: string;
	timezone: Timezone.handle_t >

type changed_credentials_t =
	< uid: Id.t;
	old_password: string;
	new_password: string >

type changed_settings_t =
	< uid: Id.t;
	fullname: string;
	timezone: Timezone.handle_t >

val make_handle:
	Id.t -> string ->
	handle_t
	
val make_full:
	Id.t -> string -> string -> Timezone.handle_t ->
	full_t

val make_fresh:
	string -> string -> string -> Timezone.handle_t ->
	fresh_t

val make_changed_credentials:
	Id.t -> string -> string ->
	changed_credentials_t

val make_changed_settings:
	Id.t -> string -> Timezone.handle_t ->
	changed_settings_t

val handle_of_tuple:
	(Id.t * string) ->
	handle_t

val full_of_tuple:
	(Id.t * string * string * Timezone.Id.t option) ->
	full_t

val tuple_of_fresh:
	fresh_t ->
	(string * string * string * Timezone.Id.t option)

val tuple_of_changed_credentials:
	changed_credentials_t ->
	(Id.t * string * string)

val tuple_of_changed_settings:
	changed_settings_t ->
	(Id.t * string * Timezone.Id.t option)

