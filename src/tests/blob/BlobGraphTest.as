package tests.blob 
{
	import alternativa.engine3d.materials.EnvironmentMaterial;
	import com.bit101.components.ComboBox;
	import com.bit101.components.RadioButton;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import com.bit101.components.PushButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class BlobGraphTest extends Sprite
	{
		
		private var btn_createNode:PushButton;
		private var btn_createArc:PushButton;
		private var btn_moveParty:PushButton;
		
		
		public static const NORTH:int = 0;
		public static const EAST:int = 1;
		public static const SOUTH:int = 2;
		public static const WEST:int = 3;
		
		private var combo_presetNode:ComboBox;
		private var combo_direction:ComboBox;
		
		private var currentPartyFacing:int = NORTH;
		private function getReverseDirection(dir:int):int {
			return (dir & 1) ? dir === NORTH ? SOUTH :NORTH : dir === WEST ? EAST : WEST;
		}
		private var _curDragged:BlobNode;
		private var btn_spawnParty:PushButton;
		private var btn_unselect:PushButton;
		private var _arcMode:Boolean;
		
		private var arcWaypoints:Sprite = new Sprite();
		private var curPartyLocation:BlobNode;
		public function showArcWaypoints():void {
			if (!curPartyLocation) {
				curPartyLocation = null;
				arcWaypoints.visible = false;
				return;
			}
			blobNodeHolder.mouseChildren = 	blobNodeHolder.mouseEnabled = false;
			blobNodeHolder.alpha = .5;
		
			arcWaypoints.visible  = true;
			var numChildren:int = arcWaypoints.numChildren;
			
			var len:int = curPartyLocation.arcs.length;
			for (var i:int = 0; i < len; i++) {
				var arc:BlobArc = curPartyLocation.arcs[i];
				var wp:Sprite = i < numChildren ? arcWaypoints.getChildAt(i) as Sprite: createArcWaypt(BlobNode.COLORS[arc.direction]);
				wp.graphics.clear();
				wp.graphics.beginFill(BlobNode.COLORS[arc.direction], 1);
			wp.graphics.drawCircle(0, 0, 8);
				wp.visible = true;
				var dest:BlobNode = arc.to;
				wp.x = dest.x;
				wp.y = dest.y;
				wayptArcs[i] =arc;
			}
			
			while (i < arcWaypoints.numChildren) {
				arcWaypoints.getChildAt(i).visible = false;
				i++;
			}
			
			
			addChild(arcWaypoints);
			

		}
		
		private var wayptArcs:Array = [];
		private function createArcWaypt(color:uint):Sprite {
			var spr:Sprite = new Sprite();
			spr.buttonMode = true;
			
			arcWaypoints.addChild(spr);
			spr.addEventListener(MouseEvent.CLICK, onArcWaypointClick);
			spr.buttonMode = true;
			return spr;
			
		}
		
		private function onArcWaypointClick(e:Event):void 
		{
			var index:int = arcWaypoints.getChildIndex(e.currentTarget as DisplayObject);
			var arc:BlobArc = wayptArcs[index];
			arc.to.occupyFromDirection(chars, arc.direction);
			
			arcWaypoints.visible = false;
			curPartyLocation = arc.to;
			currentPartyFacing = arc.direction;
			blobNodeHolder.mouseChildren = 	blobNodeHolder.mouseEnabled = true;
			blobNodeHolder.alpha = 1;
		}
		
		private function onMoveClick(e:Event):void {
			showArcWaypoints();
			_arcMode = false;
			
		}
		
		public function BlobGraphTest() 
		{	
			addChild(blobNodeHolder);
			
			btn_createNode = new PushButton(this, 20, 20, "Create Blob Node", createNodeHandler);
			combo_presetNode = new ComboBox(this, 20,40, "Standard Node", ["Standard Blob Node", "Compressed Blob Node"]);
			combo_presetNode.selectedIndex = 0;
			
			btn_createArc = new PushButton(this, 20, 80, "Create Arc", createArcHandler);
			combo_direction = new ComboBox(this, 20, 100, "North", ["North", "East", "South", "West"]);
			combo_direction.selectedIndex = 0;
			
			btn_unselect = new PushButton(this, 20, 150, "Clear Selection", doUnselect);
		
			btn_spawnParty = new PushButton(this, 20, 180, "Spawn Party At Selected", spawnPartyHandler);
			
			createChar("1");
			createChar("2");
			createChar("3");
			createChar("4");
			
			btn_moveParty = new PushButton(this, 20, 200, "Move Party", onMoveClick);
			
			
		}
		
		private var chars:Array = [];
	
		private function createChar(label:String):Sprite {
			var spr:Char = new Char(label);
	
			chars.push(spr);
			return spr;
		}
		
		private function doUnselect(e:Event=null):void 
		{
			if (_curDragged) {
				_curDragged.selected = false;
			}
			_curDragged = null;
			_arcMode = false;
			
			blobNodeHolder.mouseChildren = 	blobNodeHolder.mouseEnabled = true;
			blobNodeHolder.alpha = 1;
			arcWaypoints.visible = false;
		}
		
		private function spawnPartyHandler(e:Event):void 
		{
			if (_curDragged) {
				_curDragged.occupyFromDirection(chars, currentPartyFacing );
				curPartyLocation = _curDragged;
				
			}
			doUnselect();
			
		}
		
		private var blobNodes:Array = [];
		private var blobNodeHolder:Sprite = new Sprite();
		
		private function addBlobNode(size:Number):void 
		{
			var child:DisplayObject = new BlobNode(size);
			blobNodes.push(child);
			
			child.x = stage.stageWidth * .5 - size * .5 + Math.random()*64;
			child.y = stage.stageHeight * .5 - size * .5+ Math.random()*64;
			blobNodeHolder.addChild(child );
			child.addEventListener(MouseEvent.MOUSE_DOWN, onBlobNodePress, false, 0, true);
			
			
			
		}
		
		private function removeBlobNode(node:BlobNode):void {  // not yet done
			blobNodes.splice(blobNodes.indexOf(node));
			removeChild(node);
			node.removeEventListener(MouseEvent.MOUSE_DOWN, onBlobNodePress);
			
			// remove linked arcs
		}
		
		private function onBlobNodePress(e:MouseEvent):void 
		{
			var child:BlobNode = (e.currentTarget as BlobNode);
			if (_curDragged && _arcMode) {
				if (child != _curDragged) createArc(_curDragged,child );
				_arcMode = false;
				return;
			}
			
			if (_curDragged) {
				_curDragged.selected = false;
			}
			addChild(child);
			child.startDrag();
			_curDragged = child;
			_curDragged.selected = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageRelease);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
		}
		
		private function onDrag(e:MouseEvent):void 
		{
			//if (_curDragged) _curDragged.updateArcs();
			var len:int = blobNodes.length;
			for (var i:int = 0; i < len; i++) {
				var blobNode:BlobNode = blobNodes[i];
				blobNode.updateArcs();
			}
		}
		
		private function createArc(from:BlobNode, to:BlobNode):void 
		{
			
			from.addArc(to, combo_direction.selectedIndex);
			
			
		}
		
		private function onStageRelease(e:MouseEvent):void 
		{
			_curDragged.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageRelease);
			_arcMode = false;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
		}
		
		
		
		private function createArcHandler(e:Event):void 
		{
			if (!_curDragged) {
				return;
			}
			
			_arcMode = true;
		}
		
		
		
		private function createNodeHandler(e:Event):void 
		{
			_arcMode = false;
			addBlobNode(combo_presetNode.selectedIndex == 0 ? 64 : 32);
		}
		
	

	}
}

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.ui.Mouse;
class BlobNode extends Sprite {
	
	private var _selected:Boolean = false;
	public var arcHolder:Sprite;
	public var arcs:Array = [];
	private var north:Sprite;
	public static const CHAR_RADIUS:int = 8;
	
	public static const COLORS:Vector.<uint> = new <uint>[0xFF0000, 0x00FF00, 0x0000FF, 0x00FFFF];
	public static const DIRECTIONS_POSITIONS:Vector.<int> = new <int>[0,1,2,3  ,1,3,0,2   ,3,2,1,0    ,2,0,3,1];
	
	public static function drawArrow(graphics:Graphics, ax:int, ay:int, bx:int, by:int, color:uint=0, size:Number=8):void
	{
		// a is beginning, b is the arrow tip.

		var abx:int, aby:int, ab:int, cx:Number, cy:Number, dx:Number, dy:Number, ex:Number, ey:Number, fx:Number, fy:Number;
		var ratio:Number = 2, fullness1:Number = 2, fullness2:Number = 3;  // these can be adjusted as needed

		abx = bx - ax;
		aby = by - ay;
		ab = Math.sqrt(abx * abx + aby * aby);

		cx = bx - size * abx / ab;
		cy = by - size * aby / ab;
		dx = cx + (by - cy) / ratio;
		dy = cy + (cx - bx) / ratio;
		ex = cx - (by - cy) / ratio;
		ey = cy - (cx - bx) / ratio;
		fx = (fullness1 * cx + bx) / fullness2;
		fy = (fullness1 * cy + by) / fullness2;

		// draw lines and apply fill: a -> b -> d -> f -> e -> b
		// replace "sprite" with the name of your sprite
		//graphics.clear();
		graphics.beginFill(color);
		graphics.lineStyle(1, color);
		graphics.moveTo(ax, ay);
		graphics.lineTo(bx, by);
		graphics.lineTo(dx, dy);
		graphics.lineTo(fx, fy);
		graphics.lineTo(ex, ey);
		graphics.lineTo(bx, by);
		graphics.endFill();
	}

	public var mainHolder:Sprite = new Sprite();
	private static const POSITION_OFFSETS:Vector.<int> = new <int>[-1,-1,  1,-1, -1,1, 1,1];
	private var posOffset:Number;
	private var charHolder:Sprite =  new Sprite();
	
	public function BlobNode(size:Number) {
		
		addChild(mainHolder);
		mainHolder.graphics.lineStyle(0, 0)
		
	
		var hSize:Number = size * .5;
		
		var square:Sprite = new Sprite();
		square.graphics.beginFill(0xFFFFFF, .5);
		square.graphics.lineStyle(0, 0)
		mainHolder.addChild(square);
		
		buttonMode = true;
		var circles:Sprite = new Sprite();
		mainHolder.addChild(circles);
		
		circles.graphics.lineStyle(0, 0);
		posOffset = hSize * .5;
		circles.graphics.drawCircle( posOffset * POSITION_OFFSETS[0], posOffset * POSITION_OFFSETS[1], CHAR_RADIUS);
		circles.graphics.drawCircle( posOffset * POSITION_OFFSETS[2], posOffset * POSITION_OFFSETS[3], CHAR_RADIUS);
		circles.graphics.drawCircle( posOffset * POSITION_OFFSETS[4], posOffset * POSITION_OFFSETS[5], CHAR_RADIUS);
		circles.graphics.drawCircle( posOffset*POSITION_OFFSETS[6],posOffset*POSITION_OFFSETS[7], CHAR_RADIUS);

		
		var minHSize:Number = Math.sqrt(16 * 16 + 16 * 16);
		if (hSize < minHSize) {
			hSize = minHSize;
			size = hSize * 2;
			
		}
		square.graphics.drawRect( -hSize , -hSize, size, size);
		
		selected = false;// = .7;
		
		var nonSelectable:Sprite = new Sprite();
		nonSelectable.mouseChildren = false;
		nonSelectable.mouseEnabled = false;
		
		north = new Sprite();
		mainHolder.addChild(north);
		drawArrow( north.graphics, 0, -hSize , 0, -hSize  - 4, COLORS[0], 10);
		north.addEventListener(MouseEvent.MOUSE_DOWN, onNorthMouseDown, false, 0, true);
		
		drawArrow( mainHolder.graphics, hSize , 0, hSize+4, 0, COLORS[1], 4);
		drawArrow( mainHolder.graphics, 0, hSize , 0, hSize  + 4, COLORS[2], 4);
		drawArrow( mainHolder.graphics, -hSize , 0, -hSize-4, 0, COLORS[3], 4);
		
		addChild(nonSelectable);
		
		arcHolder = new Sprite();
		nonSelectable.addChild(arcHolder);
		
		mainHolder.addChild(charHolder);
	}
	

	
	public function occupyFromDirection(members:Array, direction:int):void {
		var len:int = members.length;
		
		var holder:DisplayObjectContainer = parent;
		if (len > 4) len = 4;
		var baseDir:int = direction * 4;
		for (var i:int = 0; i < len; i++) {
		
			var posIndex:int = DIRECTIONS_POSITIONS[baseDir + i];

			var spr:Sprite = members[i];
			var pt:Point = mainHolder.localToGlobal(new Point(POSITION_OFFSETS[posIndex * 2] * posOffset, POSITION_OFFSETS[posIndex * 2 + 1] * posOffset) );
			spr.x = pt.x;
			spr.y = pt.y;
			spr.rotation =  direction * 90 + mainHolder.rotation;
			holder.addChild(spr);
			
			
		}
	}
	
	
	
	
	private function onNorthMouseDown(e:MouseEvent):void 
	{
		e.stopImmediatePropagation();
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageRotateMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onStageRotateDone);
	}
	
	private function onStageRotateDone(e:MouseEvent):void 
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageRotateMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onStageRotateDone);
	}
	
	private function onStageRotateMove(e:MouseEvent):void 
	{
		mainHolder.rotation = Math.atan2(mouseY, mouseX) * (180 / Math.PI) + 90;
	}
	
	public function addArc(to:BlobNode, direction:int):void 
	{
		arcs.push(new BlobArc(to, direction));
		updateArcs();
	}
	
	public function updateArcs():void 
	{
		arcHolder.graphics.clear();
		var len:int = arcs.length;
		for (var i:int = 0; i < len; i++) {
			var a:BlobArc = arcs[i];
			var to:BlobNode = a.to;
			BlobNode.drawArrow(arcHolder.graphics, 0, 0, to.x-x, to.y-y, COLORS[a.direction],4);
		};
	}
	
	public function updateArcsMutually():void {
		updateArcs();
		var len:int = arcs.length;
		for (var i:int = 0; i < len; i++) {
			var a:BlobArc = arcs[i];
			var to:BlobNode = a.to;
			to.updateArcs();
		};
	}
	
	public function get selected():Boolean 
	{
		return _selected;
	}
	
	public function set selected(value:Boolean):void 
	{
		_selected = value;
			alpha = value ? 1 : .6;
	}
	
	
}



class BlobArc  {
	public var direction:int;
	public var to:BlobNode;
	
	public function BlobArc(to:BlobNode, direction:int) {
		this.direction = direction;
		this.to = to;
	}
}

class Char extends Sprite {
	
	private var mainHolder:Sprite = new Sprite();
	private var _rotation:Number;
	
	public function Char(lbl:String):void {
		addChild(mainHolder);
		var field:TextField = new TextField();
		addChild( field );
		
		field.autoSize = "left";
		field.text = lbl;
		
		
		mainHolder.graphics.beginFill(0, 0);
		mainHolder.graphics.lineStyle(0, 0);
		mainHolder.graphics.drawCircle(0, 0, BlobNode.CHAR_RADIUS);
		mainHolder.graphics.moveTo(0, -BlobNode.CHAR_RADIUS);
		mainHolder.graphics.lineTo(0, -BlobNode.CHAR_RADIUS - 4);
		
		
	}
	
	override public function get rotation():Number 
	{
		return _rotation;
	}
	
	override public function set rotation(value:Number):void 
	{
		_rotation = value;
		mainHolder.rotation = value;
	}
}