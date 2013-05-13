/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/
 * */

package components;
import util.geom.AABBUtils;
import util.geom.IAABB;



	/**
	 * Class stores object's bounding box object's local space. Generally, position of child objects isn't considered at BoundBox calculation.
	 * Ray intersection always made  boundBox check at first, but it's possible to check on crossing  boundBox  only.
	 *
	 */
	 class BoundBox implements IAABB {

		public var minX:Float;

		public var minY:Float;

		public var minZ:Float;

		public var maxX:Float;

		public var maxY:Float;

		public var maxZ:Float;
		
		public function new() 
		{
			AABBUtils.reset(this);
		
		}
	
	}
