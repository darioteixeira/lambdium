/************************************************************************/
/* Declaration of the types returned by the API functions.		*/
/************************************************************************/

/************************************************************************/
/* Timezone related types.						*/
/************************************************************************/

CREATE TYPE timezone_full_t AS
	(
	timezone_id		int4,
	timezone_name		text,
	timezone_abbrev		text,
	timezone_offset		float,
	timezone_dst		boolean
	);


/************************************************************************/
/* User related types.							*/
/************************************************************************/

CREATE TYPE user_full_t AS
	(
	user_id			int4,
	user_nick		text,
	user_fullname		text,
	user_timezone_id	int4
	);


CREATE TYPE user_handle_t AS
	(
	user_id			int4,
	user_nick		text
	);


/************************************************************************/
/* Story related types.							*/
/************************************************************************/

CREATE TYPE story_full_t AS
	(
	story_id		int4,
	story_author_id		int4,
	story_author_nick	text,
	story_title		text,
	story_timestamp		text,
	story_num_comments	int4,
	story_intro		bytea,
	story_body		bytea
	);


CREATE TYPE story_blurb_t AS
	(
	story_id		int4,
	story_author_id		int4,
	story_author_nick	text,
	story_title		text,
	story_timestamp		text,
	story_num_comments	int4,
	story_intro		bytea
	);


CREATE TYPE story_handle_t AS
	(
	story_id		int4,
	story_title		text
	);


/************************************************************************/
/* Comment related types.						*/
/************************************************************************/

CREATE TYPE comment_full_t AS
	(
	comment_id		int4,
	comment_story_id	int4,
	comment_author_id	int4,
	comment_author_nick	text,
	comment_title		text,
	comment_timestamp	text,
	comment_body		bytea
	);


CREATE TYPE comment_handle_t AS
	(
	comment_id		int4,
	comment_title		text
	);

