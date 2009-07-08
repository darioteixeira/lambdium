/************************************************************************/
/* Triggers.								*/
/************************************************************************/

/*
 * For performance reasons, each story record contains a field "story_num_comments"
 * that summarises the number of comments associated with that story (this saves us
 * the trouble of calculating that value every time a story blurb is displayed).
 * However, to maintain this number of-up-date, we must define a trigger to increase
 * story_num_comments every time a new comment is added to the story.
 */

CREATE FUNCTION increment_num_comments_triggered ()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
	UPDATE stories SET story_num_comments = story_num_comments + 1 WHERE story_id = NEW.comment_story_id;
	RETURN NULL;
END
$$;

CREATE TRIGGER increment_num_comments_trigger
AFTER INSERT ON comments FOR EACH ROW
EXECUTE PROCEDURE increment_num_comments_triggered ();

