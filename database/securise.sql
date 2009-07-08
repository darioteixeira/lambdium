/************************************************************************/
/* SQL functions.							*/
/* This module redefines a couple of API functions so that passwords	*/
/* are stored securely (salted + encrypted) in the database.  It relies	*/
/* on the pgcrypto module.						*/
/************************************************************************/

/************************************************************************/
/* Functions returning users.						*/
/************************************************************************/

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
	_target_nick		ALIAS FOR $1;
	_target_password 	ALIAS FOR $2;
	_target_password_hash	text;
	_actual_user		users%ROWTYPE;
	_actual_user_handle	user_handle_t;

BEGIN
	SELECT INTO _actual_user * FROM users WHERE user_name = _target_user_name;
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
	_user_nick		ALIAS FOR $1;
	_user_fullname		ALIAS FOR $2;
	_user_password		ALIAS FOR $3;
	_user_timezone_id	ALIAS FOR $4;
	_user_password_salt	text;
	_user_password_hash	text;

BEGIN
	_user_password_salt := gen_salt ('bf');
	_user_password_hash := crypt (_user_password, _user_password_salt);
	
	INSERT	INTO users
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
	_user_id		ALIAS FOR $1;
	_new_password		ALIAS FOR $2;
	_old_password		ALIAS FOR $3;
	_actual_user		users%ROWTYPE;
	_new_password_hash	text;
	_new_password_salt	text;
	_old_password_hash	text;

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

