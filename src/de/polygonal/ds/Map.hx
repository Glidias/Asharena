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
package de.polygonal.ds;

/**
	An object that maps keys to values
	
	__This map allows duplicate keys.__
**/
interface Map<K, T> extends Collection<T>
{
	/**
		Returns true if this map contains a mapping for `val`.
	**/
	function has(val:T):Bool;
	
	/**
		Returns true if this map contains `key`.
	**/
	function hasKey(key:K):Bool;
	
	/**
		Returns the element that is mapped to `key` or a special value (see implementation) indicating that `key` does not exist.
	**/
	function get(key:K):T;
	
	/**
		Maps `val` to `key`.
		
		Multiple keys are stored in a First-In-First-Out (FIFO) order - there is no way to access keys which were added after the first `key`,
		other than removing the first `key` which unveils the second `key`.
		@return true if `key` was added for the first time, false if this `key` is not unique.
	**/
	function set(key:K, val:T):Bool;
	
	/**
		Removes a {`key`,value} pair.
		@return true if `key` was successfully removed, false if `key` does not exist.
	**/
	function unset(key:K):Bool;
	
	/**
		Remaps the first occurrence of `key` to `val`.
		
		This is faster than `this.unset(key)` followed by `this.set(key, val)`.
		@return true if the remapping was successful, false if `key` does not exist.
	**/
	function remap(key:K, val:T):Bool;
	
	/**
		Returns a set view of the elements contained in this map.
	**/
	function toValSet():Set<T>;
	
	/**
		Returns a set view of the keys contained in this map.
	**/
	function toKeySet():Set<K>;
	
	/**
		Creates and returns an iterator over all keys in this map.
		
		@see http://haxe.org/ref/iterators
	**/
	function keys():Itr<K>;
}