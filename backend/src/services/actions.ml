(********************************************************************************)
(*	Actions.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Declaration of non-attached coservices (actions).
*)

open Eliom_parameters

let login =
	lazy (Eliom_services.new_post_coservice'
		~post_params:  (Eliom_parameters.string "nick" **
				Eliom_parameters.string "password" **
				Eliom_parameters.bool "remember")
		())


let logout =
	lazy (Eliom_services.new_post_coservice'
		~post_params: (Eliom_parameters.bool "global")
		())

