/************************************************************************/
/* Declaration of the types used internally by the database.		*/
/************************************************************************/

/*
 * Type of the various identifiers.
 */


CREATE DOMAIN id_t		AS int4;
CREATE DOMAIN timezone_id_t	AS id_t;
CREATE DOMAIN user_id_t		AS id_t;
CREATE DOMAIN story_id_t	AS id_t;
CREATE DOMAIN comment_id_t	AS id_t;


CREATE TYPE timezone_brief_t AS
	(
	name		text,
	abbrev		text
	);

