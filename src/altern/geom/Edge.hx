package altern.geom;

/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */
/**
 * Port over to Haxe
 * @author Glidias
 */
class Edge
{

	public function new() 
	{
		
	}
	public var next:Edge;

	public var a:Vertex;
	public var b:Vertex;

	public var left:Face;
	public var right:Face;
	
}