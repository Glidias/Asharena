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
class Vertex
{

	public function new() 
	{
		
	}
	public var next:Vertex;
	public var value:Vertex;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var offset:Float;
	public var temp:Bool;
	
	public var cameraX:Float;
	public var cameraY:Float;
	public var cameraZ:Float;
	
	public var transformId:Int = 0;
	
	public static var collector:Vertex;
	
	// Creates a temporary vertex to that can be destroyed alongisde Face.destroy()
	public static function create():Vertex {	
		if (collector != null) {
			var res:Vertex = collector;
			collector = res.next;
			res.next = null;
			res.transformId = 0;
			
			res.temp = true;
			//res.drawId = 0;
			return res;
		} else {
			//trace("new Vertex");
			return new Vertex();
		}
	}
	
}