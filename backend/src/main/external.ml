(********************************************************************************)
(*	External.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Declaration of external services.  These correspond to links to external
	URLs, and static resources such as images, CSS, and scripts.
*)

open XHTML.M


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let link_static path =
	Eliom_services.new_external_service
		~prefix: "http://dual:8080"
		~path
		~get_params: Eliom_parameters.unit
		~post_params: Eliom_parameters.unit
		()


let lambdium =
	Eliom_services.new_external_service
		~prefix: "http://forge.ocamlcore.org"
		~path: ["projects"; "lambdium"; ""]
		~get_params: Eliom_parameters.unit
		~post_params: Eliom_parameters.unit
		()


let lambdium_img sp =
	img ~src:(Eliom_predefmod.Xhtml.make_uri (Eliom_services.static_dir sp) sp ["images"; "lambdium-banner.png"]) ~alt:"Lambdium-light" ()


let ocsigen =
	Eliom_services.new_external_service
		~prefix: "http://www.ocsigen.org"
		~path: []
		~get_params: Eliom_parameters.unit
		~post_params: Eliom_parameters.unit
		()


let ocsigen_img sp =
	img ~src:(Eliom_predefmod.Xhtml.make_uri (Eliom_services.static_dir sp) sp ["images"; "ocsigen-banner.png"]) ~alt:"Ocsigen" ()


let ocaml =
	Eliom_services.new_external_service
		~prefix: "http://caml.inria.fr"
		~path: []
		~get_params: Eliom_parameters.unit
		~post_params: Eliom_parameters.unit
		()


let ocaml_img sp =
	img ~src:(Eliom_predefmod.Xhtml.make_uri (Eliom_services.static_dir sp) sp ["images"; "ocaml-banner.png"]) ~alt:"Ocaml" ()

