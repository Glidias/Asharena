/*
Copyright (c) 2008-2018 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package de.polygonal.ds.tools;

/**
	A helper class for working with trees.
**/
@:access(de.polygonal.ds.XmlNode)
class TreeTools
{
	/**
		Converts the XML `string` to a tree structure.
	**/
	public static function ofXml(string:String):TreeNode<XmlNode>
	{
		var xml = Xml.parse(string).firstElement();
		
		var node = XmlNode.of(xml);
		var root = new TreeNode<XmlNode>(node);
		node.arbiter = root;
		
		var p:TreeNode<XmlNode>, c:TreeNode<XmlNode>;
		var stack:Array<Dynamic> = [xml, root];
		var top = 1;
		while (top-- != 0)
		{
			p = stack.pop();
			
			for (e in (stack.pop() : Xml))
			{
				if (e.nodeType != Xml.Element) continue;
				
				node = XmlNode.of(e);
				c = new TreeNode<XmlNode>(node);
				node.arbiter = c;
				p.appendNode(c);
				
				stack.push(e);
				stack.push(c);
				top++;
			}
		}
		return root;
	}
}

/**
	An object containing the data of a XML node.
**/
@:publicFields
class XmlNode
{
	static function of(xml:Xml):XmlNode
	{
		var node = new XmlNode();
		node.name = xml.nodeName;
		
		var firstChild = xml.firstChild();
		if (firstChild != null)
		{
			if (firstChild.nodeType == Xml.CData || firstChild.nodeType == Xml.PCData)
			{
				if (~/\S/.match(firstChild.nodeValue))
					node.data = firstChild.nodeValue;
			}
		}
		
		node.attributes = new AttrAccess(xml);
		return node;
	}
	
	/**
		Node element name.
	**/
	var name:String;
	
	/**
		PCDATA or CDATA (if any).
	**/
	var data:String;
	
	/**
		XML Attributes (if any).
	**/
	var attributes:AttrAccess;
	
	/**
		The `TreeNode` instance which owns this node.
	**/
	var arbiter:TreeNode<XmlNode>;
	
	public function new() {}
	
	public function iterator():Iterator<XmlNode>
	{
		var n = arbiter.children;
		return
		{
			hasNext: function() return n != null,
			next: function()
			{
				var t = n;
				n = n.next;
				return t.val;
			}
		}
	}
	
	public function firstDescendant(name:String, deep:Bool = true):XmlNode
	{
		if (arbiter.hasChildren())
		{
			var first = arbiter.getFirstChild().val;
			if (first.name == name)
				return first;
		}
		
		var out = null;
		
		if (deep)
		{
			arbiter.preorder(
				function(x:TreeNode<XmlNode>, userData, preflight)
				{
					if (x.val.name == name)
					{
						out = x.val;
						return false;
					}
					return true;
				}, null);
			return out;
		}
		else
		{
			var c = arbiter.children;
			while (c.hasNextSibling())
			{
				if (c.val.name == name)
				{
					out = c.val;
					break;
				}
				c = c.next;
			}
		}
		return out;
	}
	
	public function descendants(name:String, deep:Bool = true):Array<XmlNode>
	{
		var out = [];
		
		if (deep)
		{
			arbiter.preorder(
				function(x:TreeNode<XmlNode>, userData, preflight)
				{
					if (x.val.name == name)
						out.push(x.val);
					return true;
				}, null);
		}
		else
		{
			var c = arbiter.children;
			while (c.hasNextSibling())
			{
				if (c.val.name == name)
					out.push(c.val);
				c = c.next;
			}
		}
		return out;
	}
	
	#if !no_tostring
	public function toString():String
	{
		return '{ XmlNode: name=$name }';
	}
	#end
}

@:allow(de.polygonal.ds.TreeTools)
private class AttrAccess implements Dynamic<String>
{
	var __o:Dynamic = {};
	
	public function new(xml:Xml)
	{
		for (i in xml.attributes())
			Reflect.setField(__o, i, xml.get(i));
	}
	
	public function resolve(name:String):String
	{
		return Reflect.hasField(__o, name) ? Reflect.field(__o, name) : null;
	}
}