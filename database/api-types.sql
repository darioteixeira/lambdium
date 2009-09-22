/************************************************************************/
/* Declaration of the types returned by the API functions.		*/
/************************************************************************/

/************************************************************************/
/* Timezone related types.						*/
/************************************************************************/

CREATE TYPE timezone_full_t AS
	(
	timezone_id		timezone_id_t,
	timezone_name		text
	);


/************************************************************************/
/* User related types.							*/
/************************************************************************/

CREATE TYPE user_full_t AS
	(
	user_id			user_id_t,
	user_nick		text,
	user_fullname		text,
	user_timezone_id	timezone_id_t
	);


CREATE TYPE user_handle_t AS
	(
	user_id			user_id_t,
	user_nick		text
	);


CREATE TYPE login_t AS
	(
	login_id		user_id_t,
	login_nick		text,
	login_tz		text
	);


/************************************************************************/
/* Story related types.							*/
/************************************************************************/

CREATE TYPE story_full_t AS
	(
	story_id		story_id_t,
	story_author_id		user_id_t,
	story_author_nick	text,
	story_title		text,
	story_timestamp		timestamp,
	story_num_comments	comment_id_t,
	story_intro		bytea,
	story_body		bytea
	);


CREATE TYPE story_blurb_t AS
	(
	story_id		story_id_t,
	story_author_id		user_id_t,
	story_author_nick	text,
	story_title		text,
	story_timestamp		timestamp,
	story_num_comments	comment_id_t,
	story_intro		bytea
	);


CREATE TYPE story_handle_t AS
	(
	story_id		story_id_t,
	story_title		text
	);


/************************************************************************/
/* Comment related types.						*/
/************************************************************************/

CREATE TYPE comment_full_t AS
	(
	comment_id		comment_id_t,
	comment_story_id	story_id_t,
	comment_author_id	user_id_t,
	comment_author_nick	text,
	comment_title		text,
	comment_timestamp	timestamp,
	comment_body		bytea
	);


CREATE TYPE comment_handle_t AS
	(
	comment_id		comment_id_t,
	comment_title		text
	);

