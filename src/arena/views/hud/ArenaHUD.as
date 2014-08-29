package arena.views.hud 
{
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.a3d.systems.text.TextBoxChannel;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Hud2D;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import alternativa.types.Float;
	import arena.components.char.ArenaCharacterClass;
	import arena.components.char.CharDefense;
	import arena.components.char.HitFormulas;
	import arena.components.enemy.EnemyAggro;
	import arena.components.enemy.EnemyIdle;
	import arena.components.weapon.Weapon;
	import arena.components.weapon.WeaponSlot;
	import arena.components.weapon.WeaponState;
	import arena.systems.enemy.EnemyAggroSystem;
	import arena.systems.player.IWeaponLOSChecker;
	import ash.core.Entity;
	import assets.fonts.ConsoleFont;
	import assets.fonts.Fontsheet;
	import components.Ellipsoid;
	import components.Health;
	import components.Pos;
	import components.Rot;
	import de.polygonal.motor.geom.primitive.AABB2;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import saboteur.spawners.SaboteurHudAssets;
	import systems.animation.IAnimatable;
	import systems.player.a3d.GladiatorStance;
	import systems.player.PlayerTargetNode;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaHUD  extends SpawnerBundle
	{
		// standard boilerplate
		public var hud:Hud2D;
		
		public var hudMeshSetBase:SpriteMeshSetClonesContainer;
		private var hudMeshMaterial:TextureAtlasMaterial
		private var hudTextureWidth:int;
		private var hudTextureHeight:int;
		
		private var stage:Stage;
	
		private var layoutTop:Object3D = new Object3D();
		private var layoutTopLeft:Object3D = new Object3D();
		private var layoutTopRight:Object3D = new Object3D();
		private var layoutBottom:Object3D = new Object3D();
		private var layoutBottomLeft:Object3D = new Object3D();
		private var layoutBottomRight:Object3D = new Object3D();
		private var layoutLeft:Object3D = new Object3D();
		private var layoutRight:Object3D = new Object3D();
		
		private var visHash:Object = { };
		
		private var fontConsole:Fontsheet;
		private var _textGeometry:Geometry;
		static public const MAX_CHARS:int = 60;  // per draw call
		
		
		private var focalLength:Number;
		private var viewSizeX:Number;
		private var viewSizeY:Number;
		private var camera:Camera3D;
		public function setCamera(camera:Camera3D):void {
			this.camera = camera;
			 onStageResize();
		}
	
		// additional stuff
		
		static public const MSG_END_ACTION_TURN:String = "Hit 'TAB' to end action turn.";
		static public const MSG_START_ACTION_TURN:String = "Press 'K' to start action turn.";
		static public const MSG_END_PHASE:String =  "Hit 'Backspace' to end phase."
		static public const MSG_END_PHASE_FINAL:String =  "No more CP left. Hit 'Backspace' to end phase."
		
		
		private var arrowMarkers:Vector.<SpriteMeshSetClone> = new Vector.<SpriteMeshSetClone>();
		private var arrowZOffset:Number = 64;
		private var maxArrowScale:Number = 2;
		private var minArrowScale:Number = .75;
		
		
		private var vec3:Vector3D = new Vector3D();
		private var projectedPoint:Vector3D = new Vector3D();
	//	/*
		
		private var visibleArrowMarkers:int = 0;
		private var visibleArrowMarkerPoints:Vector.<Number> = new Vector.<Number>();
		private var visibleArrowTargets:Vector.<Object3D>;
		private var _movementBar:SpriteMeshSetClone;
		private var _movementBarSkin:SpriteMeshSetClone;
		static private const MOVEMENT_BAR_SCALE:Number = 180;
		static private const TARGET_INFO_CMD_Y:Number = 130;
		static private const TARGET_INFO_Y:Number = 130-55;
		
		
		private var _textTurnInfo:FontSettings;
		private var _cpMeter:Array;
		private var _cpMeterHolder:Object3D;
		private var _textTurnInfoMini:FontSettings;
		private var _textTargetMode:FontSettings;
		
		private var _targetInfo:TextBoxChannel;
		private var _actionChoicesBox:TextBoxChannel;
		private var _curCharInfo:TextBoxChannel;
		private var _msgLogInfo:TextBoxChannel;
		
		private var _stanceCharInfo:TextBoxChannel;
		
		private var _displayChar:Entity;
		
		public static const UNIT_METER_SCALE:Number = 0.01905;  // based off Half-life dimensions, a unit in meters, which is 19.05mm (around 2 cm)
		public static const METER_UNIT_SCALE:Number = 1 / UNIT_METER_SCALE; 
		
		static public const EVASION_UNDER_COVER_BONUS:Number = .3;
		static public const BEING_UNDER_COVER_BONUS:Number = .75;
		
		private static function getWeaponModeLabels():Dictionary {
			var arr:Dictionary = new Dictionary();
			arr[Weapon.FIREMODE_SWING] = "Swing Weapon";
			arr[Weapon.FIREMODE_THRUST] = "Thrust Weapon";
			arr[Weapon.FIREMODE_TRAJECTORY] = "Launch Projectile";
			arr[Weapon.FIREMODE_VELOCITY] = "Fire Projectile";
			arr[Weapon.FIREMODE_STRIKE] = "Strike Weapon";
			arr[Weapon.FIREMODE_RAY] = "Shoot";
			return arr;
		}
		private static var WEAPON_MODE_LABELS:Dictionary = getWeaponModeLabels();
/*
Components for:
----------------
WeaponSlots
*/
 
		public var weaponLOSCheck:IWeaponLOSChecker = new DummyWeaponLOSCheck();
		public var arcContainer:Object3D;
	
		public function ArenaHUD(stage:Stage) 
		{
			hud = new Hud2D();
			
			
			ASSETS = [SaboteurHudAssets];
			this.stage = stage;
			super();
		}
		
		
		private var _state:String = "";
		
		public function setState(string:String):void 
		{
			if (_state === string) return;
			
			var arr:Array = visHash[_state];
			if (arr) hideList(arr);
			
			
			_state = string;
			arr =  visHash[string];
			if (arr) showList(arr);
		}
		
		private function hide(hudItem:*):void {
			if (hudItem is MeshSetClone) {
				if (hudItem.index >= 0) hudMeshSetBase.removeClone(hudItem);
			}
			else if (hudItem is Array) {
				hideList(hudItem);
			}
			else {
				hudItem.visible = false;
			
			}
		}
		private function show(hudItem:*):void {
			if (hudItem is MeshSetClone) {
				if (hudItem.index < 0) hudMeshSetBase.addClone(hudItem);
			}
			else if (hudItem is Array) {
				showList(hudItem);
			}
			else {
				hudItem.visible = true;
			}
		}
		
		private function hideList(arr:Array):void {
			var i:int = arr.length;
			while (--i > -1) {
				hide(arr[i]);
			}
		}
		
		private function showList(arr:Array):void {
			var i:int = arr["showLen"] != null ? arr["showLen"] :  arr.length;
		
			while (--i > -1) {
				show(arr[i]);
			}
		}
		
		
		
		private function onStageResize(e:Event=null):void 
		{
			if (camera != null) {
				viewSizeX = camera.view._width * 0.5;
				viewSizeY = camera.view._height * 0.5;
				focalLength = Math.sqrt(viewSizeX * viewSizeX + viewSizeY * viewSizeY) / Math.tan(camera.fov * 0.5);
			}
			
			var sh:Number = camera != null ? camera.view.height : stage.stageHeight;
			var sw:Number = camera != null ? camera.view.width :  stage.stageWidth;
			var halfWidth:Number = sw * .5;
			var halfHeight:Number = sh * .5;
			
			layoutTop._y = -halfHeight;
			layoutTop.transformChanged = true;
			
			layoutBottom._y =halfHeight;
			layoutBottom.transformChanged = true;
			
			layoutLeft._x =-halfWidth;
			layoutLeft.transformChanged = true;
			
			layoutRight._x =halfWidth;
			layoutRight.transformChanged = true;
			
			
			layoutTopLeft._x = -halfWidth;
			layoutTopLeft._y = -halfHeight;
			layoutTopLeft.transformChanged = true;
			
			layoutTopRight._x = halfWidth;
			layoutTopRight._y = -halfHeight;
			layoutTopRight.transformChanged = true;
			
			layoutBottomLeft._x = -halfWidth;
			layoutBottomLeft._y = halfHeight;
			layoutBottomLeft.transformChanged = true;
			
			layoutBottomRight._x = halfWidth;
			layoutBottomRight._y = halfHeight;
			layoutBottomRight.transformChanged = true;

		}
		
		override protected function init():void {
		
			
			// layout
			hud.addChild(layoutTop);
			hud.addChild(layoutBottom);
			hud.addChild(layoutLeft);
			hud.addChild(layoutRight);
			hud.addChild(layoutBottomRight);
			hud.addChild(layoutBottomLeft);
			hud.addChild(layoutTopRight);
			hud.addChild(layoutTopLeft);
			
			
			// setup basic fonts
			fontConsole = new ConsoleFont();
			
		//	stage.addChild( new Bitmap( fontConsole.bmpResource.data) );
			fontConsole.bmpResource.upload(context3D);
			//chatTextInput.glyphRange = fontConsole.fontV._glyphRange;
			_textGeometry  = SpriteGeometryUtil.createNormalizedSpriteGeometry(MAX_CHARS, 0, 1, 1, 0, 0, 2);
			_textGeometry.upload(context3D);
			
			
			// setup basic sprite sheet
			var hudBmpData:BitmapData = new SaboteurHudAssets.$_SHEET().bitmapData;
			hudTextureWidth = hudBmpData.width;
			hudTextureHeight = hudBmpData.height;
			var hudResource:BitmapTextureResource = new BitmapTextureResource( hudBmpData );
			hudResource.upload(context3D);
			
			hudMeshMaterial = new TextureAtlasMaterial(hudResource);// null, 1);
			hudMeshMaterial.alphaThreshold = .8;
			hudMeshMaterial.flags = TextureAtlasMaterial.FLAG_MIPNONE;  // | TextureAtlasMaterial.FLAG_PIXEL_NEAREST
			
			hudMeshSetBase =  new SpriteMeshSetClonesContainer(hudMeshMaterial, 0 );
			hudMeshSetBase.objectRenderPriority = Renderer.NEXT_LAYER;
			hudMeshSetBase.name = "hud";
			hudMeshSetBase.geometry.upload(context3D);
			
			hud.addChild(hudMeshSetBase);
				
			setupHUD();
			
			 super.init();
			 
			 stage.addEventListener(Event.RESIZE, onStageResize);
			 onStageResize();
		}
		
		
		private function registerVisState(state:String, instance:*):void {
			var arr:Array = visHash[state];
			if (arr == null) {
				arr = [];
				visHash[state] = arr;
			}
			
			arr.push(instance);
		}
		
		private function registerVisStatesOfTextBox(state:String, textBoxChannel:TextBoxChannel):void {
			var arr:Vector.<FontSettings> = textBoxChannel.styles
			var i:int = arr.length;
			while (--i > -1) {
				registerVisState(state, arr[i].spriteSet);
			}
			
			
		}
		
		
		

		
		private function getSprite(px:Number, py:Number, width:Number, height:Number, x:Number = 0, y:Number = 0, parenter:Object3D=null):SpriteMeshSetClone {
			
			var spr:SpriteMeshSetClone = hudMeshSetBase.getNewSprite();

			
			spr.u = px / hudTextureWidth;
			spr.v = py / hudTextureHeight;
			spr.uw = width / hudTextureWidth;
			spr.vw =  height / hudTextureHeight;
			
			
			spr.root._x = x;
			spr.root._y = y;
			spr.root._scaleX = width;
			spr.root._scaleY = height;
			

			spr.root._rotationX = Math.PI;
			
			spr.root._parent = parenter;
			
			return spr;
		}

		private function addSprite(px:Number, py:Number, width:Number, height:Number, x:Number = 0, y:Number = 0, parenter:Object3D=null):SpriteMeshSetClone {
			var spr:SpriteMeshSetClone = getSprite(px, py, width, height, x, y, parenter);
			
			hudMeshSetBase.addClone(spr);
			
			return spr;
		}
		
		private function getSpriteMeshIconMeter(amt:int, px:Number, py:Number, width:Number, height:Number, existingArray:Array=null):Array {
			var arr:Array = existingArray ? existingArray :  [];
			var parenter:Object3D = existingArray ? existingArray["parenter"] : new Object3D();
		
			arr["px"] = px;
			arr["py"] = py;
			arr["parenter"] = parenter;
			arr["width"] = width;
			arr["height"] = height;
			
			for (var i:int = 0; i < amt; i++) {
				if (i < arr.length) continue;
				var spr:MeshSetClone;
				arr[i] = spr  = getSprite(px, py, width, height, 0, 0, parenter);
				spr.root._x = width * i;
			}
			return arr;
		}
		
		private function adjustSpriteMeshIconMeter(amt:int, arr:Array):void {
			
			if (amt > arr.length) {
				getSpriteMeshIconMeter(amt, arr["px"], arr["py"], arr["width"], arr["height"], arr);
				
			}
			
			arr["showLen"] = amt;
			
			var spr:MeshSetClone;
			var i:int;
			for (i= 0; i < amt; i++) {
				spr = arr[i];
			
				if (spr.index < 0 ) hudMeshSetBase.addClone( spr);
			}
			var len:int = arr.length;
			for (i = amt; i < len; i++) {
				spr = arr[i];
				if (spr.index >= 0 ) hudMeshSetBase.removeClone( spr);
			}
		}
		
				
		private function getNewFontMaterial(color:uint):MaskColorAtlasMaterial {
			var mat:MaskColorAtlasMaterial =  new MaskColorAtlasMaterial(fontConsole.bmpResource);
			mat.transparentPass = false;
			mat.color = color;
			mat.alphaThreshold = .8;
			mat.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		private function getNewDefaultFontMaterial(color:uint):TextureAtlasMaterial {
			var mat:TextureAtlasMaterial =  new TextureAtlasMaterial(fontConsole.bmpResource);
			//mat.transparentPass = false;
			mat.alphaThreshold =.8;
			mat.flags = (TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		
		private function getNewTextSpriteSet(estimatedMaxChars:int, material:Material, geom:Geometry):SpriteSet {
			var spr:SpriteSet = new SpriteSet(0, true, material, fontConsole.bmpResource.data.width, fontConsole.bmpResource.data.height, estimatedMaxChars, 2 );
			
			return spr;
		}
		
		private function getNewFontSettings(fontSheet:Fontsheet, fontMat:Material, estimatedAmt:int):FontSettings {
			return new FontSettings( fontConsole, fontMat, getNewTextSpriteSet(estimatedAmt, fontMat, _textGeometry ));
		}
		
		
		// END BOILERPLATE
		
		private function setupHUD():void 
		{
			var spr:SpriteMeshSetClone;
			
			// crosshair
			spr = addSprite(281, 259, 21, 20);
			registerVisState("thirdPerson",spr);
			
			
			
			// movement meter
			_movementBar = spr = addSprite( 392, 19, 42, 20, 0, -20, layoutBottom);
			spr.root._scaleX = MOVEMENT_BAR_SCALE;
			spr.root._scaleY = 12;
			//spr.root._z = 20;
		
			// movement meter skin
			 spr = _movementBarSkin = addSprite(0, 0, 32, 256, 0, -20, layoutBottom);
			spr.root._scaleX *= .75;
			spr.root._scaleY *= .75;
			spr.root._rotationZ = Math.PI * .5;
			//spr.root._z = 20;
			
			// msg above movement meter
			
			

			var fontMat:Material = getNewDefaultFontMaterial(0xDDEEAA);
			
			
			// target info + options from  top left, or a bit lower after cp in cmd mode
			_targetInfo = new TextBoxChannel( new <FontSettings>[ getNewFontSettings(fontConsole, fontMat, 30) ], 5, -1, 3); 
			_targetInfo.width = 200;
			_targetInfo.addToContainer(layoutTopLeft);
			_targetInfo.moveTo(5, TARGET_INFO_CMD_Y);
				
			/*
			_targetInfo.appendMessage("1. ---------");
			_targetInfo.appendMessage(" ");
			_targetInfo.appendMessage("2. ---------");
			_targetInfo.appendMessage("3. ---------");
		
			_targetInfo.drawNow();
			*/
			//layoutTopLeft.addChild(_targetInfo );
			
			_actionChoicesBox = new TextBoxChannel( new <FontSettings>[ getNewFontSettings(fontConsole, fontMat, 30) ], 5, -1, 3); 
			_actionChoicesBox.addToContainer(layoutTopLeft);
			registerVisStatesOfTextBox("thirdPerson", _actionChoicesBox);
			_actionChoicesBox.styles[0].spriteSet.alwaysOnTop = true;
			
			///*
			_actionChoicesBox.appendMessage("F - Attack now");
			

			_actionChoicesBox.drawNow();
			//*/
			_actionChoicesBox.moveTo(200+20, _actionChoicesBox._heightOffset+ 40);
			
			// Command points and Turn info on top center
			_textTurnInfo = new FontSettings( fontConsole, fontMat, getNewTextSpriteSet(50, fontMat, _textGeometry), "commandPoints" );
		//	_textTurnInfo.writeFinalData("Hello world", 0,0,800, false );
			_textTurnInfo.spriteSet._x = 4;	
			_textTurnInfo.spriteSet._y = 15;// -44;	
			layoutTopLeft.addChild(_textTurnInfo.spriteSet);
			//registerVisState("commander", _textTurnInfo.spriteSet); 
			

			
			_textTurnInfoMini =  new FontSettings( fontConsole, fontMat, getNewTextSpriteSet(50, fontMat, _textGeometry), "commandPointsMini" );
			_textTurnInfoMini.spriteSet._x = 5;	
			_textTurnInfoMini.spriteSet._y = 110;	
			//_textTurnInfoMini.hardSetUVOffsetIndices(1);
		//	_textTurnInfoMini.spriteSet.alwaysOnTop = true;
			//_textTurnInfoMini.spriteSet.z -= .2;
			layoutTopLeft.addChild(_textTurnInfoMini.spriteSet);
			registerVisState("thirdPerson", _textTurnInfoMini.spriteSet);
			
			_textTargetMode =  new FontSettings( fontConsole, fontMat, getNewTextSpriteSet(50, fontMat, _textGeometry), "commandPointsMini" );
			//_textTargetMode.spriteSet._x = 8;	
			_textTargetMode.spriteSet._y = -20;// -40;	
			_textTargetMode.spriteSet.alwaysOnTop = true;
			//_textTargetMode.spriteSet.z -= .2;
			layoutBottom.addChild(_textTargetMode.spriteSet);
			//_textTargetMode.writeFinalData(MSG_END_ACTION_TURN, 0,0,2000,true);
		//	registerVisState("thirdPerson", _textTargetMode.spriteSet);
			
			
			
			
			_cpMeter = getSpriteMeshIconMeter(5, 32, 256, 16, 16);
			_cpMeterHolder = _cpMeter["parenter"];
			//registerVisState("commander", _cpMeter); 
			
			
			// Message log on bottom left
			_msgLogInfo = new TextBoxChannel( new <FontSettings>[ getNewFontSettings(fontConsole, fontMat, 30) ], 8, -1, 3); 
			registerVisStatesOfTextBox("thirdPerson", _msgLogInfo);
			_msgLogInfo.moveTo(5, -82);
			_msgLogInfo.addToContainer(layoutBottomLeft);
			/*
			_msgLogInfo.appendMessage("1. ---------");
			_msgLogInfo.appendMessage("2. ---------");
			_msgLogInfo.appendMessage("3. ---------");
			_msgLogInfo.appendMessage("4. ---------");
			_msgLogInfo.appendMessage("6. ---------");
			_msgLogInfo.appendMessage("7. ---------");
			_msgLogInfo.appendMessage("8. ---------");
			_msgLogInfo.drawNow();
			*/
			
			
			// stance key cues on bottom left
			_stanceCharInfo = new TextBoxChannel( new <FontSettings>[ getNewFontSettings(fontConsole, fontMat, 30) ], 5, -1, 3); 
			_stanceCharInfo.addToContainer(layoutBottomLeft);
			registerVisStatesOfTextBox("thirdPerson", _stanceCharInfo);
			setStance(0);
		
			_stanceCharInfo.moveTo(5, 0);
			
			// your stats on bottom right
			_curCharInfo = new TextBoxChannel( new <FontSettings>[ getNewFontSettings(fontConsole, fontMat, 30) ], 6, -1, 3); 
			_curCharInfo.centered = true;
			_curCharInfo.width = 160;
			_curCharInfo.addToContainer(layoutBottomRight);
			
			_curCharInfo.moveTo( -92, 0);
		

		}
		
	
		
		public function setStance(stance:int):void {
			_stanceCharInfo.clearAll();
				
			if (stance ===0) {
				_stanceCharInfo.appendSpanTagMessage('<span u="2">Standing</span>');
				_stanceCharInfo.appendMessage("Q/Ctrl - Cautious");
		
			}
			else if (stance === 1) {
				if (!_targetMode) _stanceCharInfo.appendMessage("Q - Standing");
				_stanceCharInfo.appendSpanTagMessage('<span u="2">Cautious</span>');
				_stanceCharInfo.appendMessage("Ctrl - Crouched");
			}
			else {
				
				_stanceCharInfo.appendMessage("Q/Ctrl - Cautious");
				_stanceCharInfo.appendSpanTagMessage('<span u="2">Crouched</span>');
			}
			_stanceCharInfo.drawNow();
				
		}
		
		

		
		
		public function showArrowMarkers(targets:Vector.<Object3D>):void {
			var len:int = targets.length;
			visibleArrowTargets = targets;
			visibleArrowMarkers = len;

			var hx:Number = camera.view.width * .5;
			var hy:Number = camera.view.height * .5;
			var t:Transform3D = camera.globalToLocalTransform;
			
			for (var i:int = 0; i < len; i++) {
				var arrowMarker:SpriteMeshSetClone;
				if (i >= arrowMarkers.length) {
					arrowMarkers[i] = addSprite( 2, 256, 16, 16, 0, -16) ;
				}
				arrowMarker  = arrowMarkers[i];
			
				
				if (arrowMarker.index < 0) hudMeshSetBase.addClone(arrowMarker);
			}
			
			i = len;
			len = arrowMarkers.length;
			while ( i  < len) {
				arrowMarker = arrowMarkers[i];
				if (arrowMarker.index >= 0) hudMeshSetBase.removeClone( arrowMarker );
				i++;
			}
			
			
		}
	//	*/
	
	
		public function clearArrows():void {
			for (var i:int = 0; i < visibleArrowMarkers; i++) {
					hudMeshSetBase.removeClone( arrowMarkers[i] );
		
					
				}
			 visibleArrowMarkers = 0;
			
		}
		
		private function toMeters(val:Number):Number {
			return int(val * UNIT_METER_SCALE * 100) / 100;
		}
		
		private var _stars:Boolean = false;
		private var _cpInfo:String;
		
		public function hideStars():void {
			_stars = false;
			hideList(_cpMeter);
			_textTurnInfo.spriteSet.visible = false;
			
			_targetInfo.moveTo(5, TARGET_INFO_Y);
			_textTargetMode.hardSetUVOffsetIndices( 0);
			_textTargetMode.writeFinalData(_cpInfo, 0, 0, 2000, true);
			//_textTargetMode.writeFinalData("Press 'Z' - target mode", 0, 0, 2000, true);
		
			///*
			setChar(_displayChar);
		//	*/
		
		setTargetChar(null);
		
		}
		
		private var _charWeaponEnabled:Boolean = true;
		public var playerWeaponModeForAttack:uint = Weapon.FIREMODE_THRUST;
		public var enemyWeaponModeForAttack:uint = Weapon.FIREMODE_THRUST;
		
		public function setChar(ent:Entity):void {
			_displayChar = ent;
			_charWeaponEnabled = true;
			
			_curCharInfo.clearAll();
			if (ent == null) {
				_curCharInfo.drawNow();
				_curCharPos = null;
				lastCharPosition.x = Number.MAX_VALUE;
				lastCharPosition.y = Number.MAX_VALUE;
				lastCharPosition.z = Number.MAX_VALUE;
				return;
			}
			
			_curCharPos = ent.get(Pos) as Pos;
			
			lastCharPosition.x = _curCharPos.x;
			lastCharPosition.y = _curCharPos.y;
			lastCharPosition.z = _curCharPos.z;
			
			updateCharInfo();
			
			var gSa:GladiatorStance = ent.get(IAnimatable) as GladiatorStance;
			setStance(gSa.stance);
		}
		
		private function updateCharInfo():void 
		{
			var ent:Entity = _displayChar;
				var health:Health = ent.get(Health) as Health;
			var obj:Object3D = ent.get(Object3D) as Object3D;
		
			
			var charClass:ArenaCharacterClass = ent.get(ArenaCharacterClass) as ArenaCharacterClass;
			var weapon:Weapon = getWeapon(ent);
			var weaponSlots:WeaponSlot = ent.get(WeaponSlot) as WeaponSlot;
			//ent.get(ArenaChar

			
			_curCharInfo.appendMessage("Name: "+obj.name);
			_curCharInfo.appendMessage("HP: "+(health.hp >= 0 ? health.hp : 0)+"/"+health.maxHP);
			_curCharInfo.appendMessage("Class: " + charClass.name);
			var rangeInMeters:Number = int(weapon.range * UNIT_METER_SCALE * 100) / 100;
			_curCharInfo.appendMessage((_charWeaponEnabled ? "Attack: " : "" )+weapon.name+" ("+rangeInMeters+"m)");
			_curCharInfo.appendMessage(weaponSlots ? "'C' to cycle attack modes. (1/" + weaponSlots.slots.length + ")" : _stars ? "Press 'TAB' to cycle character." : " " ); //"'C' to switch attack mode. (1/2)" //"Attack completed."
			if (!_charWeaponEnabled && !_stars) _curCharInfo.appendSpanTagMessage('<span u="2">Done!</span>');
			 _curCharInfo.appendMessage(_stars ?  numStars > 0 ?  MSG_START_ACTION_TURN : " " : MSG_END_ACTION_TURN);
			_curCharInfo.drawNow();
		}
		
		private var _gotTargetInRange:Boolean = false;
		private var _curCharPos:Pos;
		private var _targetNode:PlayerTargetNode;
		private var _targetMode:Boolean;
		
		private function getRangeToTarget():Number {
			var dx:Number = _curCharPos.x - _targetNode.pos.x;
			var dy:Number = _curCharPos.y - _targetNode.pos.y;
			var dz:Number = _curCharPos.z - _targetNode.pos.z;
			var dist:Number = Math.sqrt(dx * dx + dy * dy + dz * dz);
			var distM:Number = 1 / dist;
			dx *= distM*_targetNode.ellipsoid.x;
			dy *= distM*_targetNode.ellipsoid.y;
			dz *= distM*_targetNode.ellipsoid.z;
			return  dist - Math.sqrt(dx*dx+dy*dy+dz*dz);
		}
		
		private var _lastTargetNode:PlayerTargetNode;
		public function setTargetChar(node:PlayerTargetNode):void {
			_targetNode = node;
			_targetInfo.clearAll();
			if (node == null) {
				_gotTargetInRange = false;
				_gotTargetLOS = false;
				_targetInfo.drawNow();
				validateTargetInRange();
				return;
				
			}
			_lastTargetNode = node;
			
			var ent:Entity = node.entity;
			var obj:Object3D = node.obj;
			
			var health:Health = ent.get(Health) as Health;
			if (health.hp <= 0) {
				
				return;
			}
			var charClass:ArenaCharacterClass = ent.get(ArenaCharacterClass) as ArenaCharacterClass;
			var weapon:Weapon = getWeapon(ent);
			var pos:Pos = node.pos;

			_gotTargetLOS = false;
			
			if (_curCharPos) {
				_gotTargetInRange =  getRangeToTarget() <= weapon.range;
				if (_gotTargetInRange) {
					_gotTargetLOS = weaponLOSCheck == null || checkLOS(_displayChar, _displayChar.get(Weapon) as Weapon, node.entity);
				}
			}
			else {
			
				_gotTargetInRange =  false; 
			
			}
			
			if (_gotTargetInRange && _gotTargetLOS && !_stars) {
				updateTargetChoices();
				
			}
			
		
			
			_targetInfo.appendMessage("Name: "+obj.name);
			_targetInfo.appendMessage("HP: "+health.hp+"/"+health.maxHP);
			_targetInfo.appendMessage("Class: " + charClass.name);
			_curCharInfo.appendMessage("Carrying: "+weapon.name);
			_targetInfo.drawNow();
			
			validateTargetInRange();
		}
		
		private function checkLOS(entA:Entity, entAWeapon:Weapon, entB:Entity):Boolean 
		{
			
			return weaponLOSCheck.validateWeaponLOS( entA.get(Pos) as Pos, entAWeapon.sideOffset, entAWeapon.heightOffset, entB.get(Pos) as Pos, entB.get(Ellipsoid) as Ellipsoid );
		}
		
		private function checkCoverBlockLOS(entA:Entity, entB:Entity):Boolean 
		{
	
			return entA.has(EnemyIdle) ? false :   !weaponLOSCheck.validateWeaponLOS( entA.get(Pos) as Pos, (entB.get(Ellipsoid) as Ellipsoid ).x, 0, entB.get(Pos) as Pos, entB.get(Ellipsoid) as Ellipsoid )
			 ||  !weaponLOSCheck.validateWeaponLOS( entA.get(Pos) as Pos, -(entB.get(Ellipsoid) as Ellipsoid ).x, 0, entB.get(Pos) as Pos, entB.get(Ellipsoid) as Ellipsoid );
		}
		
		
		
		private var choices:Array = [];
		private var choicesWeapons:Array = [];
		
		private function updateTargetChoices():void { // TODO: determine best choice (percChanceToHit|damage) and use default F key for choice
			
			_actionChoicesBox.clearAll();
				
			// ROLLING
			var hitPercResult:Number;
			var critPercResult:Number;
			var bestChoiceIndex:int = 0;
			var bestDamage:int = 0;
			var bestPercChanceToHit:Number = 0;
			
			
			var rangeToTarget:Number = getRangeToTarget();
			
			var count:int = 0;
			for (var playerWeapon:Weapon =  _displayChar.get(Weapon) as Weapon; playerWeapon != null; playerWeapon = playerWeapon.nextFireMode) {  // start loop
			
			if (playerWeapon.range < rangeToTarget || !checkLOS(_displayChar, playerWeapon, _targetNode.entity)) {
				continue;
			}
			var aggro:EnemyAggro = _targetNode.entity.get(EnemyAggro) as EnemyAggro;
			var aggroing:Boolean = false;
			var checkingLOS:Boolean = false;
			aggroing = aggro == null || aggro.flag != 1 ? false : (checkingLOS  = aggro!=null) && checkLOS(_targetNode.entity, (_targetNode.entity.get(WeaponState) as WeaponState).fireMode, _displayChar);
		//	if (aggro != null && aggro.flag == 2) throw new Error("STILL WAITING");
			if (!aggroing) {
				hitPercResult = HitFormulas.getPercChanceToHitDefenderMethod(playerWeapon)( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid );
				if (checkingLOS || (aggro && aggro.flag == -1) ) hitPercResult *= EVASION_UNDER_COVER_BONUS
				else hitPercResult *= checkCoverBlockLOS( _targetNode.entity, _displayChar ) ? BEING_UNDER_COVER_BONUS : 1;
				critPercResult= HitFormulas.getPercChanceToCritDefender(_curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense,_targetNode.entity.get(Ellipsoid) as Ellipsoid );
				
			}
			else {
				var aggroWeapon:Weapon =  (_targetNode.entity.get(WeaponState) as WeaponState).fireMode;
				aggroing = true;

				//posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, healthA:Health, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState)
				hitPercResult = HitFormulas.getPercChanceToHitAttackerMethod(playerWeapon)(
					_curCharPos,
					_displayChar.get(Rot) as Rot, 
					_displayChar.get(CharDefense) as CharDefense, 
					_displayChar.get(Ellipsoid) as Ellipsoid, 
					playerWeapon, 
					_displayChar.get(Health) as Health, 
					_targetNode.entity.get(Pos) as Pos, 
					_targetNode.entity.get(Rot) as Rot, 
					_targetNode.entity.get(CharDefense) as CharDefense, 
					_targetNode.entity.get(Ellipsoid) as Ellipsoid, 
					aggroWeapon,
					_targetNode.entity.get(WeaponState) as WeaponState);
					
					//posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState
					critPercResult = HitFormulas.getPercChanceToCritAttacker( 
						_curCharPos,
						_displayChar.get(Rot) as Rot, 
						_displayChar.get(CharDefense) as CharDefense, 
						_displayChar.get(Ellipsoid) as Ellipsoid, 
						playerWeapon, 
						_targetNode.entity.get(Pos) as Pos, 
						_targetNode.entity.get(Rot) as Rot, 
						_targetNode.entity.get(CharDefense) as CharDefense, 
						_targetNode.entity.get(Ellipsoid) as Ellipsoid, 
						aggroWeapon,
						_targetNode.entity.get(WeaponState) as WeaponState);
			}
			
			
			
			
			hitPercResult = Math.round(hitPercResult);
			critPercResult = Math.round(critPercResult);
			
			var targetHP:Health = _targetNode.entity.get(Health) as Health;
			
			var sampleDmg:int = HitFormulas.rollDamageForWeapon(playerWeapon);
			var numHits:int = Math.ceil(targetHP.hp / sampleDmg);
			var numCritHits:int = Math.ceil(targetHP.hp / (sampleDmg*3));
			
			var showLabels:Boolean = false;
		
			//_actionChoicesBox.appendMessage("::");
			if (hitPercResult > bestPercChanceToHit || (hitPercResult == bestPercChanceToHit && sampleDmg > bestDamage) ) {
				bestChoiceIndex = count;
				bestPercChanceToHit = hitPercResult;
				bestDamage = sampleDmg;
				_bestChoiceIndex = count;
			}
			
			
			choicesWeapons[count] = playerWeapon;
			choices[count ]  = (count + 1) + ' - ' + (playerWeapon.fireModeLabel || WEAPON_MODE_LABELS[playerWeapon.fireMode] ) + ' (<span u="2">' + hitPercResult + '%</span>' + (showLabels ? " hit" : "") + ' | <span u="1">' + critPercResult + '%</span>' + (showLabels ? ' critical' : '') + ')' + '  ~(<span u="2">' + numHits + '</span>|<span u="1">' + numCritHits + '</span>)' + (aggroing ? "*" : "");
				count++;
			}	// end loop
			
			for (var i:int = 0; i < count; i++) {
				_actionChoicesBox.appendSpanTagMessage(choices[i] + (i=== bestChoiceIndex ? " [F]" : "") );
			}
			
			choices.length = count;
		
			_actionChoicesBox.drawNow();
			_actionChoicesBox.moveTo(200+20, 20+count*20);
		}
		
		private function checkTargetInRange():Boolean { 
			var gotTargetInRange:Boolean = false;
			var gotTargetLOS:Boolean = false;
			if (_displayChar == null) return false;
			for (var playerWeapon:Weapon = _displayChar.get(Weapon) as Weapon; playerWeapon != null; playerWeapon = playerWeapon.nextFireMode) {
				if ( _targetNode && _curCharPos) {
					
					gotTargetInRange = getRangeToTarget() <= playerWeapon.range;
					gotTargetLOS = false;
					if (gotTargetInRange) {
						gotTargetLOS = weaponLOSCheck == null || checkLOS(_displayChar, playerWeapon, _targetNode.entity);
						if (gotTargetLOS) {
							break;
						}
					}
				}
				else {
				//	gotTargetLOS = true;
					//gotTargetInRange =  true;  //TODO: subjected to weapon condition
					gotTargetLOS = false;
					gotTargetInRange =  false;  //TODO: subjected to weapon condition

				}
			}
			
			if (gotTargetInRange != _gotTargetInRange || gotTargetLOS != _gotTargetLOS) {
				_gotTargetInRange = gotTargetInRange
				_gotTargetLOS = gotTargetLOS;
				validateTargetInRange();
				return true;
			}
			return false;
		}
		public function setTargetMode(val:Boolean):void {
			_targetMode = val;
			if (arcContainer) arcContainer.visible = !val;
			if (val) {
				_textTargetMode.writeFinalData("Z - exit target mode", 0, 0, 2000, true);
				 _textTurnInfoMini.writeFinalData("", 0, 0, 300, false);
				 checkTargetModeOptions();
				 if (_targetNode) {
					
					 updateTargetChoices(); // setTargetChar(_targetNode);
				 }
			}
			else  {
				_textTargetMode.writeFinalData(_cpInfo, 0, 0, 2000, true);
				
			}
			validateTargetInRange();
		}
		
		private function checkTargetModeOptions():void 
		{
			
		}
		
		private function validateTargetInRange():void 
		{
			//var hitPercResult:Number = NaN;
			//var critPercResult:Number = NaN;
			
			//if (_targetNode && _curCharPos) {
			//	hitPercResult= HitFormulas.getPercChanceToHitDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  _targetNode.entity.get(Weapon) as Weapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense,_targetNode.entity.get(Ellipsoid) as Ellipsoid );
			//	critPercResult= HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  _targetNode.entity.get(Weapon) as Weapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense,_targetNode.entity.get(Ellipsoid) as Ellipsoid );
			//	hitPercResult = Math.round(hitPercResult);
			//	critPercResult = Math.round(critPercResult);
			//}
			
			_actionChoicesBox.styles[0].spriteSet.visible = _targetMode && _gotTargetInRange && _gotTargetLOS &&  _targetNode;
			if (_targetMode || !_targetNode) {  // show valid target options if within range
				_textTurnInfoMini.writeFinalData(_targetNode && !(_gotTargetInRange && _gotTargetLOS) && _charWeaponEnabled ? _gotTargetInRange ? "No Line of Fire!" : "out of range: " + toMeters(getRangeToTarget()) + "m"  : "");
				if (_targetMode) {
					checkTargetModeOptions();
				}
				return;
			}
			
			
			
			_textTurnInfoMini.writeFinalData(_gotTargetInRange  ?  _charWeaponEnabled ? _gotTargetLOS ?  "Z - target mode" : "No Line of Fire!" :  _charWeaponEnabled ? "out of range: "+toMeters(getRangeToTarget())+"m"  : "" : "" ,0,0,300,false);
		}
		
		public function newPhase():void {
			show( _movementBar );
			show(_movementBarSkin);
			_textTargetMode.hardSetUVOffsetIndices(0);
			_textTargetMode.writeFinalData(MSG_END_PHASE, 0,0,2000,true);
		}
		public function showStars():void {
			_stars = true;
			clearLog();
			showList(_cpMeter);
			_textTurnInfo.spriteSet.visible = true;
			
			var noMoreStars:Boolean = numStars == 0;
			_textTargetMode.hardSetUVOffsetIndices(noMoreStars ? 1 : 0);
				_textTargetMode.writeFinalData(!noMoreStars ? MSG_END_PHASE : MSG_END_PHASE_FINAL, 0,0,2000,true);
			
			if (noMoreStars) {
				hide( _movementBar );
				hide(_movementBarSkin);
			}
			_targetInfo.moveTo(5, TARGET_INFO_CMD_Y);
		}
		
		public function clearLog():void 
		{
			_msgLogInfo.clearAll();
			_msgLogInfo.drawNow();
		}
		
		private function get numStars():int 
		{
			return _cpMeter["showLen"];
		}
		
		private var lastCharPosition:Vector3D = new Vector3D(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
		private var positionChangeThreshold:Number = 1;
		
		
	
		public function update():void {
			var len:int;
		//	if (_gotTargetInRange && !targetNode) throw new Error("A");
			// check target in range
			var alreadyValidated:Boolean = checkTargetInRange();
		
			if (!alreadyValidated && _targetNode && !(_gotTargetInRange&&_gotTargetLOS) && _curCharPos) {
				var dx:Number = _curCharPos.x -lastCharPosition.x;
				var dy:Number = _curCharPos.y - lastCharPosition.y;
				var dz:Number = _curCharPos.z- lastCharPosition.z;
				if ( dx * dx + dy * dy + dz * dz  >= positionChangeThreshold) {
					
					validateTargetInRange();
					
					lastCharPosition.x = _curCharPos.x;
					lastCharPosition.y = _curCharPos.y;
					lastCharPosition.z = _curCharPos.z;
					
				}
			}
			
		
			// update arrows
			
			//if ( camera.transformChanged ) {
				
				var t:Transform3D = camera.globalToLocalTransform;
				len = visibleArrowMarkers;
				
				for (var i:int = 0; i < len; i++) {
					var arrowMarker:SpriteMeshSetClone  = arrowMarkers[i];
					var targ:Object3D = visibleArrowTargets[i];
					vec3.x = targ._x;
					vec3.y = targ._y;
					vec3.z = targ._z +  arrowZOffset;
					projectedPoint.x = t.a * vec3.x + t.b * vec3.y + t.c * vec3.z + t.d;
					projectedPoint.y = t.e * vec3.x + t.f * vec3.y + t.g * vec3.z + t.h;
					projectedPoint.z = t.i * vec3.x + t.j * vec3.y + t.k * vec3.z + t.l;
					var scaleRatio:Number = focalLength / projectedPoint.z;
					projectedPoint.x =projectedPoint.x* scaleRatio;
					projectedPoint.y =projectedPoint.y *scaleRatio;
					arrowMarker.root._x =  projectedPoint.x;
					arrowMarker.root._y =  projectedPoint.y;
					
					scaleRatio = scaleRatio < minArrowScale ? minArrowScale : scaleRatio > maxArrowScale ? maxArrowScale : scaleRatio;
					arrowMarker.root._scaleX = scaleRatio * 16;
					arrowMarker.root._scaleY =  scaleRatio * 16;
					arrowMarker.root._y -= 8 *scaleRatio;
					
					arrowMarker.root.transformChanged = true;
					
				}
			//}	
		}
		
		public function updateFuel(ratio:Number):void 
		{
			ratio *= MOVEMENT_BAR_SCALE;
			if (_movementBar.root._scaleX !=ratio ) {
				_movementBar.root._scaleX = ratio;
				_movementBar.root._x = -(MOVEMENT_BAR_SCALE -ratio)*.5;
				_movementBar.root.transformChanged = true;
			}
		}
		
		public function updateTurnInfo(curCommandPoints:int, maxCommandPoints:int, side:String, sideIndex:int, incomeNextTurn:int):void 
		{
			var cpInfo:String ="CP: "+ curCommandPoints + " / " + maxCommandPoints +  "  [+" + incomeNextTurn + "]";
			_cpInfo = cpInfo;
			
			_textTurnInfo.counter = 0;
			_textTurnInfo.writeData(side +" :: "+curCommandPoints+" CP left:", 0, 0, 800, false);
			
			//throw new Error(_textTurnInfo.boundsCache.length );
			var aabb:AABB2 = _textTurnInfo.boundParagraph; 
			
			var aabbWidth:Number = (aabb.maxX - aabb.minX);
			adjustSpriteMeshIconMeter(curCommandPoints, _cpMeter);
			_cpMeterHolder.x = _textTurnInfo.spriteSet._parent.x +  aabbWidth + 18;
			_cpMeterHolder.y = _textTurnInfo.spriteSet._parent.y + 10;
			//_textTurnInfoMini.writeFinalData(cpInfo , 0, 0, 800, false);  // curCommandPoints + "CP left."
			
	
			_textTurnInfo.writeData("+" + incomeNextTurn + " next phase.  Max: " + maxCommandPoints , curCommandPoints * 16 + aabbWidth + 12, 0, 2000, false, _textTurnInfo.boundsCache.length    );
	
			_textTurnInfo.finaliseWrittenData();
		}
		
		
		
		public var strikeResult:int;
		public var enemyStrikeResult:int;
		private var ENEMY_ROLL_CRIT:Boolean = EnemyAggroSystem.AGGRO_HAS_CRITICAL;
		private var _gotTargetLOS:Boolean;
		private var _bestChoiceIndex:uint;
		public var playerDmgDealRoll:int;
		public var enemyDmgDealRoll:int
		
		public function checkStrike(keyCode:uint):int 
		{
			strikeResult = 0;
			enemyStrikeResult = 0;
			
			
			if (!_charWeaponEnabled || !_targetMode || !_gotTargetInRange || !_targetNode || !_gotTargetLOS) return 0;
			if (keyCode == Keyboard.F) keyCode = _bestChoiceIndex
			else keyCode = keyCode -Keyboard.NUMBER_1;  // get index keyCode for weapon slot
			var chosenWeapon:Weapon = choicesWeapons[keyCode];
			if (chosenWeapon == null) return 0;
			
			
			playerWeaponModeForAttack = chosenWeapon.fireMode;
			// ROLLING
			var hitPercResult:Number;
			var critPercResult:Number;
			var gotCrit:Boolean
			
			var aggro:EnemyAggro = _targetNode.entity.get(EnemyAggro) as EnemyAggro;
			var checkingLOS:Boolean = false;
			var aggroing:Boolean = aggro != null && aggro.flag == 1 && (checkingLOS=aggro!=null) && checkLOS(targetNode.entity, (_targetNode.entity.get(WeaponState) as WeaponState).fireMode,  _displayChar);

			_charWeaponEnabled = false; 
			updateCharInfo();
			
			var health:Health = targetNode.entity.get(Health) as Health;
			
			var gotHit:Boolean = false;
			var percToRoll:Number;
			var baseDmg:Number;
			var playerHealth:Health = (_displayChar.get(Health) as Health);
			
			if (!aggroing) {  // Only player attacks
				percToRoll = HitFormulas.getPercChanceToHitDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid ) 
				
				//percToRoll = Math.round(hitPercResult);
				if (Math.random() * 100 <= percToRoll) {  // got hit
					baseDmg = HitFormulas.rollDamageForWeapon(chosenWeapon );
					
					percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid );
					if (checkingLOS || (aggro && aggro.flag == -1) ) percToRoll *= EVASION_UNDER_COVER_BONUS
					else {
						hitPercResult *= checkCoverBlockLOS( _targetNode.entity, _displayChar ) ? BEING_UNDER_COVER_BONUS : 1;
					}
					
							gotCrit = Math.random() * 100 <= percToRoll;
							
					strikeResult = gotCrit ? 2 :1;
					// resolve now1
					//health.damage( HitFormulas.rollDamageForWeapon(_displayChar.get(Weapon) as Weapon ) * (gotCrit ? 3 : 1) );	
					playerDmgDealRoll = HitFormulas.rollDamageForWeapon(chosenWeapon) * (gotCrit ? 3 : 1);
				}
				else {
					txtPlayerMisses(_displayChar, targetNode.entity);
					strikeResult = -1;
				}
	
				return strikeResult;
			}
			else {  // Both sides attack
				
				enemyStrikeResult = -1;
				var aggroWeapon:Weapon = (_targetNode.entity.get(WeaponState) as WeaponState).fireMode;
				enemyWeaponModeForAttack = aggroWeapon.fireMode;
				//posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState
				percToRoll = HitFormulas.getPercChanceToBeHitByAttacker(
				_curCharPos,
					_displayChar.get(Rot) as Rot,
				  _displayChar.get(CharDefense) as CharDefense,
				  _displayChar.get(Ellipsoid) as Ellipsoid, 
				 chosenWeapon,
				   _targetNode.entity.get(Pos) as Pos,
				    _targetNode.entity.get(Rot) as Rot,
					 _targetNode.entity.get(Ellipsoid) as Ellipsoid,
					 aggroWeapon,
					   _targetNode.entity.get(WeaponState) as WeaponState
				);
				var dmgInflict:int = 0;
				var survived:Boolean = true;
				
				if (percToRoll > 0) {  // ai goes first
					if (Math.random() * 100 <= percToRoll) {
						dmgInflict = HitFormulas.rollDamageForWeapon( aggroWeapon );
						enemyStrikeResult = 1;
						
						if (ENEMY_ROLL_CRIT) {
							percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid );
							gotCrit = Math.random() * 100 <= percToRoll;
							enemyStrikeResult = gotCrit ? 2 : 1;
							dmgInflict *= gotCrit ? 3 : 1;
						}
						
						if (dmgInflict < playerHealth.hp ) { // 
							
						}
						else {  // u will always miss because u will be dead!
							survived = false;
						}
					}
					if (survived) {
						percToRoll = HitFormulas.getPercChanceToHitDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid ) 
				
						if (Math.random() * 100 <= percToRoll) { // got hit
							baseDmg = HitFormulas.rollDamageForWeapon( chosenWeapon );
							
							percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid );
							gotCrit = Math.random() * 100 <= percToRoll;
							strikeResult = gotCrit ? 2 : 1;
						}
						else strikeResult = -1;
						
						
						// resolve now 
						//if (strikeResult > 0) health.damage( HitFormulas.rollDamageForWeapon(chosenWeapon ) * (gotCrit ? 3 : 1) )
						//else txtPlayerMisses(_displayChar, targetNode.entity);
						
						//playerHealth.damage(dmgInflict);
						if (strikeResult > 0) playerDmgDealRoll = HitFormulas.rollDamageForWeapon(chosenWeapon ) * (gotCrit ? 3 : 1);
						enemyDmgDealRoll = dmgInflict;

						return strikeResult;
					}
					else {
						
						// resolve now (you will be dead)
						//txtPlayerMisses(_displayChar, targetNode.entity);
						//playerHealth.damage(dmgInflict);
						
						strikeResult = -1;
						return strikeResult;
					}
				}
				else {  // you go first
					//posA:Pos, rotA:Rot, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState
					percToRoll = HitFormulas.getPercChanceToHitSlowerAttacker(
						_curCharPos,
						_displayChar.get(Rot) as Rot,
					  _displayChar.get(Ellipsoid) as Ellipsoid, 
					 chosenWeapon,
					   _targetNode.entity.get(Pos) as Pos,
						_targetNode.entity.get(Rot) as Rot,
						 _targetNode.entity.get(CharDefense) as CharDefense,
						  _targetNode.entity.get(Ellipsoid) as Ellipsoid,
						  aggroWeapon,
						   _targetNode.entity.get(WeaponState) as WeaponState
					);
					if (Math.random() * 100 <= percToRoll) {  // got hit
						
						// roll for critical
						percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid );
						baseDmg = HitFormulas.rollDamageForWeapon(chosenWeapon );
						gotCrit = Math.random() * 100 <= percToRoll;
						strikeResult = gotCrit ? 2 : 1;
						 baseDmg *= (gotCrit ? 3 : 1);
						 
					
						if (baseDmg < (_displayChar.get(Health) as Health).hp ) { // 
							// give AI a chance to retailaite as well
							//playerHealth.damage();
							dmgInflict = 0;
							percToRoll = HitFormulas.getPercChanceToHitDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot) as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid ) 
							if (Math.random() * 100 <= percToRoll) {
								dmgInflict = HitFormulas.rollDamageForWeapon(_targetNode.entity.get(Weapon) as Weapon);
							}
							
							enemyStrikeResult = 1;
						
							if (ENEMY_ROLL_CRIT) {
								percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid );
								gotCrit = Math.random() * 100 <= percToRoll;
								enemyStrikeResult = gotCrit ? 2 : 1;
								dmgInflict *= gotCrit ? 3 : 1;
							}
							
							// resolve now
							playerDmgDealRoll = baseDmg;
							enemyDmgDealRoll = dmgInflict;
							//health.damage(baseDmg);	
							//playerHealth.damage(dmgInflict);
							
							
							
						}
						else {
							// resolve now, killing enemy ai
							playerDmgDealRoll = baseDmg;
							//health.damage(baseDmg);	
						}
					
					
					}
					else { // miss, enemy retailaites
						dmgInflict = 0;
						percToRoll = HitFormulas.getPercChanceToHitDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot) as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid ) 
						if (Math.random() * 100 <= percToRoll) {
							dmgInflict = HitFormulas.rollDamageForWeapon(aggroWeapon);
							enemyStrikeResult = 1;
						
							if (ENEMY_ROLL_CRIT) {
								percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid );
								gotCrit = Math.random() * 100 <= percToRoll;
								enemyStrikeResult = gotCrit ? 2 : 1;
								dmgInflict *= gotCrit ? 3 : 1;
							}
						}
							
						// resolve now, player miss and taking damage from enemy if any..
						enemyDmgDealRoll = dmgInflict;
						//txtPlayerMisses(_displayChar, targetNode.entity);
						//playerHealth.damage(dmgInflict);
						
						strikeResult = -1;
					}
					
					
					return strikeResult;
					
				}
				
				
			}
			
			
			
		
		}
		
		private function getWeaponByIndex(weapon:Weapon, count:uint):Weapon 
		{
		
			var c:int = 0;
			while (weapon != null) {
				if (c >= count) break;
				weapon = weapon.nextFireMode;
				c++;
			}
			return weapon;
		}
		
		
		public function getWeapon(ent:Entity):Weapon {
			return ent.get(Weapon) as Weapon;
		}
		
		public function txtPlayerStrike(e:Entity, hp:int, amount:int, killingBlow:Boolean=false):void 
		{
			if (amount == 0) return;
		//	_msgLogInfo.resetAllScrollingMessages()
			var obj:Object3D = e.get(Object3D) as Object3D;
			
			var crit:Boolean  = strikeResult == 2;
			_msgLogInfo.appendSpanTagMessage(!killingBlow  ? '<span u="2">Player</span> hits <span u="1">'+obj.name + '</span> for <span u="'+(crit ? 1 : 2)+'">'+amount + '</span> points of '+(crit ? '<span u="1">critical</span> ': '')+'damage.' : '<span u="2">Player kills</span> <span u="1">'+obj.name + '</span>'+(crit ? ' with a <span u="1">critical</span> hit' : "")+'!');
			_msgLogInfo.drawNow();
			if ( e === _targetNode.entity) {
				if (!killingBlow ) {
					setTargetChar(_targetNode);
					
				}
				else if (killingBlow) {
					setTargetChar(null );
				}
			}
		
		}
		
		// this could be due to a block/parry or something, we determine description here
		///*
		private function txtPlayerMisses(e:Entity, targetEntity:Entity):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			var targetObj:Object3D = targetEntity.get(Object3D) as Object3D;
		
			_msgLogInfo.appendSpanTagMessage('<span u="2">Player</span> misses <span u="1">'+targetObj.name+'</span>!');
			_msgLogInfo.drawNow();
		
		}
		//*/
		
		
		
		public function txtTookDamageFrom(e:Entity, hp:int, amount:int, killingBlow:Boolean=false):void 
		{
		
			var describeDmg:String = enemyStrikeResult != 2  ? "" : " critical";
			enemyStrikeResult = 0;
			
			if (e == null) {
				
				appenSpanTagMessage(killingBlow ? 'Player died due to <span u="1">'+amount+'</span>'+describeDmg+' damage!' : amount!= 0 ? 'Player took <span u="1">' + amount + '</span> points of '+describeDmg+'damage.' : 'Player avoided enemy strike');
				updateCharInfo();
				return;
				
			}
				var obj:Object3D = e.get(Object3D) as Object3D;
				//var player:Object3D = 
			
			appenSpanTagMessage(amount == 0 ? '<span u="1">' + obj.name + '</span> misses player.': !killingBlow ? 'Player took ' + amount + describeDmg+' damage from <span u="1">' + obj.name + '</span>!' : 
					 'Player was killed by <span u="1">' + obj.name + '</span>!' 
				);
			
			
			updateCharInfo();
		}
		
		public function outOfFuel():void 
		{
			_msgLogInfo.appendSpanTagMessage(
					 'You have ran out of movement points!' 
				);
				_msgLogInfo.drawNow();
		}
		
		public function appendMessage(string:String):void 
		{
				_msgLogInfo.appendMessage(
					string
				);
				_msgLogInfo.drawNow();
		}
		
		public function appenSpanTagMessage(string:String):void 
		{
			//_msgLogInfo.appendMessage("_"+	string	);
				_msgLogInfo.appendSpanTagMessage(	string	);
				_msgLogInfo.drawNow();
		}
		
		public function get targetNode():PlayerTargetNode 
		{
			return _targetNode || _lastTargetNode;
		}
		
		public function get charWeaponEnabled():Boolean 
		{
			return _charWeaponEnabled;
		}
		

		
		
		
		
	}

}
import arena.systems.player.IWeaponLOSChecker;
import components.Ellipsoid;
import components.Pos;


class DummyWeaponLOSCheck implements IWeaponLOSChecker {
	public function validateWeaponLOS (attacker:Pos, sideOffset:Number, heightOffset:Number, target:Pos, targetSize:Ellipsoid) : Boolean {
		return true;
	}
	
	
}