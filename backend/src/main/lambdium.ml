(********************************************************************************)
(*	Lambdium.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

let () =
	Eliom_services.register_eliom_module "lambdium" Register.register;
	Ocsigen_server.start_server ()

