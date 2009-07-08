/********************************************************************************/
/* event.js									*/
/* Takes care of low-level details of event handling.				*/
/* In particular, it encapsulates browser-specific code from the higher levels.	*/
/********************************************************************************/

/*
 * Create the object to hold this module's namespace.
 */

var Evt = {};

/*
 * This function takes care of event registration.
 * The caller must specify the target element, the event
 * handling function, and the type of event.
 */

Evt.register = function (elem, handler, eventName)

	{
	var altEventName = "on" + eventName;

	if (elem.addEventListener)		// Does the browser support the standard W3C model?
		{
		elem.addEventListener (eventName, handler, false);
		}
	else if (elem.attachEvent)		// Does it instead use the Microsoft model?
		{
		elem.attachEvent (altEventName, handler);
		}
	else if (altEventName in elem)		// Does it at least support the traditional model?
		{
		elem [altEventName] = handler;
		}
	};

/*
 * This function takes care of event unregistration, being
 * in all aspects the counterpart of registerEvent.
 */

Evt.unregister = function (elem, handler, eventName)

	{
	var altEventName = "on" + eventName;

	if (elem.removeEventListener)		// Does the browser support the standard W3C model?
		{
		elem.removeEventListener (eventName, handler, false);
		}
	else if (elem.dettachEvent)		// Does it instead use the Microsoft model?
		{
		elem.dettachEvent (altEventName, handler);
		}
	else if (altEventName in elem)		// Does it at least support the traditional model?
		{
		elem [altEventName] = null;
		}
	};

/*
 * This function takes care of retrieving the event proper.
 * (It is necessary because IE does not provide event handlers with
 * the event, forcing one to retrieve it from a global variable).
 */

Evt.getProper = function (evt)

	{
	return evt || window.event;
	};

/*
 * This function takes care of retrieving the current target element for an event,
 * taking care of the nasty browser incompatibilities.  The standard W3C model
 * says that the original target is given by "evt.currentTarget", while Microsoft
 * says it is given by "evt.srcElement".
 */

Evt.getCurrentTarget = function (evt)

	{
	return evt.currentTarget || evt.srcElement;
	};

/*
 * This function returns the element that was the original target of the event,
 * taking care of the nasty browser incompatibilities.  The standard W3C model
 * says that the original target is given by "evt.target", while Microsoft says
 * it is given by "evt.srcElement".
 */

Evt.getOriginalTarget = function (evt)

	{
	return evt.target || evt.srcElement;
	};

/*
 * Returns the explicit target of the event.  This is used, for example,
 * to know which of the submit buttons in a form was clicked.
 */

Evt.getExplicitTarget = function (evt)

	{
	return evt.explicitOriginalTarget;
	};

/*
 * Cancels the default action of the event.
 */

Evt.cancelDefault = function (evt)

	{
	if (evt.preventDefault)
		{
		evt.preventDefault ();
		}
	else if (evt.returnValue)
		{
		evt.returnValue = false;
		}
	};

/*
 * This function returns the X position (relative to the document)
 * for the mouse event passed as parameter.  It takes care of the
 * various browser-specific ways of getting this information.
 */

Evt.getAbsoluteX = function (evt)

	{
	return evt.pageX || (evt.clientX + (document.documentElement.scrollLeft || document.body.scrollLeft));
	};

/*
 * This function returns the Y position (relative to the document)
 * for the mouse event passed as parameter.  It takes care of the
 * various browser-specific ways of getting this information.
 */

Evt.getAbsoluteY = function (evt)

	{
	return evt.pageY || (evt.clientY + (document.documentElement.scrollTop || document.body.scrollTop));
	};

/*
 * This function returns the X position (relative to the viewport)
 * for the mouse event passed as parameter.  It takes care of the
 * various browser-specific ways of getting this information.
 */

Evt.getViewportX = function (evt)

	{
	return evt.clientX;
	};

/*
 * This function returns the Y position (relative to the viewport)
 * for the mouse event passed as parameter.  It takes care of the
 * various browser-specific ways of getting this information.
 */

Evt.getViewportY = function (evt)

	{
	return evt.clientY;
	};

