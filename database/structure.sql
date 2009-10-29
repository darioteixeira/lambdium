/************************************************************************/
/* Creates the basic structure of a Lambdium database.			*/
/************************************************************************/

/************************************************************************/
/* Type of the various identifiers.					*/
/************************************************************************/

CREATE DOMAIN id_t              AS int4;
CREATE DOMAIN timezone_id_t     AS id_t;
CREATE DOMAIN user_id_t         AS id_t;
CREATE DOMAIN story_id_t        AS id_t;
CREATE DOMAIN comment_id_t      AS id_t;


/************************************************************************/
/* Timezones.								*/
/************************************************************************/

CREATE TABLE timezones
	(
	timezone_id		timezone_id_t UNIQUE NOT NULL,
	timezone_name		text NOT NULL,
	PRIMARY KEY (timezone_id)
	);

CREATE SEQUENCE timezone_id_seq START 1 OWNED BY timezones.timezone_id;
ALTER TABLE timezones ALTER COLUMN timezone_id SET DEFAULT nextval ('timezone_id_seq');


/************************************************************************/
/* Users.								*/
/************************************************************************/

/*
 * Create the "users" relation, together with the sequence
 * that automatically increments the user_id of new users.
 */

CREATE TABLE users
	(
	user_id			user_id_t UNIQUE NOT NULL,
	user_nick		text UNIQUE NOT NULL,
	user_fullname		text NOT NULL,
	user_password_salt	text NOT NULL,
	user_password_hash	text NOT NULL,
	user_timezone_id	timezone_id_t REFERENCES timezones (timezone_id) NULL,
	PRIMARY KEY (user_id)
	);

CREATE SEQUENCE user_id_seq START 1 OWNED BY users.user_id;
ALTER TABLE users ALTER COLUMN user_id SET DEFAULT nextval ('user_id_seq');

CREATE INDEX users_user_timezone_id_idx ON users (user_timezone_id);


/************************************************************************/
/* Stories.								*/
/************************************************************************/

/*
 * Create the "stories" relation, together with the sequence
 * that automatically increments the story_id of new stories.
 * Note that the timestamp is stored in UTC, without TZ info.
 */

CREATE TABLE stories
	(
	story_id		story_id_t UNIQUE NOT NULL,
	story_author_id		user_id_t REFERENCES users (user_id) NOT NULL,
	story_title		text NOT NULL,
	story_timestamp 	timestamp NOT NULL,
	story_num_comments	comment_id_t NOT NULL,
	story_intro_src		text NOT NULL,
	story_intro_doc		bytea NOT NULL,
	story_intro_out	bytea NOT NULL,
	story_body_src		text NOT NULL,
	story_body_doc		bytea NOT NULL,
	story_body_out	bytea NOT NULL,
	PRIMARY KEY (story_id)
	);


CREATE SEQUENCE story_id_seq START 1 OWNED BY stories.story_id;
ALTER TABLE stories ALTER COLUMN story_id SET DEFAULT nextval ('story_id_seq');

CREATE INDEX stories_story_author_id_idx ON stories (story_author_id);

/************************************************************************/
/* Comments.								*/
/************************************************************************/

/*
 * Create the "comments" relation, together with the sequence
 * that automatically increments the comment_id of new comments.
 * Note that the timestamp is stored in UTC, without TZ info.
 */

CREATE TABLE comments
	(
	comment_id		comment_id_t UNIQUE NOT NULL,
	comment_story_id	story_id_t REFERENCES stories (story_id) NOT NULL,
	comment_author_id	user_id_t REFERENCES users (user_id) NOT NULL,
	comment_title		text NOT NULL,
	comment_timestamp	timestamp NOT NULL,
	comment_body_src	text NOT NULL,
	comment_body_doc	bytea NOT NULL,
	comment_body_out	bytea NOT NULL,
	PRIMARY KEY (comment_id)
	);

CREATE SEQUENCE comment_id_seq START 1 OWNED BY comments.comment_id;
ALTER TABLE comments ALTER COLUMN comment_id SET DEFAULT nextval ('comment_id_seq');

CREATE INDEX comments_comment_story_id_idx ON comments (comment_story_id);
CREATE INDEX comments_comment_author_id_idx ON comments (comment_author_id);

