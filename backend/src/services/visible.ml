(********************************************************************************)
(*	Visible.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Declaration of the visible services offered by the server.  These are
	public services that the user may directly type into the address bar
	or bookmark.
*)

open Eliom_parameters
open Common

let view_stories =
	lazy (Eliom_services.new_service
		~path: [""]
		~get_params: Eliom_parameters.unit
		())


let view_users =
	lazy (Eliom_services.new_service
		~path: ["view_users"]
		~get_params: Eliom_parameters.unit
		())


let show_story =
	lazy (Eliom_services.new_service
		~path: ["story"]
		~get_params: (Eliom_parameters.suffix (Story.Id.param "sid"))
		())


let show_user =
	lazy (Eliom_services.new_service
		~path: ["user"]
		~get_params: (Eliom_parameters.suffix (User.Id.param "uid"))
		())


let show_comment =
	lazy (Eliom_services.new_service
		~path: ["comment"]
		~get_params: (Eliom_parameters.suffix (Comment.Id.param "cid"))
		())


let add_user =
	lazy (Eliom_services.new_service
		~path: ["add_user"]
		~get_params: Eliom_parameters.unit
		())


let add_story =
	lazy (Eliom_services.new_service
		~path: ["add_story"]
		~get_params: Eliom_parameters.unit
		())


let add_comment_fallback =
	lazy (Eliom_services.new_service
		~path: ["add_comment"]
		~get_params: Eliom_parameters.unit
		())


let add_comment =
	lazy (Eliom_services.new_post_service
		~fallback: !!add_comment_fallback
		~post_params:  (Story.Id.param "sid" **
				Eliom_parameters.string "title" **
				Eliom_parameters.string "body")
		())


let edit_user_settings =
	lazy (Eliom_services.new_service
		~path: ["edit_user_settings"]
		~get_params: Eliom_parameters.unit
		())


let edit_user_credentials =
	lazy (Eliom_services.new_service
		~path: ["edit_user_credentials"]
		~get_params: Eliom_parameters.unit
		())

