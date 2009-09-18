/************************************************************************/
/* Functional API.							*/
/* This file defines a functional API for database access.		*/
/* Clients should limit themselves to invoking these functions.		*/
/* Direct manipulation of the database tables is neither necessary nor	*/
/* recommended!  Note also that if you want secure storage of user	*/
/* passwords, you must run the module securise.sql, which redefines	*/
/* of couple of these functions.					*/
/************************************************************************/


/************************************************************************/
/* Functions returning timezones.					*/
/************************************************************************/

/*
 * Returns all timezones in the database.
 */

CREATE FUNCTION get_timezones ()
RETURNS SETOF timezone_full_t
LANGUAGE sql STABLE AS
$$
	SELECT timezone_id, timezone_name, timezone_abbrev, timezone_offset, timezone_dst
	FROM timezones;
$$;

/*
 * Returns the specified timezone.
 */

CREATE FUNCTION get_timezone (int4)
RETURNS timezone_full_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_timezone_id		ALIAS FOR $1;
	_timezone		timezone_full_t%ROWTYPE;
BEGIN
	SELECT	INTO _timezone	
		timezone_id, timezone_name, timezone_abbrev, timezone_offset, timezone_dst
		FROM timezones
		WHERE timezone_id = _timezone_id;

	IF NOT FOUND
	THEN
		RAISE EXCEPTION 'Non-existent timezone';
		RETURN NULL;
	END IF;

	RETURN _timezone;
END
$$;

/************************************************************************/
/* Functions returning users.						*/
/************************************************************************/

/*
 * Returns all users in the database.
 */

CREATE FUNCTION get_users ()
RETURNS SETOF user_handle_t
LANGUAGE sql STABLE AS
$$
	SELECT user_id, user_nick
	FROM users;
$$;


/*
 * Returns all the information for a specified user.
 */

CREATE FUNCTION get_user (user_id int4)
RETURNS SETOF user_full_t
LANGUAGE sql STABLE AS
$$
	SELECT user_id, user_nick, user_fullname, user_timezone_id
	FROM users
	WHERE user_id = $1;
$$;


/*
 * Checks if the specified credentials (username, password) match
 * a user in the database.  If so, this function returns that user;
 * if not, an empty set is returned.
 */

CREATE OR REPLACE FUNCTION get_login (text, text)
RETURNS user_handle_t
LANGUAGE plpgsql AS
$$
DECLARE
        _target_nick            ALIAS FOR $1;
        _target_password        ALIAS FOR $2;
        _target_password_hash   text;
        _actual_user            users%ROWTYPE;
        _actual_user_handle     user_handle_t;

BEGIN
        SELECT INTO _actual_user * FROM users WHERE user_nick = _target_nick;
        IF FOUND
        THEN
                _target_password_hash := crypt (_target_password, _actual_user.user_password_salt);
                IF _target_password_hash = _actual_user.user_password_hash
                THEN
                        _actual_user_handle := (_actual_user.user_id, _actual_user.user_nick);
                        RETURN _actual_user_handle;
                ELSE
                        RAISE EXCEPTION 'Non-matching password';
                        RETURN NULL;
                END IF;
        ELSE
                RAISE EXCEPTION 'Non-existent user name';
                RETURN NULL;
        END IF;
END
$$;



/************************************************************************/
/* Functions returning stories.						*/
/************************************************************************/

/*
 * Returns all stories in the database.  Only the story's blurb is returned.
 * If the specified client_id isn't null, the timestamp of each story is returned
 * in the user's localtime according to their timezone.
 */

CREATE FUNCTION get_stories (int4)
RETURNS SETOF story_blurb_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_client_id	ALIAS FOR $1;
	_timezone	timezone_brief_t%ROWTYPE;
	_story		story_blurb_t%ROWTYPE;

BEGIN
	_timezone := get_user_timezone (_client_id);
	
	FOR _story IN
		SELECT	story_id, user_id, user_nick, story_title,
			timestamp_to_localtime (_timezone, story_timestamp),
			story_num_comments, story_intro_raw
			FROM stories, users
			WHERE story_author_id = user_id
			ORDER BY story_timestamp DESC
		LOOP
			RETURN NEXT _story;
		END LOOP;

	RETURN;
END
$$;


/*
 * Returns all stories authored by a specified user.
 */

CREATE FUNCTION get_user_stories (user_id int4)
RETURNS SETOF story_handle_t
LANGUAGE sql STABLE AS
$$
	SELECT story_id, story_title
	FROM stories
	WHERE story_author_id = $1
	ORDER BY story_timestamp DESC
$$;


/*
 * Returns all existing information about the specified story.
 * If the specified client_id isn't null, the timestamp of the story
 * is returned in the user's localtime according to their timezone.
 */

CREATE FUNCTION get_story (int4, int4)
RETURNS story_full_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_story_id	ALIAS FOR $1;
	_client_id	ALIAS FOR $2;
	_timezone	timezone_brief_t%ROWTYPE;
	_story		story_full_t%ROWTYPE;

BEGIN
	_timezone:= get_user_timezone (_client_id);

	SELECT	INTO _story
		story_id, user_id, user_nick, story_title,
		timestamp_to_localtime (_timezone, story_timestamp),
		story_num_comments, story_intro_raw, story_body_raw
	FROM stories, users
	WHERE story_id = _story_id AND story_author_id = user_id;

	RETURN _story;
END
$$;


/************************************************************************/
/* Functions returning comments.					*/
/************************************************************************/

/*
 * Returns all comments belonging to a specified story.
 * If the specified client_id isn't null, the timestamp of each comment
 * is returned in the user's localtime according to their timezone.
 */

CREATE FUNCTION get_story_comments (int4, int4)
RETURNS SETOF comment_full_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_story_id	ALIAS FOR $1;
	_client_id	ALIAS FOR $2;
	_timezone	timezone_brief_t%ROWTYPE;
	_comment	comment_full_t%ROWTYPE;

BEGIN
	_timezone := get_user_timezone (_client_id);

	FOR _comment IN
		SELECT	comment_id, comment_story_id, user_id, user_nick, comment_title,
			timestamp_to_localtime (_timezone, comment_timestamp), comment_body_raw
			FROM comments, users
			WHERE comment_story_id = _story_id AND comment_author_id = user_id
			ORDER BY comment_timestamp
		LOOP
			RETURN NEXT _comment;
		END LOOP;

	RETURN;
END
$$;


/*
 * Returns all comments authored by a specified user.
 */

CREATE FUNCTION get_user_comments (user_id int4)
RETURNS SETOF comment_handle_t
LANGUAGE sql STABLE AS
$$
	SELECT comment_id, comment_title
	FROM comments
	WHERE comment_author_id = $1
	ORDER BY comment_timestamp;
$$;


/*
 * Returns the specified comment.
 * If the specified client_id isn't null, the timestamp of the comment
 * is returned in the user's localtime according to their timezone.
 */

CREATE FUNCTION get_comment (int4, int4)
RETURNS comment_full_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_comment_id	ALIAS FOR $1;
	_client_id	ALIAS FOR $2;
	_timezone	timezone_brief_t%ROWTYPE;
	_comment	comment_full_t%ROWTYPE;

BEGIN
	_timezone := get_user_timezone (_client_id);

	SELECT	INTO _comment
		comment_id, comment_story_id, user_id, user_nick, comment_title,
		timestamp_to_localtime (_timezone, comment_timestamp), comment_body_raw
		FROM comments, users
		WHERE _comment_id = comment_id AND comment_author_id = user_id;

	RETURN _comment;
END
$$;


/************************************************************************/
/* Functions that add content to the database.				*/
/************************************************************************/

/*
 * Adds a new user.
 */

CREATE OR REPLACE FUNCTION add_user (text, text, text, int4)
RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
        _user_nick              ALIAS FOR $1;
        _user_fullname          ALIAS FOR $2;
        _user_password          ALIAS FOR $3;
        _user_timezone_id       ALIAS FOR $4;
        _user_password_salt     text;
        _user_password_hash     text;

BEGIN
        _user_password_salt := gen_salt ('bf');
        _user_password_hash := crypt (_user_password, _user_password_salt);

        INSERT  INTO users
                        (
                        user_nick,
                        user_fullname,
                        user_password_salt,
                        user_password_hash,
                        user_timezone_id
                        )
                VALUES
                        (
                        _user_nick,
                        _user_fullname,
                        _user_password_salt,
                        _user_password_hash,
                        _user_timezone_id
                        );
END
$$;


/*
 * Adds a new story.
 */

CREATE FUNCTION add_story (int4, text, text, bytea, bytea, text, bytea, bytea)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_story_author_id	ALIAS FOR $1;
	_story_title		ALIAS FOR $2;
	_story_intro_src	ALIAS FOR $3;
	_story_intro_ast	ALIAS FOR $4;
	_story_intro_raw	ALIAS FOR $5;
	_story_body_src		ALIAS FOR $6;
	_story_body_ast		ALIAS FOR $7;
	_story_body_raw		ALIAS FOR $8;

BEGIN
	INSERT	INTO stories
			(
			story_author_id,
			story_title,
			story_timestamp,
			story_num_comments,
			story_intro_src,
			story_intro_ast,
			story_intro_raw,
			story_body_src,
			story_body_ast,
			story_body_raw
			)
		VALUES
			(
			_story_author_id,
			_story_title,
			now (),
			0,
			_story_intro_src,
			_story_intro_ast,
			_story_intro_raw,
			_story_body_src,
			_story_body_ast,
			_story_body_raw
			);
END
$$;


/*
 * Adds a new comment.
 */

CREATE FUNCTION add_comment (int4, int4, text, text, bytea, bytea)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_comment_story_id	ALIAS FOR $1;
	_comment_author_id	ALIAS FOR $2;
	_comment_title		ALIAS FOR $3;
	_comment_body_src	ALIAS FOR $4;
	_comment_body_ast	ALIAS FOR $5;
	_comment_body_raw	ALIAS FOR $6;

BEGIN
	INSERT	INTO comments
			(
			comment_story_id,
			comment_author_id,
			comment_title,
			comment_timestamp,
			comment_body_src,
			comment_body_ast,
			comment_body_raw
			)
		VALUES
			(
			_comment_story_id,
			_comment_author_id,
			_comment_title,
			now (),
			_comment_body_src,
			_comment_body_ast,
			_comment_body_raw
			);
END
$$;


/************************************************************************/
/* Functions that edit content from the database.			*/
/************************************************************************/

/*
 * Changes the user's credentials (password).
 */

CREATE OR REPLACE FUNCTION edit_user_credentials (int4, text, text)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
        _user_id                ALIAS FOR $1;
        _new_password           ALIAS FOR $2;
        _old_password           ALIAS FOR $3;
        _actual_user            users%ROWTYPE;
        _new_password_hash      text;
        _new_password_salt      text;
        _old_password_hash      text;

BEGIN
        SELECT INTO _actual_user * FROM users WHERE user_id = _user_id;
        IF FOUND
        THEN
                _old_password_hash := crypt (_old_password, _actual_user.user_password_salt);

                IF _old_password_hash = _actual_user.user_password_hash
                THEN
                        _new_password_salt := gen_salt ('bf');
                        _new_password_hash := crypt (_new_password, _new_password_salt);

                        UPDATE  users
                                SET (user_password_salt, user_password_hash) = (_new_password_salt, _new_password_hash)
                                WHERE user_id = _user_id;
                        RETURN;
                ELSE
                        RAISE EXCEPTION 'Wrong password';
                        RETURN;
                END IF;
        ELSE
                RAISE EXCEPTION 'Non-existent user ID';
                RETURN;
        END IF;
END
$$;



/*
 * Changes the user's settings.
 */

CREATE FUNCTION edit_user_settings (int4, text, int4)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_user_id		ALIAS FOR $1;
	_user_fullname		ALIAS FOR $2;
	_user_timezone_id	ALIAS FOR $3;
BEGIN
	UPDATE	users
		SET (user_fullname, user_timezone_id) = (_user_fullname, _user_timezone_id)
		WHERE user_id = _user_id;
END
$$;


/************************************************************************/
/* Boolean functions that return the availability of a given element.	*/
/************************************************************************/

/*
 * Is the given user name available?
 */

CREATE FUNCTION is_available_nick (nick text)
RETURNS bool
LANGUAGE sql STABLE AS
$$
	SELECT (COUNT (user_nick) = 0) FROM users WHERE user_nick = $1;
$$;

