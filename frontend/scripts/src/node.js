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
	while (candidate && (candidate.nodeType !== Node.ELEMENT_NODE))
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
	while (candidate && (candidate.nodeType !== Node.ELEMENT_NODE))
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
	while (candidate && (candidate.nodeType !== Node.ELEMENT_NODE))
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

