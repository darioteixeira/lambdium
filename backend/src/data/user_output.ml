(********************************************************************************)
(*	User_output.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M
open Common


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let output_handle sp user =
	li ~a:[a_class ["user_handle"]]
		[
		Eliom_predefmod.Xhtml.a !!Visible.show_user sp [pcdata user#nick] user#uid
		]


let output_full sp user timezone stories comments =
	div ~a:[a_class ["user"]]
		[
		h1 [pcdata "User information:"];

		dl ~a:[a_class ["user_info"]]
			(dt [pcdata "ID:"])
			[
			dd [pcdata (User.Id.to_string user#uid)];
			dt [pcdata "Login name:"]; dd [pcdata user#nick];
			dt [pcdata "Full name:"]; dd [pcdata user#fullname]
			];

		h1 [pcdata "User timezone:"];

		Timezone_output.output_full timezone;

		h1 [pcdata "List of stories:"];
		(match stories with
			| []	 -> p [pcdata "(This user has written no stories)"]
			| hd::tl -> ul ~a:[a_class ["list_of_stories"]]
					(Story_output.output_handle sp hd)
					(List.map (Story_output.output_handle sp) tl));

		h1 [pcdata "List of comments:"];
		match comments with
			| []	 -> p [pcdata "(This user has written no comments)"]
			| hd::tl -> ul ~a:[a_class ["list_of_comments"]]
					(Comment_output.output_handle sp hd)
					(List.map (Comment_output.output_handle sp) tl);
		]

