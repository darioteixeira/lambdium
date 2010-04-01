(********************************************************************************)
(*	Forms.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M


module Monatomic =
struct
	let make_button value =
		fieldset ~a:[a_class ["control_set"]]
			[
			Eliom_predefmod.Xhtml.string_input ~input_type:`Submit ~value ();
			]

	let make_form ~label ~service ~sp ?content () =
		let form_maker enter_content =
			(match content with | Some c -> c enter_content | None -> Lwt.return []) >>= fun fieldsets ->
			Lwt.return (fieldsets @ [make_button label]) in
		Eliom_predefmod.Xhtml.lwt_post_form ~a:[a_class ["core_form"]] ~service ~sp form_maker () >>= fun form ->
		let form = (form : Xhtmltypes.form XHTML.M.elt :> [> Xhtmltypes.form ] XHTML.M.elt)
		in Lwt.return form
end


module Triatomic =
struct
	type t = [ `Cancel | `Continue | `Conclude ]

	let of_string = function
		| "Cancel"	-> `Cancel
		| "Continue"	-> `Continue
		| "Conclude"	-> `Conclude
		| x		-> raise (Invalid_argument x)

	let to_string = function
		| `Cancel	-> "Cancel"
		| `Continue	-> "Continue"
		| `Conclude	-> "Conclude"

	let param = Eliom_parameters.user_type of_string to_string "action"

	let make_buttons enter_action =
		fieldset ~a:[a_class ["control_set"]]
			[
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Cancel to_string ();
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Continue to_string ();
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Conclude to_string ();
			]

	let make_form ~service ~sp ?content () =
		let form_maker (enter_action, enter_content) = 
			(match content with | Some c -> c enter_content | None -> Lwt.return []) >>= fun form ->
			Lwt.return (form @ [make_buttons enter_action]) in
		Eliom_predefmod.Xhtml.lwt_post_form ~a:[a_class ["core_form"]] ~service ~sp form_maker () >>= fun form ->
		let form = (form : Xhtmltypes.form XHTML.M.elt :> [> Xhtmltypes.form ] XHTML.M.elt)
		in Lwt.return form
end


module Previewable =
struct
	type t = [ `Cancel | `Preview | `Finish ]

	let of_string = function
		| "Cancel"	-> `Cancel
		| "Preview"	-> `Preview
		| "Finish"	-> `Finish
		| x		-> raise (Invalid_argument x)

	let to_string = function
		| `Cancel	-> "Cancel"
		| `Preview	-> "Preview"
		| `Finish	-> "Finish"

	let param = Eliom_parameters.user_type of_string to_string "action"

	let make_buttons enter_action =
		fieldset ~a:[a_class ["control_set"]]
			[
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Cancel to_string ();
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Preview to_string ();
			Eliom_predefmod.Xhtml.user_type_input ~input_type:`Submit ~name:enter_action ~value:`Finish to_string ();
			]

	let make_form ~service ~sp ?content () =
		let form_maker (enter_action, enter_content) =
			(match content with | Some c -> c enter_content | None -> Lwt.return []) >>= fun form ->
			Lwt.return (form @ [make_buttons enter_action]) in
		Eliom_predefmod.Xhtml.lwt_post_form ~a:[a_class ["core_form"]] ~service ~sp form_maker () >>= fun form ->
		let form = (form : Xhtmltypes.form XHTML.M.elt :> [> Xhtmltypes.form ] XHTML.M.elt)
		in Lwt.return form
end

