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
	while ((elem !== topElem) && !condition (elem))
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
	var condition = function (elem) {return className.isMatch (elem, className);};

	return Dom.getAncestor (elem, topElem, condition);
	};

