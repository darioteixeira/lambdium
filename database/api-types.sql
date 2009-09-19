/************************************************************************/
/* Declaration of the types returned by the API functions.		*/
/************************************************************************/

/************************************************************************/
/* Type of the various identifiers.					*/
/************************************************************************/

CREATE DOMAIN id_t		AS int4;
CREATE DOMAIN timezone_id_t	AS id_t;
CREATE DOMAIN user_id_t		AS id_t;
CREATE DOMAIN story_id_t	AS id_t;
CREATE DOMAIN comment_id_t	AS id_t;


/************************************************************************/
/* Timezone related types.						*/
/************************************************************************/

CREATE TYPE timezone_full_t AS
	(
	timezone_id		timezone_id_t,
	timezone_name		text,
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


/************************************************************************/
/* Story related types.							*/
/************************************************************************/

CREATE TYPE story_full_t AS
	(
	story_id		story_id_t,
	story_author_id		user_id_t,
	story_author_nick	text,
	story_title		text,
	story_timestamp		text,
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
	story_timestamp		text,
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
	comment_timestamp	text,
	comment_body		bytea
	);


CREATE TYPE comment_handle_t AS
	(
	comment_id		comment_id_t,
	comment_title		text
	);

