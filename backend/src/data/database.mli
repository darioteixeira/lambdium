(********************************************************************************)
(*	Database.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.	
*)
(********************************************************************************)

(**	The database module provides a high-level API for data storage.
	It uses the PG'OCaml syntax extension, and therefore relies on
	a PostgreSQL backend for the actual storage of data.

	Note that because database access is inherently a time-consuming
	operation, but one where we simply wait for input, all functions
	in this module are meant to be used with Lwt cooperative threads.
	They therefore return 'a Lwt.t.
*)

(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Unexpected_result
exception Unique_violation
exception Unknown_uid
exception Unknown_sid
exception Unknown_cid
exception Error of string


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Functions returning timezones}					*)
(********************************************************************************)

val get_timezones: unit -> Timezone.full_t list Lwt.t
val get_timezone: Timezone.Id.t option -> Timezone.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning users}						*)
(********************************************************************************)

val get_users: unit -> User.handle_t list Lwt.t
val get_user: User.Id.t -> User.full_t Lwt.t

val get_login_from_credentials: string -> string -> Login.t option Lwt.t
val get_login_update: User.Id.t -> Login.t Lwt.t


(********************************************************************************)
(**	{2 Functions returning stories}						*)
(********************************************************************************)

val get_stories: unit -> Story.blurb_t list Lwt.t
val get_user_stories: User.Id.t -> Story.handle_t list Lwt.t
val get_story: Story.Id.t -> Story.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning comments}					*)
(********************************************************************************)

val get_story_comments: Story.Id.t -> Comment.full_t list Lwt.t
val get_user_comments: User.Id.t -> Comment.handle_t list Lwt.t
val get_comment: Comment.Id.t -> Comment.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning mixed content (this AND that)}			*)
(********************************************************************************)

(**	Note: the reason why these special functions should be used (instead of
	simply calling the individual functions separately) is to ensure that we
	get a consistent snapshot of the database at a point in time.  Note that
	we use the transaction mechanisms (PGOCaml.begin_work et al) for that.
*)

val get_story_with_comments: Story.Id.t -> (Story.full_t * Comment.full_t list) Lwt.t


(********************************************************************************)
(**	{2 Functions that add content to the database}				*)
(********************************************************************************)

val add_user: User.fresh_t -> User.Id.t Lwt.t
val add_story: output_maker:(Story.Id.t -> string * string) -> side_action:(Story.Id.t -> unit Lwt.t) -> Story.fresh_t -> Story.Id.t Lwt.t
val add_comment: output_maker:(Comment.Id.t -> string) -> Comment.fresh_t -> Comment.Id.t Lwt.t


(********************************************************************************)
(**	{2 Functions that edit content from the database}			*)
(********************************************************************************)

val edit_user_credentials: User.changed_credentials_t -> unit Lwt.t
val edit_user_settings: User.changed_settings_t -> unit Lwt.t


(********************************************************************************)
(**	{2 Functions that return the availability of a given element}		*)
(********************************************************************************)

val is_available_nick: string -> bool Lwt.t

