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

