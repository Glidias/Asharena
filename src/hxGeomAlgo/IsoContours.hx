/**
 * IsoContours implementation (Clockwise).
 * 
 * Based on:
 * 
 * @see http://en.wikipedia.org/wiki/Marching_squares
 * @see https://github.com/deltaluca/nape					(by Luca Deltodesco)
 * @see https://github.com/scikit-image/scikit-image		(by scikit-image team)
 * 
 * @author azrafe7
 */

package hxGeomAlgo;

import de.polygonal.ds.BitVector;
import haxe.ds.Vector;
import haxe.ds.ObjectMap;





class IsoContours
{


	var pixels:BitVector;
	public var pixels2:BitVector;
	var width:Int;
	var height:Int;
	
	var values:BitVector;

	var adjacencyMap:AdjacencyMap;

	var  paddedWidth:Int;
	var  paddedHeight:Int;
	
	/**
	 * Constructor.
	 * 
	 * @param	pixels			Bit vector pixels to use as source.
	 */
	public function new(pixels:BitVector, across:Int)
	{
		this.pixels = pixels;
		this.width = across;
		this.height = across;
		this.values = null;
			paddedWidth = width + 2;
		paddedHeight = height + 2;
		//this.isoFunction = (isoFunction != null) ? isoFunction : isoAlpha;
	}
	
	/**
	 * Returns an Array of contours (each contour being an Array of HxPoint) based on where the data crosses the `isoValue`.
	 * 
	 * A contour in the output will be in CCW winding order if it's a hole, and in CW order otherwise.
	 * 
	 * @param	isoValue		Data values crossing this value will get the corresponding pixel pos inserted in a contour. 
	 * @param	addBorders		If true this will work as if the source had a 1px wide border around it (handled in isoFunction()).
	 * @param	recalcValues	Whether isoFunction() needs to be re-run through all pixels.
	 */
	public function find(addBorders:Bool = true, recalcValues:Bool = true):Array<Array<HxPoint>> {
		
		adjacencyMap = new AdjacencyMap();
		
		// run isoFunction through all pixels
		if (recalcValues || values == null) {
			if (values == null) values = new BitVector(paddedWidth * paddedHeight);
			 runIsoFunction();
		}
	
		march( addBorders, recalcValues);	
 		var contours = merge();
		return contours;
	}
	
	public function find2(addBorders:Bool = true, recalcValues:Bool = true):Array<Array<HxPoint>> {
		
		adjacencyMap = new AdjacencyMap();
		
		// run isoFunction through all pixels
		if (recalcValues || values == null) {
			if (values == null) values = new BitVector(paddedWidth * paddedHeight);
			 runIsoFunction2();
		}
	
		march( addBorders, recalcValues);	
 		var contours = merge();
		return contours;
	}
	
	inline function merge() {
		
		var isoLines = [];
		
		
		var segment = null;
		while ((segment = adjacencyMap.getFirstSegment()) != null) {
			
			var start = segment.from;
			var end = segment.to;
			
			var reversedIsoLine = [start];
			var isoLine = [end];
			
			while (true) {
				end = adjacencyMap.getEndingPointOf(end);
				start = adjacencyMap.getStartingPointOf(start);
				
				if (end != null) {
					isoLine.push(end);
				}
				if (start != null) {
					reversedIsoLine.push(start);
				}
				
				if (start == null && end == null) break;
			}
			
			reversedIsoLine.reverse();
			isoLines.push(reversedIsoLine.concat(isoLine));
		}
		
		return isoLines;
	}
	
	inline function runIsoFunction():Void {
	
			for (y in 0...paddedHeight) {
				
				for (x in 0...paddedWidth) {
					
					var pos = y * paddedWidth + x;

					var withinRange:Bool =  x > 0 && x <= width && y > 0 && y <= height;
					var value =withinRange ? pixels.getFlagAt((y-1)*width+x-1): 0;// isoFunction(pixels, x - 1, y - 1);
				
					values.setFlagAt(y*paddedWidth + x, value );
				}
			}
	}
	
	
	inline function runIsoFunction2():Void {
	
			for (y in 0...paddedHeight) {
				
				for (x in 0...paddedWidth) {
					
					var pos = y * paddedWidth + x;

					var withinRange:Bool =  x > 0 && x <= width && y > 0 && y <= height;
					var value =withinRange ? pixels.getFlagAt((y-1)*width+x-1): 0;// isoFunction(pixels, x - 1, y - 1);
					var value2 =  pixels2!= null && withinRange ? pixels2.getFlagAt((y-1)*width+x-1): 1;
					values.setFlagAt(y*paddedWidth + x, (value & value2) );
				}
			}
	}
	
	inline
	function march( addBorders:Bool = true, recalcValues:Bool = true) {
		
		
		
		
		
		
		
		
		// adjust loop variables
		var offset = -.5;
		var startX = 0;
		var startY = 0;
		var endX = width + 1;
		var endY = height + 1;
		if (!addBorders) {
			startX = 1;
			startY = 1;
			endX = width;
			endY = height;
		}
		
		// march
		
		for (x in startX...endX) {
			
			for (y in startY...endY) {
				
				// calc binaryIdx (CW from msb)
				var pos = y * paddedWidth + x;
				var topLeft = values.has(pos); // values[pos];
				var topRight = values.has(pos + 1);
				var bottomRight = values.has(pos + 1 + paddedWidth);
				var bottomLeft = values.has(pos + paddedWidth);
				
				var binaryIdx = 0;
				if (topLeft ) binaryIdx += 8;
				if (topRight ) binaryIdx += 4;
				if (bottomRight) binaryIdx += 2;
				if (bottomLeft) binaryIdx += 1;
				
				if (binaryIdx != 0 && binaryIdx != 15) {
					
					var topPoint = new HxPoint(offset + x + interpB(topLeft, topRight), offset + y);
					var leftPoint = new HxPoint(offset + x, offset + y + interpB(topLeft, bottomLeft));
					var rightPoint = new HxPoint(offset + x + 1, offset + y + interpB(topRight, bottomRight));
					var bottomPoint = new HxPoint(offset + x + interpB(bottomLeft, bottomRight), offset + y + 1);
					
					// resolve saddle ambiguities by using central (/average) value
					if (binaryIdx == 5 || binaryIdx == 10) {
					
						var avgValue = ((topLeft?1:0) + (topRight?1:0) + (bottomRight?1:0) +( bottomLeft?1:0)) / 4;
						if (avgValue <= 0) binaryIdx = ~binaryIdx & 15; // flip binaryIdx
					}
					
					//binaryIdx = 999999;
					// add segments (pairs of points) based on binaryIdx. 
					// consistent order is enforced, meaning that the first point of a 
					// segment is guaranteed to be the second point of another segment 
					// (except for head and tail segments of open isolines of course)
					switch (binaryIdx) { 
						case 1: 
							adjacencyMap.addSegment(leftPoint, bottomPoint);
						case 2: 
							adjacencyMap.addSegment(bottomPoint, rightPoint);
						case 3: 
							adjacencyMap.addSegment(leftPoint, rightPoint);
						case 4: 
							adjacencyMap.addSegment(rightPoint, topPoint);
						case 5: // saddle
							adjacencyMap.addSegment(leftPoint, topPoint);
							adjacencyMap.addSegment(rightPoint, bottomPoint);
						case 6: 
							adjacencyMap.addSegment(bottomPoint, topPoint);
						case 7: 
							adjacencyMap.addSegment(leftPoint, topPoint);
						case 8: 
							adjacencyMap.addSegment(topPoint, leftPoint);
						case 9: 
							adjacencyMap.addSegment(topPoint, bottomPoint);
						case 10: // saddle
							adjacencyMap.addSegment(bottomPoint, leftPoint);
							adjacencyMap.addSegment(topPoint, rightPoint);
						case 11: 
							adjacencyMap.addSegment(topPoint, rightPoint);
						case 12: 
							adjacencyMap.addSegment(rightPoint, leftPoint);
						case 13: 
							adjacencyMap.addSegment(rightPoint, bottomPoint);
						case 14: 
							adjacencyMap.addSegment(bottomPoint, leftPoint);
						default:
					}
				}
			}
		}
	}
	
	public function interp(isoValue:Float, fromValue:Float, toValue:Float):Float {
		if (fromValue == toValue) return 0;
		return (isoValue - fromValue) / (toValue - fromValue);
	}
	
	public function interpB( fromValue:Bool, toValue:Bool):Float {
	
		return fromValue == toValue ? 0 : fromValue ? 1 : 0;
	}
	

	//static
	inline  public function isOutOfBounds(pixels:BitVector, x:Int, y:Int):Bool {
		return (x < 0 || y < 0 || x >= width || y >= height);
	}	
}


/**
 * Stores segments and provides a quick way of finding adjacent/consecutive points.
 * 
 * You can query it to fetch:
 *   - the starting/ending point of a segment (given the other end)
 *   - the first available segment (in insertion order)
 * 
 * Both types of queries will automatically remove the related segment (if any) from the structure.
 */ 
class AdjacencyMap {

	var pointSet:Map<String, HxPoint>;
	
	var firstIdx:Int = 0;
	var segments:Array<Segment>;
	
	var mapStartToEnd:ObjectMap<HxPoint, Array<Int>>;
	var mapEndToStart:ObjectMap<HxPoint, Array<Int>>;
	
	public function new():Void {
		pointSet = new Map();
		segments = [];
		
		mapStartToEnd = new ObjectMap();
		mapEndToStart = new ObjectMap();
	}
	
	public function addSegment(from:HxPoint, to:HxPoint):Void {
		if (from.equals(to)) return; 
		//if  (from != null && to != null && from.x == to.x && from.y == to.y) return ;
		//(HxPoint.areEqual(from, to)) return;

		var fromKey = from.toString();
		var toKey = to.toString();
		
		if (!pointSet.exists(fromKey)) pointSet[fromKey] = from;
		else from = pointSet[fromKey];
		
		if (!pointSet.exists(toKey)) pointSet[toKey] = to;
		else to = pointSet[toKey];
		
		var idx = segments.length;
		segments.push(new Segment(from, to));
		
		if (mapStartToEnd.exists(from)) mapStartToEnd.get(from).push(idx);
		else mapStartToEnd.set(from, [idx]);
		
		if (mapEndToStart.exists(to)) mapEndToStart.get(to).push(idx);
		else mapEndToStart.set(to, [idx]);
	}
	
	public function getStartingPointOf(end:HxPoint):HxPoint {
		if (end == null) return null;
		
		var start = null;
		
		if (mapEndToStart.exists(end)) {
			var entry = mapEndToStart.get(end);
			var idx = entry[0];
			start = segments[idx].from;
			removeSegmentAt(idx);
		}
		
		return start;
	}
	
	public function getEndingPointOf(start:HxPoint):HxPoint {
		if (start == null) return null;
		
		var end = null;
		
		if (mapStartToEnd.exists(start)) {
			var entry = mapStartToEnd.get(start);
			var idx = entry[0];
			end = segments[idx].to;
			removeSegmentAt(idx);
		}
		
		return end;
	}
	
	public function getFirstSegment():Segment {
		var segment = null;
		
		for (i in firstIdx...segments.length) {
			segment = segments[i];
			if (segment != null) {
				removeSegmentAt(i);
				firstIdx = i;
				break;
			}
		}
		
		return segment;
	}
	
	function removeSegmentAt(i:Int) {
		var segment = segments[i];
		
		var start = segment.from;
		var end = segment.to;
		
		var entry = mapStartToEnd.get(start);
		entry.remove(i);
		if (entry.length == 0) mapStartToEnd.remove(start);
		
		entry = mapEndToStart.get(end);
		entry.remove(i);
		if (entry.length == 0) mapEndToStart.remove(end);
		
		segments[i] = null;
	}	
}

private class Segment {
	public var from:HxPoint;
	public var to:HxPoint;
	
	public function new(from:HxPoint, to:HxPoint):Void {
		this.from = from;
		this.to = to;
	}
}