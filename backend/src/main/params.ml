(********************************************************************************)
(*	Params.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Eliom_parameters


let add_comment =
	Story.Id.param "sid" **
	Eliom_parameters.string "title" **
	Eliom_parameters.string "body"

let add_story =
	Eliom_parameters.string "title" **
	Eliom_parameters.string "intro" **
	Eliom_parameters.string "body"

let add_user =
	Eliom_parameters.string "nick" **
	Eliom_parameters.string "fullname" **
	Eliom_parameters.string "password" **
	Eliom_parameters.string "password2"**
	Timezone.param "timezone"

let edit_user_credentials =
	Eliom_parameters.string "old_password" **
	Eliom_parameters.string "new_password" **
	Eliom_parameters.string "new_password2"

let edit_user_settings =
	Eliom_parameters.string "fullname" **
	Timezone.param "timezone"

