(********************************************************************************)
(*	Register.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	Takes care of registering the previously declared services.  These fall
	into four categories: user visible public services (that may be bookmarked,
	for example); non-attached coservices (actions), services that are typically
	only visible to the Javascript frontend via XmlHttpRequest, and finally,
	pseudo-services like the registration of a global exception handler.
*)

open Common


(********************************************************************************)
(*	{1 Private functions and values}					*)
(********************************************************************************)

(**	Register user visible public services.
*)
let register_visible () =
	Eliom_predefmod.Xhtml.register !!Visible.view_stories		View_stories.handler;
	Eliom_predefmod.Xhtml.register !!Visible.view_users		View_users.handler;
	Eliom_predefmod.Xhtml.register !!Visible.show_story		Show_story.handler;
	Eliom_predefmod.Xhtml.register !!Visible.show_user		Show_user.handler;
	Eliom_predefmod.Xhtml.register !!Visible.show_comment		Show_comment.handler;
	Eliom_predefmod.Xhtml.register !!Visible.add_user 		Add_user.step1_handler;
	Eliom_predefmod.Xhtml.register !!Visible.add_story		Add_story.step1_handler;
	Eliom_predefmod.Xhtml.register !!Visible.add_comment_fallback	Add_comment.fallback_handler;
	Eliom_predefmod.Xhtml.register !!Visible.add_comment		Add_comment.step1_handler;
	Eliom_predefmod.Xhtml.register !!Visible.edit_user_settings	Edit_user_settings.step1_handler;
	Eliom_predefmod.Xhtml.register !!Visible.edit_user_credentials	Edit_user_credentials.step1_handler


(**	Register non-attached coservices (actions).
*)
let register_actions () =
	Eliom_predefmod.Actions.register !!Actions.login		Session.login_handler;
	Eliom_predefmod.Actions.register !!Actions.logout		Session.logout_handler


(**	Register services visible only to the Ajax API via XmlHttpRequest.
*)
let register_ajaxapi () =
	Eliom_predefmod.Xhtml.register !!Ajax.preview_comment_fallback	Preview_comment.fallback_handler;
	Eliom_predefmod.Text.register !!Ajax.preview_comment		Preview_comment.handler


(**	Register miscelaneous pseudo-services.
*)
let register_pseudo () =
	Eliom_services.set_exn_handler Page.exception_handler


(********************************************************************************)
(*	{1 Public functions and values}						*)
(********************************************************************************)

(**	Register all services.
*)
let register () =
	register_visible ();
	register_actions ();
	register_ajaxapi ();
	register_pseudo ()

