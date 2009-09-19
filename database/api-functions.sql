/************************************************************************/
/* Functional API.							*/
/* This file defines a functional API for database access.		*/
/* Clients should limit themselves to invoking these functions.		*/
/* Direct manipulation of the database tables is neither necessary nor	*/
/* recommended!								*/
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
	SELECT	timezone_id, timezone_name
		FROM timezones;
$$;

/*
 * Returns the specified timezone.
 */

CREATE FUNCTION get_timezone (timezone_id_t)
RETURNS timezone_full_t
LANGUAGE sql STABLE AS
$$
	SELECT	timezone_id, timezone_name
		FROM timezones
		WHERE timezone_id = $1;
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
	SELECT	user_id, user_nick
		FROM users;
$$;


/*
 * Returns all the information for a specified user.
 */

CREATE FUNCTION get_user (user_id)
RETURNS SETOF user_full_t
LANGUAGE sql STABLE AS
$$
	SELECT	user_id, user_nick, user_fullname, user_timezone_id
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
	SELECT	INTO _actual_user *
		FROM users
		WHERE user_nick = _target_nick;

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
 * Returns all stories in the database.
 * Only the story's blurb is returned.
 */

CREATE FUNCTION get_stories ()
RETURNS SETOF story_blurb_t
LANGUAGE sql STABLE AS
$$
	SELECT	story_id, user_id, user_nick, story_title, story_timestamp, story_num_comments, story_intro_xhtml
		FROM stories, users
		WHERE story_author_id = user_id
		ORDER BY story_timestamp DESC
$$;


/*
 * Returns all stories authored by a specified user.
 */

CREATE FUNCTION get_user_stories (user_id_t)
RETURNS SETOF story_handle_t
LANGUAGE sql STABLE AS
$$
	SELECT	story_id, story_title
		FROM stories
		WHERE story_author_id = $1
		ORDER BY story_timestamp DESC
$$;


/*
 * Returns all existing information about the specified story.
 */

CREATE FUNCTION get_story (story_id_t)
RETURNS story_full_t
LANGUAGE sql STABLE AS
$$
	SELECT	story_id, user_id, user_nick, story_title, story_timestamp, story_num_comments, story_intro_xhtml, story_body_xhtml
		FROM stories, users
		WHERE story_id = $1 AND story_author_id = user_id;
$$;


/************************************************************************/
/* Functions returning comments.					*/
/************************************************************************/

/*
 * Returns all comments belonging to a specified story.
 */

CREATE FUNCTION get_story_comments (story_id_t)
RETURNS SETOF comment_full_t
LANGUAGE sql STABLE AS
$$
	SELECT	comment_id, comment_story_id, user_id, user_nick, comment_title, comment_timestamp, comment_body_xhtml
		FROM comments, users
		WHERE comment_story_id = $1 AND comment_author_id = user_id
		ORDER BY comment_timestamp
$$;


/*
 * Returns all comments authored by a specified user.
 */

CREATE FUNCTION get_user_comments (user_id_t)
RETURNS SETOF comment_handle_t
LANGUAGE sql STABLE AS
$$
	SELECT	comment_id, comment_title
		FROM comments
		WHERE comment_author_id = $1
		ORDER BY comment_timestamp;
$$;


/*
 * Returns the specified comment.
 */

CREATE FUNCTION get_comment (comment_id_t)
RETURNS comment_full_t
LANGUAGE sql STABLE AS
$$
	SELECT	comment_id, comment_story_id, user_id, user_nick, comment_title, comment_timestamp, comment_body_xhtml
		FROM comments, users
		WHERE comment_id = $1 AND comment_author_id = user_id;
$$;


/************************************************************************/
/* Functions that add content to the database.				*/
/************************************************************************/

/*
 * Adds a new user.
 */

CREATE FUNCTION add_user (text, text, text, timezone_id_t)
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

CREATE FUNCTION add_story (user_id_t, text, text, bytea, bytea, text, bytea, bytea)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_story_author_id	ALIAS FOR $1;
	_story_title		ALIAS FOR $2;
	_story_intro_src	ALIAS FOR $3;
	_story_intro_doc	ALIAS FOR $4;
	_story_intro_xhtml	ALIAS FOR $5;
	_story_body_src		ALIAS FOR $6;
	_story_body_doc		ALIAS FOR $7;
	_story_body_xhtml	ALIAS FOR $8;

BEGIN
	INSERT	INTO stories
			(
			story_author_id,
			story_title,
			story_timestamp,
			story_num_comments,
			story_intro_src,
			story_intro_doc,
			story_intro_xhtml,
			story_body_src,
			story_body_doc,
			story_body_xhtml
			)
		VALUES
			(
			_story_author_id,
			_story_title,
			now (),
			0,
			_story_intro_src,
			_story_intro_doc,
			_story_intro_xhtml,
			_story_body_src,
			_story_body_doc,
			_story_body_xhtml
			);
END
$$;


/*
 * Adds a new comment.
 */

CREATE FUNCTION add_comment (story_id_t, user_id_t, text, text, bytea, bytea)
RETURNS void
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_comment_story_id	ALIAS FOR $1;
	_comment_author_id	ALIAS FOR $2;
	_comment_title		ALIAS FOR $3;
	_comment_body_src	ALIAS FOR $4;
	_comment_body_doc	ALIAS FOR $5;
	_comment_body_xhtml	ALIAS FOR $6;

BEGIN
	INSERT	INTO comments
			(
			comment_story_id,
			comment_author_id,
			comment_title,
			comment_timestamp,
			comment_body_src,
			comment_body_doc,
			comment_body_xhtml
			)
		VALUES
			(
			_comment_story_id,
			_comment_author_id,
			_comment_title,
			now (),
			_comment_body_src,
			_comment_body_doc,
			_comment_body_xhtml
			);
END
$$;


/************************************************************************/
/* Functions that edit content from the database.			*/
/************************************************************************/

/*
 * Changes the user's credentials (password).
 */

CREATE FUNCTION edit_user_credentials (user_id_t, text, text)
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
        SELECT	INTO _actual_user *
		FROM users
		WHERE user_id = _user_id;

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

CREATE FUNCTION edit_user_settings (user_id_t, text, timezone_id_t)
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

CREATE FUNCTION is_available_nick (text)
RETURNS bool
LANGUAGE sql STABLE AS
$$
	SELECT (COUNT (user_nick) = 0) FROM users WHERE user_nick = $1;
$$;

