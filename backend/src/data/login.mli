(********************************************************************************)
(*	Login.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

type t = {uid: User.Id.t; nick: string;}

val uid: t -> User.Id.t
val nick: t -> string
val of_tuple: (User.Id.t * string) -> t
val of_user: User.handle_t -> t
val to_user: t -> User.handle_t
val own_element: User.handle_t -> t option -> XHTML.M.nmtoken list
val maybe_uid: t option -> User.Id.t option

