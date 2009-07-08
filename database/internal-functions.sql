/************************************************************************/
/* Auxiliary functions used internally by the database.			*/
/* These are not meant to be called by clients.				*/
/************************************************************************/

/*
 * Returns the timezone associated with the given user_id.
 * If user_id is NULL or if the user has no timezone defined,
 * then 'UTC' is returned.
 */

CREATE FUNCTION get_user_timezone (int4)
RETURNS timezone_brief_t
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_client_id		ALIAS FOR $1;
	_timezone		timezone_brief_t%ROWTYPE;
BEGIN
	SELECT	INTO _timezone.name, _timezone.abbrev
		timezone_name, timezone_abbrev
		FROM users, timezones
		WHERE	user_id = _client_id AND
			user_timezone_id = timezone_id;

	IF NOT FOUND
	THEN
		_timezone.name := 'UTC';
		_timezone.abbrev := 'UTC';
	END IF;

	RETURN _timezone;
END
$$;


/*
 * Converts a timestamp into one specified in a particular timezone.
 */

CREATE FUNCTION timestamp_to_localtime (timezone_brief_t, timestamptz)
RETURNS text
LANGUAGE plpgsql STABLE AS
$$
DECLARE
	_timezone 	ALIAS FOR $1;
	_timestamp	ALIAS FOR $2;
BEGIN
	RETURN to_char (_timestamp AT TIME ZONE _timezone.name, 'YYYY-MM-DD HH24:MI:SS ') || _timezone.abbrev;
END
$$;

