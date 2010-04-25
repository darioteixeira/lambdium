(********************************************************************************)
(*	Login.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type t =
	{
	uid: User.Id.t;
	nick: string;
	tz: string option;
	}


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let uid x = x.uid

let nick x = x.nick

let tz x = x.tz

let make uid nick tz =
	{uid = uid; nick = nick; tz = tz;}
	
let to_user x =
	User.make_handle x.uid x.nick

let own_element user = function
	| Some login	-> if login.uid = user#uid then ["own_element"] else []
	| None		-> []

let maybe_uid = function
	| Some l	-> Some l.uid
	| None		-> None

