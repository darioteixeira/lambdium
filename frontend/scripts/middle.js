/*jslint passfail: true, forin: true, evil: true */
/********************************************************************************/
/* array.js									*/
/* Various functions to handle arrays.						*/
/********************************************************************************/

/*
 * Min function: returns the minimum element of the array.
 */

Array.prototype.min = function ()

	{
	return Math.min.apply (null, this);
	};

/*
 * Max function: returns the maximum element of the array.
 */

Array.prototype.max = function ()

	{
	return Math.max.apply (null, this);
	};

/*
 * Takes an array-like collection as parameter, returning its proper "arrayified" equivalent.
 */

Array.toArray = function (pseudoArray)

	{
	if (!pseudoArray)
		{
		return [];
		}
	else	{
		var result = [];
		for (var i=0; i < pseudoArray.length; i++)
			{
			result.push (pseudoArray [i]);
			}
		return result;
		}
	};

/********************************************************************************/
/* bind.js									*/
/* Bind utilities.								*/
/********************************************************************************/

/*
 * Binds.
 */

Function.prototype.bind = function ()

	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	object = oldArgs.shift ();
	return function ()
		{
		var newArgs = Array.toArray (oldArgs);
		return method.apply (object, oldArgs.concat (newArgs));
		};
	};

/*
 * Binds as event listener.
 */

Function.prototype.bindAsEventListener = function (object)

	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	object = oldArgs.shift ();
	return function (evt)
		{
		var newArgs = Array.toArray (arguments);
		return method.apply (object, [(evt || window.event)].concat (oldArgs).concat(newArgs));
		};
	};

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

/********************************************************************************/
/* dom.js									*/
/* This module takes care of all DOM-related activities.			*/
/********************************************************************************/

/*
 * Create the object to hold this module's namespace.
 */

var Dom = {};

/*
 * Returns all elements descendent from the parent element
 * which match a given tag, and have a certain attribute
 * with a given value.
 */

Dom.getElementsByAttr = function (parentElem, tagName, attrName, value)

	{
	var candidateElems = parentElem.getElementsByTagName (tagName);
	var matchingElems = [];
	var pattern = new RegExp ("\\b" + value + "\\b");

	for (var i=0; i < candidateElems.length; i++)
		{
		var candidate = candidateElems [i];      
		if (pattern.test (candidate [attrName]))
			{
			matchingElems.push (candidate);
			}   
		}

	return matchingElems;
	};

/*
 * Returns all elements descendent from the parent element
 * which match a given tag and class name.
 */

Dom.getElementsByClassName = function (parentElem, tagName, className)

	{
	return Dom.getElementsByAttr (parentElem, tagName, "className", className);
	};


/*
 * Returns the ancestor that meets the specified condition.
 * The search must be delimited by a given top ancestor
 * (which can be set to 'document', for example).
 * If no matching ancestor is found, returns top ancestor.
 */

Dom.getAncestor = function (elem, topElem, condition)

	{
	while ((elem != topElem) && !condition (elem))
		{
		elem = elem.parentNode;
		}

	return elem;
	};

/*
 * Returns the ancestor with a given tag.
 * The search must be delimited by a given top ancestor
 * (which can be set to 'document', for example).
 * If no matching ancestor is found, returns top ancestor.
 */

Dom.getAncestorByTagName = function (elem, topElem, tagName)

	{
	var condition = function (elem) {return elem.nodeName === tagName;};

	return Dom.getAncestor (elem, topElem, condition);
	};

/*
 * Returns the ancestor prefixed with the given class name.
 * The search must be delimited by a given top ancestor
 * (which can be set to 'document', for example).
 * If no matching ancestor is found, returns top ancestor.
 */

Dom.getAncestorByClassName = function (elem, topElem, className)

	{
	var condition = function (elem) {return ClassName.isMatch (elem, className);};

	return Dom.getAncestor (elem, topElem, condition);
	};

/********************************************************************************/
/* obj.js									*/
/* Module for storing persistent objects.					*/
/********************************************************************************/

var Obj = {};


/********************************************************************************/
/* Module functions.								*/
/********************************************************************************/

/*
 * Top-level setup function.
 */

Obj.setup = function ()

	{
	Obj.objects = [];
	};

/*
 * Top-level finalise function.
 */

Obj.finalise = function ()

	{
	while (Obj.objects.length > 0)
		{
		var obj = Obj.objects.pop ();
		obj.finalise ();
		}
	};

/*
 * Adds a new object to the list.
 */

Obj.add = function (obj)

	{
	Obj.objects.push (obj);
	};

/********************************************************************************/
/* node.js									*/
/* This module takes care of node-related DOM activities.			*/
/********************************************************************************/

/*
 * Returns the *real* next sibling of a given element.  We can't just use
 * elem.nextSibling directly because Mozilla includes text whitespace as nodes.
 */

Node.prototype.getNextSibling = function ()

	{
	var candidate = this.nextSibling;
	while (candidate && (candidate.nodeType != Node.ELEMENT_NODE))
		{
		candidate = candidate.nextSibling;
		}

	return candidate;
	};

/*
 * Returns the *real* first child of a given element.  We can't just use
 * elem.firstChild directly because Mozilla includes text whitespace as nodes.
 */

Node.prototype.getFirstChild = function ()

	{
	var candidate = this.firstChild;
	while (candidate && (candidate.nodeType != Node.ELEMENT_NODE))
		{
		candidate = candidate.nextSibling;
		}

	return candidate;
	};

/*
 * Returns the *real* last child of a given element.  We can't just use
 * elem.lastChild directly because Mozilla includes text whitespace as nodes.
 */

Node.prototype.getLastChild = function ()

	{
	var candidate = this.lastChild;
	while (candidate && (candidate.nodeType != Node.ELEMENT_NODE))
		{
		candidate = candidate.previousSibling;
		}

	return candidate;
	};

/*
 * Inserts a new child at the beginning of the child tree.
 */

Node.prototype.prependChild = function (child)

	{
	this.insertBefore (child, this.firstChild);
	};

/********************************************************************************/
/* ajaxer.js									*/
/* Provides for XmlHttpRequest (vulgo Ajax) handling.				*/
/********************************************************************************/

var Ajaxer = {};


/*
 * Module constants.
 */

Ajaxer.PROTOCOL_GET = "GET";
Ajaxer.PROTOCOL_POST = "POST";


/*
 *
 */


Ajaxer.encodeData = function (data)
	{
	var pairs = [];
	var regexp = /%20/g; // A regular expression to match an encoded space

	for (var name in data)
		{
		var value = data [name].toString ();
		var pair = encodeURIComponent(name).replace(regexp,"+") + '=' +
			encodeURIComponent(value).replace(regexp,"+");
		pairs.push(pair);
		}

	return pairs.join('&');
	};


/*
 * The factories contain the various browser-specific way of obtaining
 * an XMLHttpRequest object.  These should be tried out in order, until
 * we find one that works.
 */

Ajaxer.factories =
	[
	function () {return new XMLHttpRequest ();},
	function () {return new ActiveXObject ("Msxml2.XMLHTTP");},
	function () {return new ActiveXObject ("Msxml3.XMLHTTP");},
	function () {return new ActiveXObject ("Microsoft.XMLHTTP");}
	];


/*
 * This class variable contains a factory that has worked in returning
 * an XMLHttpRequest object.  It serves as a cache, avoiding the trouble
 * of determining the factory every time a new object is created.
 */

Ajaxer.factory = null;


/*
 * Returns a new XMLHttpRequest object.
 */

Ajaxer.newRequest = function ()

	{
	if (Ajaxer.factory !== null)
		{
		return Ajaxer.factory ();
		}

	for (var i=0; i < Ajaxer.factories.length; i++)
		{
		try	{
			var factory = Ajaxer.factories [i];
			var request = factory ();
			if (request !== null)
				{
				Ajaxer.factory = factory;
				return request;
				}
			}
		catch (e)
			{
			continue;
			}
		}

	// If we got this far is because no suitable factories were found.
	// Let's just raise an exception and cache that behaviour.

	Ajaxer.factory = function ()
		{
		throw new Error ("XmlHttpRequest is not supported");
		};

	Ajaxer.factory ();
	};


/*
 * The core of the module.  This function executes a new XMLHttpRequest, taking
 * care of setting (and unsetting if need be) timeouts if required, and calling
 * the appropriate user-provided handlers for success and error conditions.
 */

Ajaxer.executeRequest = function (protocol, url, data, successHandler, errorHandler, options)

	{
	var request = Ajaxer.newRequest();
	var timer;

	if (!options)
		{
		options = {};
		}

	// The user can specify a timeout for the request in options.timeoutHandler.
	// Optionally, a function options.timeoutHandler can also be called.

	if (options.timeout)
		{
		var whenTimedout = function ()
			{
			request.onreadystatechange = function () {};
			request.abort ();
			if (options.timeoutHandler) {options.timeoutHandler ();}
			};

		timer = setTimeout (whenTimedout, options.timeout);
		}

	request.onreadystatechange = function ()
		{
		if (request.readyState == 4)
			{
			if (timer) {clearTimeout (timer);}

			// This somewhat convuluted way of determining which handler
			// (success or error) to call is due to a bug in Firefox:
			// https://bugzilla.mozilla.org/show_bug.cgi?id=238559

			var handler = errorHandler;

			try	{
				if (request.status == 200) {handler = successHandler;}
				}
			catch (e) {}

			handler (request);
			}
		};

	// Open the request (further configurations must be done on an open request).

	request.open (protocol, url, true);

	// Set the request headers.  One of them, 'User-Agent', is always set.
	// The others can be passed in the options.requestHeaders

	request.setRequestHeader ("User-Agent", "XMLHTTP");

	if (options.requestHeaders)
		{
		for (var prop in options.requestHeaders)
			{
			request.setRequestHeader (prop, options.requestHeaders [prop]);
			}
		}

	// Configurations done.  Issue the request!

	request.send (data);
	};


/*
 * Convenience function that issues a XMLHttpRequest using the GET method.
 */

Ajaxer.get = function (url, values, successHandler, errorHandler, options)

	{
	// If the values dictionary isn't null, then let's encode it in the URL.

	if (values)
		{
		var data = Ajaxer.encodeData (values);
		url = url + '?' + data;
		}

	// The function Ajaxer.executeRequest takes care of the actual work.

	Ajaxer.executeRequest (Ajaxer.PROTOCOL_GET, url, null, successHandler, errorHandler, options);
	};


/*
 * Convenience function that issues a XMLHttpRequest using the POST method.
 */

Ajaxer.post = function (url, values, successHandler, errorHandler, options)

	{
	// We'll encode the data in 'application/x-www-form-urlencoded'
	// format and set one of the requestHeaders accordingly.

	var data = Ajaxer.encodeData (values);

	if (!options) {options = {};}
	if (!options.requestHeaders) {options.requestHeaders = {};}

	options.requestHeaders ["Content-Type"] = "application/x-www-form-urlencoded";

	// The function Ajaxer.executeRequest takes care of the actual work.

	Ajaxer.executeRequest (Ajaxer.PROTOCOL_POST, url, data, successHandler, errorHandler, options);
	};

/********************************************************************************/
/* previewer.js									*/
/* Story and comment previews via Ajax.						*/
/********************************************************************************/

/********************************************************************************/
/* Object-oriented portion: constructor and instance methods.			*/
/********************************************************************************/

/*
 * Object (sort of) constructor.
 * Creates the "Preview" button and attaches an onclick handler to it.
 */

function Previewer (form)

	{
	this.form = form;
	this.submitBinding = this.submitHandler.bindAsEventListener (this);
	Evt.register (this.form, this.submitBinding, "submit");
	}


/*
 * Object (sort of) destructor.
 */

Previewer.prototype.finalise = function () {};

/*
 * Submit handler.
 */

Previewer.prototype.submitHandler = function (evt)

	{
	var target = Evt.getExplicitTarget (evt);

	if (target.value === "Preview")
		{
		Evt.cancelDefault (evt);
		var url = this.form.action.replace (/add_comment/, "preview_comment");

		var values = {};
		values.sid = this.form.sid.value;
		values.title = this.form.title.value;
		values.body = this.form.body.value;

		var myself = this;
		var successHandler = function (request) {myself.successHandler (request);};
		var errorHandler = function (request) {myself.errorHandler (request);};

		Ajaxer.post (url, values, successHandler, errorHandler);
		}
	};


Previewer.prototype.successHandler = function (request)

	{
	var response = eval ('(' + request.responseText + ')');
	var container = this.getContainer ();
	container.innerHTML = response.content;
	};


Previewer.prototype.errorHandler = function (request)

	{
	var container = this.getContainer ();
	container.innerHTML = "<h1 class=\"error_msg\">Could not get preview!</h1>";
	};


Previewer.prototype.getContainer = function ()

	{
	var parentNode = this.form.parentNode;
	var container = parentNode.getLastChild ();

	if (container.className !== "comment_preview_wrapper")
		{
		container = document.createElement ("div");
		container.className = "comment_preview_wrapper";
		parentNode.appendChild (container);
		}
	else	{
		while (container.childNodes.length > 0)
			{
			container.removeChild (container.childNodes [0]);
			}
		}

	return container;
	};


/********************************************************************************/
/* Function-oriented portion: class methods.					*/
/********************************************************************************/

/*
 * Top-level setup function.
 */

Previewer.setup = function ()

	{
	// Find out all forms that have "previewable" in their class name.
	// For each one create a new Previewer object, which takes care of the rest.

	var formsPreviewable = Dom.getElementsByClassName (document, "FORM", "previewable");

	for (var i=0; i < formsPreviewable.length; i++)
		{
		Obj.add (new Previewer (formsPreviewable [i]));
		}
	};

/*
 * Top-level finalise function.
 */

Previewer.finalise = function ()

	{
	};

/********************************************************************************/
/* main.js									*/
/* Main programme.								*/
/********************************************************************************/

var Main = {};


/********************************************************************************/
/* Module functions.								*/
/********************************************************************************/

/*
 * Top-level setup function.
 */

Main.setup = function ()

	{
	Obj.setup ();
	Previewer.setup ();
	};

/*
 * Top-level finalise function.
 */

Main.finalise = function ()

	{
	Previewer.finalise ();
	Obj.finalise ();
	};


/********************************************************************************/
/* Top-level statements: register window setup and cleanup handlers.		*/
/********************************************************************************/

Evt.register (window, Main.setup, "load");
Evt.register (window, Main.finalise, "unload");

