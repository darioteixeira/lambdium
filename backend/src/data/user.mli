(********************************************************************************)
(*	User.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
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

type incipient_t =
	< nick: string;
	fullname: string;
	timezone: Timezone.handle_t >


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

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

val make_incipient:
	string -> string -> Timezone.handle_t ->
	incipient_t

