(********************************************************************************)
(*	Ajax.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Declaration of various services offered by the server, and meant to be
	used only by the Javascript frontend via XmlHttpRequest.  Note however
	that there is no way to enforce this restriction.
*)

open Eliom_parameters
open Common


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let preview_comment_fallback =
	lazy (Eliom_services.new_service
		~path: ["preview_comment"]
		~get_params: Eliom_parameters.unit
		())


let preview_comment =
	lazy (Eliom_services.new_post_service
		~fallback: !!preview_comment_fallback
		~post_params:  (Story.Id.param "sid" **
				Eliom_parameters.string "title" **
				Eliom_parameters.string "body")
		())

