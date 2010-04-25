(********************************************************************************)
(*	User.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

module Id = Id.Id32

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

let make_handle uid nick =
	object
		method uid = uid
		method nick = nick
	end


let make_full uid nick fullname timezone =
	object
		method uid = uid
		method nick = nick
		method fullname = fullname
		method timezone = timezone
	end


let make_fresh nick fullname new_password timezone =
	object
		method nick = nick
		method fullname = fullname
		method new_password = new_password
		method timezone = timezone
	end


let make_changed_credentials uid old_password new_password =
	object
		method uid = uid
		method old_password = old_password
		method new_password = new_password
	end


let make_changed_settings uid fullname timezone =
	object
		method uid = uid
		method fullname = fullname
		method timezone = timezone
	end


let make_incipient nick fullname timezone =
	object
		method nick = nick
		method fullname = fullname
		method timezone = timezone
	end

