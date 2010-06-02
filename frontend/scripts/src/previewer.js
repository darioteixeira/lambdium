/********************************************************************************/
/*	Previewer.js
	Copyright (c) 2010 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*/
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
	var response = JSON.parse (request);
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

