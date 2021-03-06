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
	import arena.components.char.AggroMem;
	import arena.components.char.ArenaCharacterClass;
	import arena.components.char.CharDefense;
	import arena.components.char.EllipsoidPointSamples;
	import arena.components.char.HitFormulas;
	import arena.components.enemy.EnemyAggro;
	import arena.components.enemy.EnemyIdle;
	import arena.components.weapon.Weapon;
	import arena.components.weapon.WeaponSlot;
	import arena.components.weapon.WeaponState;
	import arena.systems.enemy.EnemyAggroSystem;
	import arena.systems.player.IStance;
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
	import flash.geom.Point;
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
	public class ArenaHUD   extends HudBase 
	{
		// standard boilerplate
		
		
		public var hudMeshSetBase:SpriteMeshSetClonesContainer;
		private var hudMeshMaterial:TextureAtlasMaterial
		private var hudTextureWidth:int;
		private var hudTextureHeight:int;
		
	
		
		private var visHash:Object = { };
		
	
		static public const MAX_CHARS:int = 60;  // per draw call
		
		
		
		
	
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
			super(stage);
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
		
		
	
		
		override protected function init():void {
		
				 super.init();
		
			
		//	stage.addChild( new Bitmap( fontConsole.bmpResource.data) );
	//		fontConsole.bmpResource.upload(context3D);
			//chatTextInput.glyphRange = fontConsole.fontV._glyphRange;
			_textGeometry  = SpriteGeometryUtil.createNormalizedSpriteGeometry(MAX_CHARS, 0, 1, 1, 0, 0, 2);
			//_textGeometry.upload(context3D);
			
			
			// setup basic sprite sheet
			var hudBmpData:BitmapData = new SaboteurHudAssets.$_SHEET().bitmapData;
			hudTextureWidth = hudBmpData.width;
			hudTextureHeight = hudBmpData.height;
			var hudResource:BitmapTextureResource = new BitmapTextureResource( hudBmpData );
			//hudResource.upload(context3D);
			
			hudMeshMaterial = new TextureAtlasMaterial(hudResource);// null, 1);
			hudMeshMaterial.alphaThreshold = .8;
			hudMeshMaterial.flags = TextureAtlasMaterial.FLAG_MIPNONE;  // | TextureAtlasMaterial.FLAG_PIXEL_NEAREST
			
			hudMeshSetBase =  new SpriteMeshSetClonesContainer(hudMeshMaterial, 0 );
			hudMeshSetBase.objectRenderPriority = Renderer.NEXT_LAYER;
			hudMeshSetBase.name = "hud";
			//hudMeshSetBase.geometry.upload(context3D);
			
			hud.addChild(hudMeshSetBase);
				
			setupHUD();
			
			
			setupDials();
		
			
		}
		[Embed(source="../../../../resources/fonts/dialsymbols.png")]
		private static var DIAL_SYMBOLS:Class;
		private function setupDials():void 
		{
			var bmpData:BitmapData = new DIAL_SYMBOLS().bitmapData;
			//addChild( new Bitmap(bmpData));
		
			var material:TextureAtlasMaterial = new TextureAtlasMaterial( new BitmapTextureResource( bmpData ) );
			//material.alphaThreshold =0.2;
			//material.color = 0xFFFFFF;
		//	material.transparentPass = false;
			material.alphaThreshold = .8;
	//		material.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			

			
			var cont:SpriteMeshSetClonesContainer = _myDialSymbols =  new SpriteMeshSetClonesContainer( material);
			//cont.objectRenderPriority = Renderer.NEXT_LAYER;
			//cont.x = -54;
			//cont.y = -54;
			(!CENTER_MODE ? layoutBottomRight : hud).addChild(cont);
			
			
			// Create dials
			if (CENTER_MODE) {
				DIAL_1_POSITION.x = 0;
				DIAL_1_POSITION.y = 0;
			}
			var dial:Array =  createDial(DIAL_1_POSITION.x, DIAL_1_POSITION.y);    
			//setDialValues(dial, 3, 20, 3, 10, 4, 2, 0);  // testing only
			setDialValues(dial, 6, 20, 3, 3, 4, 2, 3);  // testing only
			createDial(DIAL_2_POSITION.x , DIAL_2_POSITION.y);
			//allDials[allDials.length - 1].obj.x = 99999;
			createDial(DIAL_3_POSITION.x , DIAL_3_POSITION.y);
			allDials[allDials.length - 1].obj.x = 99999;
			enemyDial = createDial(9999 , DIAL_3_POSITION.y);
			
		
			
			var spr:SpriteSet;
			dialLetters = new FontSettings(fontConsole, fontConsoleMatDefault, spr = getNewTextSpriteSet(60, fontConsoleMatDefault, _textGeometry) );
			
			//dialLetters.hardSetUVOffsetIndices(3);
			dialLetters.initMeshSet( cont = new SpriteMeshSetClonesContainer(fontConsoleMatDefault, 0) );
			//cont.objectRenderPriority = Renderer.NEXT_LAYER;
			dialLetters.writeCircleData("Block Open/Stk", 0, 0, true, 100, 0, allDials[0].obj);  // testing only
			dialLetters.writeCircleData("Thrust ", 0, 0, true, 100, dialLetters.circleTailIndex, allDials[1].obj); 
			
			//dialLetters.writeData("Cut", DIAL_2_POSITION.x, DIAL_2_POSITION.y, 0,  true, dialLetters.boundsCache.length); 
			//dialLetters.finaliseWrittenData();
			//spr.x = -54;
			//spr.y = -54;
			
			//cont.x = -54;
			//cont.y = -54;
			(!CENTER_MODE ? layoutBottomRight : hud).addChild(spr);
			(!CENTER_MODE ? layoutBottomRight : hud).addChild(cont);
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
		
		
		

		
		

		private function addSprite(px:Number, py:Number, width:Number, height:Number, x:Number = 0, y:Number = 0, parenter:Object3D=null):SpriteMeshSetClone {
			var spr:SpriteMeshSetClone = getSprite(hudMeshSetBase,px, py, width, height, x, y, parenter);
			
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
				arr[i] = spr  = getSprite(hudMeshSetBase,px, py, width, height, 0, 0, parenter);
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
			//registerVisStatesOfTextBox("thirdPerson", _msgLogInfo);
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
			//_curCharInfo.addToContainer(layoutBottomRight);
			registerVisStatesOfTextBox("commander", _curCharInfo);
			
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
			clearLog();
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
			
			var weap:Weapon  = ent.get(Weapon) as Weapon;
			if (weap != null) {
				var weapSlot:WeaponSlot = ent.get(WeaponSlot) as WeaponSlot;
				if (weapSlot != null) {
					weapIndex = weapSlot.slots.indexOf(weap);
				}
			}
			
			_curCharPos = ent.get(Pos) as Pos;
			
			lastCharPosition.x = _curCharPos.x;
			lastCharPosition.y = _curCharPos.y;
			lastCharPosition.z = _curCharPos.z;
			
			updateCharInfo();
			
			var gSa:GladiatorStance = ent.get(IAnimatable) as GladiatorStance;
			setStance(gSa.stance);
			
			
		}
		
		public function cycleWeapon():int {
			if (_displayChar == null) return -1;
			var weaponSlots:WeaponSlot = _displayChar.get(WeaponSlot) as WeaponSlot;
			if (weaponSlots == null) return -1;
			
			weapIndex++;
			if (weapIndex >= weaponSlots.slots.length) {
				weapIndex = 0;
			}
			
			
			//_displayChar.removeNoSignal(Weapon);
			_displayChar.addOrChange(weaponSlots.slots[weapIndex], Weapon);
			setWeapon(weapIndex);
			return weapIndex;
		}
		
		private function setWeapon(index:int):void {
			weapIndex = index;
			updateCharInfo();
			
			 if (_targetNode && _targetMode) {
				 updateTargetChoices(); 
			 }
		}
		
		private function updateCharInfo():void 
		{
			var ent:Entity = _displayChar;
				var health:Health = ent.get(Health) as Health;
				if (health == null) {
					
					setDeadCharInfo();
					return;
				}
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
			_curCharInfo.appendMessage(weaponSlots && !_targetMode ? "'B' to cycle weapons. ("+(weapIndex+1)+"/" + weaponSlots.slots.length + ")" : _stars ? "Press 'TAB' to cycle character." : " " ); //"'Z' to switch attack mode. (1/2)" //"Attack completed."
			if (!_charWeaponEnabled && !_stars) _curCharInfo.appendSpanTagMessage('<span u="2">Done!</span>');
			 _curCharInfo.appendMessage(_stars ?  numStars > 0 ?  MSG_START_ACTION_TURN : " " : MSG_END_ACTION_TURN);
			_curCharInfo.drawNow();
		}
		
		private function setDeadCharInfo():void {
			var ent:Entity = _displayChar;
			
			var obj:Object3D = ent.get(Object3D) as Object3D;
		
			
			var charClass:ArenaCharacterClass = ent.get(ArenaCharacterClass) as ArenaCharacterClass;


			//ent.get(ArenaChar

			_curCharInfo.appendMessage("Name: "+obj.name);
			_curCharInfo.appendSpanTagMessage('<span u="2">Dead!</span>');
			_curCharInfo.appendMessage("Class: " + charClass.name);
			//_curCharInfo.appendMessage("Press 'TAB' to switch to new character."); //"'C' to switch attack mode. (1/2)" //"Attack completed."
			//if (!_charWeaponEnabled && !_stars) _curCharInfo.appendSpanTagMessage('<span u="2">Done!</span>');
		//	 _curCharInfo.appendMessage(_stars ?  numStars > 0 ?  MSG_START_ACTION_TURN : " " : MSG_END_ACTION_TURN);
			_curCharInfo.drawNow();
		}
		
		private var _gotTargetInRange:Boolean = false;
		private var _curCharPos:Pos;
		private var _targetNode:PlayerTargetNode;
		private var _targetMode:Boolean;
		
		private function getRangeToTarget():Number {
			return HitFormulas.get3DDist(_curCharPos, _targetNode.pos, _targetNode.ellipsoid) ;
			/*
			var dx:Number = _curCharPos.x - _targetNode.pos.x;
			var dy:Number = _curCharPos.y - _targetNode.pos.y;
			var dz:Number = _curCharPos.z - _targetNode.pos.z;
			var dist:Number = Math.sqrt(dx * dx + dy * dy + dz * dz);
			var distM:Number = 1 / dist;
			dx *= distM*_targetNode.ellipsoid.x;
			dy *= distM*_targetNode.ellipsoid.y;
			dz *= distM*_targetNode.ellipsoid.z;
			return  dist - Math.sqrt(dx*dx+dy*dy+dz*dz);
			*/
		}
		private function getSqDistToTarget():Number {
			var dx:Number = _curCharPos.x - _targetNode.pos.x;
			var dy:Number = _curCharPos.y - _targetNode.pos.y;
			var dz:Number = _curCharPos.z - _targetNode.pos.z;
			return dx * dx + dy * dy + dz * dz;
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
				_gotTargetInRange =  getSqDistToTarget() <= weapon.range*weapon.range;
				if (_gotTargetInRange) {
					_gotTargetLOS = weaponLOSCheck == null || checkLOS(_displayChar, _displayChar.get(Weapon) as Weapon, node.entity);
				}
			}
			else {
			
				_gotTargetInRange =  false; 
			
			}
			
			if (_gotTargetInRange && _gotTargetLOS && !_stars && _targetMode) {
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
			
			return entAWeapon!= null ? weaponLOSCheck.validateWeaponLOS( entA.get(Pos) as Pos, entAWeapon.sideOffset, entAWeapon.heightOffset, entB.get(Pos) as Pos, entB.get(Ellipsoid) as Ellipsoid ) : false;
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
			
			if (_targetNode == null) {
					choices.length = 0;
					_actionChoicesBox.drawNow();
					return;
			}
			//_targetNode = _targetNode || _lastTargetNode;
			//if (!_targetNode.entity.get(
			var aggroTarget:AggroMem = _targetNode.entity.get(AggroMem) as AggroMem;
			var aggroSide:int = aggroTarget != null ? aggroTarget.side : -1;
			var aggroPlayer:AggroMem = _displayChar.get(AggroMem) as AggroMem;
			var playerSide:int = aggroPlayer != null ? aggroPlayer.side : -1;
			if ( (playerSide == aggroSide) || aggroSide == -1 ) {
				choices.length = 0;
				_actionChoicesBox.drawNow();
				return;  // kiv: shoudld redirect to healing/non-threathening options for friendly side!
				
			}
				
			// ROLLING
			var hitPercResult:Number;
			var critPercResult:Number;
			var bestChoiceIndex:int = 0;
			var bestDamage:int = 0;
			var bestPercChanceToHit:Number = 0;
			
			
			//var rangeToTarget:Number = getRangeToTarget();
			var sqDistToTarget:Number = getSqDistToTarget();
			
			var count:int = 0;
			for (var playerWeapon:Weapon =  _displayChar.get(Weapon) as Weapon; playerWeapon != null; playerWeapon = playerWeapon.nextFireMode) {  // start loop
			
			if (playerWeapon.range*playerWeapon.range < sqDistToTarget || !checkLOS(_displayChar, playerWeapon, _targetNode.entity)) {
				continue;
			}
			var aggro:EnemyAggro = _targetNode.entity.get(EnemyAggro) as EnemyAggro;
			var aggroing:Boolean = false;
			var checkingLOS:Boolean = false;
			
			//try {
			
			var fullyAggro:Boolean = HitFormulas.fullyAggroing(_targetNode.entity);
			aggroing = aggro == null || aggro.flag != 1 || (_targetNode.entity.get(WeaponState) as WeaponState).fireMode.fireMode <= 0  ? false : (checkingLOS  = aggro != null) && checkLOS(_targetNode.entity, (_targetNode.entity.get(WeaponState) as WeaponState).fireMode, _displayChar);
			
			var exposure:Number =  weaponLOSCheck.getTotalExposure(_curCharPos, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, _targetNode.entity.get(IStance) as IStance, _targetNode.entity.get(EllipsoidPointSamples) as EllipsoidPointSamples  );
			
		//	if (aggro != null && aggro.flag == 2) throw new Error("STILL WAITING");
			if (!aggroing) {
				hitPercResult = HitFormulas.getPercChanceToHitDefenderMethod(playerWeapon)( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid, !fullyAggro  ? HitFormulas.getFullyDefensiveRating( _targetNode.entity.get(CharDefense) as CharDefense) : 0 , !fullyAggro ? -.3 : 0  ); //HitFormulas.getDefenseForEntity(_displayChar, _targetNode.entity) 
				if (checkingLOS || (aggro && aggro.flag == -1) ) hitPercResult *= EVASION_UNDER_COVER_BONUS
				else hitPercResult *= checkCoverBlockLOS( _targetNode.entity, _displayChar ) ? BEING_UNDER_COVER_BONUS : 1;
				critPercResult= HitFormulas.getPercChanceToCritDefender(_curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense,_targetNode.entity.get(Ellipsoid) as Ellipsoid, exposure, _targetNode.entity.has(EnemyAggro) ? HitFormulas.STATE_UNAWARE : 0 );
				
				
				
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
						_targetNode.entity.get(WeaponState) as WeaponState,
						exposure);
			}
			
			
			//Ellipsoid, targetStance:IStance, targetPts:EllipsoidPointSamples
		//	hitPercResult = weaponLOSCheck.getTotalExposure(_curCharPos, playerWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, _targetNode.entity.get(IStance) as IStance, _targetNode.entity.get(EllipsoidPointSamples) as EllipsoidPointSamples  ) * 100;
		
			hitPercResult *= playerWeapon.fireMode <=0 ? exposure : 1;
			hitPercResult = Math.round(hitPercResult);
			critPercResult = Math.round(critPercResult);
			
			var targetHP:Health = _targetNode.entity.get(Health) as Health;
			
			var sampleDmg:int = HitFormulas.rollDamageForWeapon(playerWeapon);
			var numHits:int = Math.ceil(targetHP.hp / sampleDmg);
			var numCritHits:int = Math.ceil(targetHP.hp / (sampleDmg * (_targetNode.entity.get(CharDefense) as CharDefense).critDamageMult ));
			
			var showLabels:Boolean = false;
		
			//_actionChoicesBox.appendMessage("::");
			if (hitPercResult > bestPercChanceToHit || (hitPercResult == bestPercChanceToHit && sampleDmg > bestDamage) ) {
				bestChoiceIndex = count;
				bestPercChanceToHit = hitPercResult;
				bestDamage = sampleDmg;
				_bestChoiceIndex = count;
			}
			
			//}  // end try
			//catch (e:Error) {
			//	throw new Error("CAUGHT:" + _targetNode + ", "+e );
			//}
			
			
			
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
					
					gotTargetInRange = getSqDistToTarget() <= playerWeapon.range*playerWeapon.range;
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
			updateCharInfo();
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
			//clearLog();
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
			updateCPTextInfo(curCommandPoints, maxCommandPoints, incomeNextTurn);
			
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
		
		private function updateCPTextInfo(curCommandPoints:int, maxCommandPoints:int, incomeNextTurn:int):void 
		{
			var cpInfo:String ="CP: "+ curCommandPoints + " / " + maxCommandPoints +  "  [+" + incomeNextTurn + "]";
			_cpInfo = cpInfo;
		}
		
		public function notifyPlayerActionMiss():void {
			txtPlayerMisses(_displayChar, _targetStrikeEntity);
		}
		
		
		public var strikeResult:int;
		public var enemyStrikeResult:int;
		private var ENEMY_ROLL_CRIT:Boolean = EnemyAggroSystem.AGGRO_HAS_CRITICAL;
		private var _gotTargetLOS:Boolean;
		private var _bestChoiceIndex:uint;
		private var _targetStrikeEntity:Entity;
		private var weapIndex:int = 0;
		public var playerChosenWeaponStrike:Weapon;
		public var playerDmgDealRoll:int;
		public var enemyDmgDealRoll:int
		public var enemyGoesFirst:Boolean = false;
		public var delayEnemyStrikeT:Number = 0;
		
		public function checkStrike(keyCode:uint):int 
		{
			strikeResult = 0;
			enemyStrikeResult = 0;
			
			
			if (!_charWeaponEnabled || !_targetMode || !_gotTargetInRange || !_targetNode || !_gotTargetLOS) return 0;
			if (keyCode == Keyboard.F) keyCode = _bestChoiceIndex
			else keyCode = keyCode -Keyboard.NUMBER_1;  // get index keyCode for weapon slot
			if (keyCode >= choices.length) return 0;
			var chosenWeapon:Weapon = choicesWeapons[keyCode];
			if (chosenWeapon == null) return 0;
			
			playerChosenWeaponStrike = chosenWeapon;
			playerWeaponModeForAttack = chosenWeapon.fireMode;
			_targetStrikeEntity = _targetNode.entity;
			// ROLLING
			var hitPercResult:Number;
			var critPercResult:Number;
			var gotCrit:Boolean
			
			var aggro:EnemyAggro = _targetNode.entity.get(EnemyAggro) as EnemyAggro;
			var checkingLOS:Boolean = false;
		
				var fullyAggro:Boolean = HitFormulas.fullyAggroing(_targetNode.entity);
			var aggroing:Boolean = aggro != null && aggro.flag == 1 && (_targetNode.entity.get(WeaponState) as WeaponState).fireMode.fireMode > 0 && (checkingLOS=aggro!=null) && checkLOS(_targetNode.entity, (_targetNode.entity.get(WeaponState) as WeaponState).fireMode,  _displayChar);

			_charWeaponEnabled = false; 
			updateCharInfo();
			
			var health:Health = _targetNode.entity.get(Health) as Health;
			
			var gotHit:Boolean = false;
			var percToRoll:Number;
			var baseDmg:Number;
			var playerHealth:Health = (_displayChar.get(Health) as Health);
			//attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetStance:IStance, targetPts:EllipsoidPointSamples
			var exposure:Number = weaponLOSCheck.getTotalExposure(_curCharPos, chosenWeapon,  _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, _targetNode.entity.get(IStance) as IStance, _targetNode.entity.get(EllipsoidPointSamples) as EllipsoidPointSamples);
			
			if (!aggroing) {  // Only player attacks
				percToRoll = HitFormulas.getPercChanceToHitDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid, !fullyAggro  ? HitFormulas.getFullyDefensiveRating(_targetNode.entity.get(CharDefense) as CharDefense) : 0, !fullyAggro? -.3 : 0 ); //  HitFormulas.getDefenseForEntity(_displayChar, _targetNode.entity) 
				
				//percToRoll = Math.round(hitPercResult);
				if (Math.random() * 100 <= percToRoll) {  // got hit
					baseDmg = HitFormulas.rollDamageForWeapon(chosenWeapon );
					
					percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid, exposure, _targetNode.entity.has(EnemyAggro) ? HitFormulas.STATE_UNAWARE : 0 );
					if (checkingLOS || (aggro && aggro.flag == -1) ) percToRoll *= EVASION_UNDER_COVER_BONUS
					else {
						hitPercResult *= checkCoverBlockLOS( _targetNode.entity, _displayChar ) ? BEING_UNDER_COVER_BONUS : 1;
					}
					
							gotCrit = Math.random() * 100 <= percToRoll;
							
					strikeResult = gotCrit ? 2 :1;
					// resolve now1
					//health.damage( HitFormulas.rollDamageForWeapon(_displayChar.get(Weapon) as Weapon ) * (gotCrit ? 3 : 1) );	
					playerDmgDealRoll = HitFormulas.rollDamageForWeapon(chosenWeapon) * (gotCrit ? (_targetNode.entity.get(CharDefense) as CharDefense).critDamageMult : 1);
				}
				else {
					//txtPlayerMisses(_displayChar, targetNode.entity);
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
					enemyGoesFirst = true;
					if (Math.random() * 100 <= percToRoll) {
						dmgInflict = HitFormulas.rollDamageForWeapon( aggroWeapon );
						enemyStrikeResult = 1;
						
						if (ENEMY_ROLL_CRIT) {
							percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid, exposure );
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
						percToRoll = HitFormulas.getPercChanceToHitDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid, aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot) as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid, 0 ); //HitFormulas.getDefenseForEntity(_displayChar, _targetNode.entity) 
						
				percToRoll *= chosenWeapon.fireMode <=0 ? exposure : 1;
						if (Math.random() * 100 <= percToRoll) { // got hit
							baseDmg = HitFormulas.rollDamageForWeapon( chosenWeapon );
							
							percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid, exposure );
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
					enemyGoesFirst = false;
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
					
					percToRoll *= chosenWeapon.fireMode <=0 ? exposure : 1;
					if (Math.random() * 100 <= percToRoll) {  // got hit enemy
						
						// roll for critical
						percToRoll =  HitFormulas.getPercChanceToCritDefender( _curCharPos, _displayChar.get(Ellipsoid) as Ellipsoid,  aggroWeapon, _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Rot)	 as Rot, _targetNode.entity.get(CharDefense) as CharDefense, _targetNode.entity.get(Ellipsoid) as Ellipsoid,exposure );
						baseDmg = HitFormulas.rollDamageForWeapon(chosenWeapon );
						gotCrit = Math.random() * 100 <= percToRoll;
						strikeResult = gotCrit ? 2 : 1;
						 baseDmg *= (gotCrit ? 3 : 1);
						 
					
						if (baseDmg < (_targetNode.entity.get(Health) as Health).hp ) { // enemy can retailate because he'll still be alive after getting hit
							// give AI a chance to retailaite as well
							//playerHealth.damage();
							dmgInflict = 0;
							percToRoll = HitFormulas.getPercChanceToHitDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot) as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid ) //HitFormulas.getDefenseForEntity(_targetNode.entity, _displayChar) 
							if (Math.random() * 100 <= percToRoll) {
								dmgInflict = HitFormulas.rollDamageForWeapon(_targetNode.entity.get(Weapon) as Weapon);
							}
							
							enemyStrikeResult = 1;
						
							if (ENEMY_ROLL_CRIT) {
								percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid, exposure );
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
							enemyDmgDealRoll = 0;
							enemyStrikeResult = 0;
							//health.damage(baseDmg);	
						}
					
					
					}
					else { // miss, enemy retailaites
						dmgInflict = 0;
						percToRoll = HitFormulas.getPercChanceToHitDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid, chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot) as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid ); //HitFormulas.getDefenseForEntity(_targetNode.entity, _displayChar) 
						if (Math.random() * 100 <= percToRoll) {
							dmgInflict = HitFormulas.rollDamageForWeapon(aggroWeapon);
							enemyStrikeResult = 1;
						
							if (ENEMY_ROLL_CRIT) {
								percToRoll =  HitFormulas.getPercChanceToCritDefender( _targetNode.entity.get(Pos) as Pos, _targetNode.entity.get(Ellipsoid) as Ellipsoid,  chosenWeapon, _displayChar.get(Pos) as Pos, _displayChar.get(Rot)	 as Rot, _displayChar.get(CharDefense) as CharDefense, _displayChar.get(Ellipsoid) as Ellipsoid, exposure );
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

			if ( e === _targetStrikeEntity) {
				if (!killingBlow ) {
				//	setTargetChar(_targetStrikeNode);
					
				}
				else if (killingBlow) {
					setTargetChar(null );
				}
			}
		
		}
		
		public function txtEnemyGotHit(e:Entity, hp:int, amount:int, killingBlow:Boolean=false):void 
		{
			if (amount == 0) return;
		//	_msgLogInfo.resetAllScrollingMessages()
		
			var obj:Object3D = e.get(Object3D) as Object3D;

			var crit:Boolean  = strikeResult == 2;
			_msgLogInfo.appendSpanTagMessage(!killingBlow  ? '<span u="1">'+obj.name + '</span> took <span u="1">'+amount+'</span> points of assisted damage.' : '<span u="1">'+obj.name + '</span> was killed by friendly assist!');
			_msgLogInfo.drawNow();

			if ( e === _targetStrikeEntity) {
				if (!killingBlow ) {
				//	setTargetChar(_targetStrikeNode);
					
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
				
				appendSpanTagMessage(killingBlow ? 'Player died due to <span u="1">'+amount+'</span>'+describeDmg+' damage!' : amount!= 0 ? 'Player took <span u="1">' + amount + '</span> points of '+describeDmg+'damage.' : 'Player avoided enemy strike');
				updateCharInfo();
				return;
				
			}
				var obj:Object3D = e.get(Object3D) as Object3D;
				//var player:Object3D = 
			
			appendSpanTagMessage(amount == 0 ? '<span u="1">' + obj.name + '</span> misses player.': !killingBlow ? 'Player took ' + amount + describeDmg+' damage from <span u="1">' + obj.name + '</span>!' : 
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
		
		public function appendSpanTagMessage(string:String):void 
		{
			//_msgLogInfo.appendMessage("_"+	string	);
				_msgLogInfo.appendSpanTagMessage(	string	);
				_msgLogInfo.drawNow();
		}
		
		public function killPlayer():void 
		{
			_charWeaponEnabled = false;
			setDeadCharInfo();
		}
		
		public function reloadTurn():void 
		{
			_charWeaponEnabled = true;
			
			
		}
		
		/*
		public function get targetNode():PlayerTargetNode 
		{
			return _targetNode || _lastTargetNode;
		}
		*/
		
		public function get targetEntity():Entity 
		{
			return  _targetStrikeEntity;
		}
		
		public function get charWeaponEnabled():Boolean 
		{
			return _charWeaponEnabled;
		}
		

		
		// Dials
		private var _myDialSymbols:SpriteMeshSetClonesContainer;
		private var dialSymbols:BitmapData;
		private var c:SpriteMeshSetClone;
		private var dialLetters:FontSettings;
		
		private static const CENTER_MODE:Boolean = false;
		
		
		public static const DIAL_1_POSITION:Point = new Point( -140, -65); // defenive
		public static const DIAL_2_POSITION:Point = new Point( -60, -135); // offensive
		public static const DIAL_3_POSITION:Point = new Point( -60, -246); // offensive buy/secondary
		private var enemyDial:Array;
		private var dialTexts:String;
		private var dialEnemyText:String = "";
		
		
		public function writeMove():void {
			
		}
		
		
		
		
		private var allDials:Array = [];
		

		
		
		public static const DIAL_EMPTY:Number = 0/128;
		public static const DIAL_FILLED:Number = 1*16/128;
		public static const DIAL_PAIN:Number = 3*16/128;
		public static const DIAL_SHOCK:Number = 2*16/128;
		public static const DIAL_SPENT:Number = 4*16/128;
		public static const DIAL_PENALISE:Number = 5*16/128;
		public static const DIAL_DOT:Number = 6*16/128;
		public static const DIAL_BUY:Number = 7*16/128;
		
		public static const DIAL_BAR:Number = 6*16/128;
		
		public function setDialValues(dial:Array, usingCP:int, totalCP:int, spentCP:int=0, pain:int = 0, shock:int=0, manueverCost:int=0, intiativeBought:int=0):void {
			var i:int;
			
			
		
		
			c = dial[0];

			for (i = 0; i < spentCP; i++) {
				c = dial[i];
				c.u = DIAL_SPENT;
				c.v = 0;// .5;
				//c.u = ;
			}
			
			var len:int = usingCP + spentCP;
			for (i = spentCP; i < len; i++) {
				c = dial[i];
				c.u = DIAL_FILLED;
				c.v =  .5;
				//c.u = ;
				
			}
			
			len = totalCP;
			for (i = i;  i < len; i++) {
				c = dial[i];
				c.u = DIAL_EMPTY;
				c.v = 0;
				
			}
			
			c = dial[i];
			c.u = DIAL_EMPTY ;
			c.v = 0;
			i++;
			
			len = dial.length;
			for (i = i; i < len ; i++ ) {
				c = dial[i];
				c.u = DIAL_DOT;
				c.v = 0;
			}
			
			
			c = dial[totalCP];
			c.u = DIAL_BAR ;
			c.v = 0;
			
			if (pain >= shock) shock = 0
			else shock = shock - pain;
			
			i = totalCP;
			
			if (pain > 0) {
				while (--i > -1) {
					
					c = dial[i];
					c.u = DIAL_PAIN;
					c.v = 0;
					pain--;
					if (pain == 0) break;
				}
			}
			
			if (shock > 0) {
				while (--i > -1) {
					
					c = dial[i];
					c.u = DIAL_SHOCK;
					c.v = 0;
					shock--;
					if (shock == 0) break;
				}
			}
			
			i = usingCP + spentCP;
			
			if ( intiativeBought > 0) {
				while ( i < len) {
					
					c = dial[i];
					c.u = DIAL_BUY;
					c.v = 0;// .5;
					
					i++;
					intiativeBought--;
					if (intiativeBought == 0) break;
				}
			}
			
			if ( manueverCost > 0) {
				while ( i < len) {
					c = dial[i];
					c.u = DIAL_SPENT;
					c.v = 0;// .5;
					i++;
					manueverCost--;
					if (manueverCost == 0) break;
					
				
				}
			}

		}
		
		public function notifyEnemyInterrupt(gotInterrupt:Boolean=true):void 
		{
			//allDials[1].obj.x = gotInterrupt ?  DIAL_2_POSITION.x : 99999;
		}
		
		
		
		
		protected function createDial(ox:Number=0, oy:Number=0):Array {
			
			var c:SpriteMeshSetClone;
			
			var obj:Object3D = new Object3D();
			var arr:Array = [];
			var radius:Number = 42;
			var len:int = 26;
			obj.x = ox;
			obj.y = oy;
			var division:Number = 2 * Math.PI / len;
			 for (var i:int = 0 ; i < len; i++) {
				 //  var pos:Point = Point.polar(radius, (i / len) * Math.PI * 2);
				  _myDialSymbols.addClone( c =  getSprite(_myDialSymbols, 16 * 0, 0, 16, 16, -8, -8, obj) );
				  arr.push(c);
				 c.root._x = Math.cos( -Math.PI * .5 + division * i ) * radius;
				  c.root._y = Math.sin( -Math.PI * .5 + division * i) * radius;
				  c.root.rotationZ = division * i;
				//if (c.root.rotationZ == 0) c.root.rotationZ = 0.2;
				c.root.scaleX = 16;
				c.root.scaleY = 16;
			 }
		//	 obj.scaleX = obj.scaleY = .9;
			 arr["obj"] = obj;
			 allDials.push(arr);
			
			// obj.transform.copy(layoutBottomRight.transform);
			// obj.transform.append(
			
			return arr;
		}
		
		
	}

}
import arena.components.char.EllipsoidPointSamples;
import arena.systems.player.IStance;
import arena.components.weapon.Weapon;
import arena.systems.player.IWeaponLOSChecker;
import components.Ellipsoid;
import components.Pos;


class DummyWeaponLOSCheck implements IWeaponLOSChecker {
	public function validateWeaponLOS (attacker:Pos, sideOffset:Number, heightOffset:Number, target:Pos, targetSize:Ellipsoid) : Boolean {
		return true;
	}
	
	/* INTERFACE arena.systems.player.IWeaponLOSChecker */
	
	public function getTotalExposure(attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetStance:IStance, targetPts:EllipsoidPointSamples):Number 
	{
		return 1;
	}
	
	
}