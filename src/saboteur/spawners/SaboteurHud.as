package saboteur.spawners 
{
	import alternativa.a3d.cullers.CircleRadiusCuller;
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.a3d.systems.text.StringLog;
	import alternativa.a3d.systems.text.TextBoxChannel;
	import alternativa.a3d.systems.text.TextSpawner;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillCircleMaterial;
	import alternativa.engine3d.materials.FillHudMaterial;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Grid2DMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.RadarGrid2DMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSet;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import ash.core.Engine;
	import assets.fonts.ConsoleFont;
	import de.polygonal.core.event._Observable.Bind; 
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import input.KeyPoll;
	import saboteur.models.PlayerInventory;
	import saboteur.ui.SaboteurHUDLayout;
	import saboteur.util.Saboteur2Deck;
	import saboteur.util.SaboteurActionCard;
	import saboteur.util.SaboteurDeck;
	import saboteur.views.SaboteurMinimap;
	import views.ui.hud.BindDockPin;
	import views.ui.hud.BindLayoutObjCenterScale;
	import views.ui.hud.BindLayoutTextBox;
	import views.ui.text.TextLineInputter;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	import util.SpawnerBundle;
	/**
	 * Consolidating all stuff for HuD and determining number of draw calls used for it
	 * @author Glenn Ko
	 */
	public class SaboteurHud extends SpawnerBundle
	{
		// Radar and minimap stuff
		public var minimapMaterial:TextureMaterial;  // minimap texture
		public var radarMaterial:TextureMaterial;  // circle masked
		public var radarGridMaterial:RadarGrid2DMaterial; 
		private var radarBgMaterial:FillCircleMaterial; 
		public var radarGridSprite:Object3D;
		
		//public var bgOverlayFillMaterial:FillMaterial= new FillMaterial(0x666666, .4);
		public var radar_endPointDead:FillMaterial= new FillMaterial(0xFF0000, 1);
		public var radar_endPointAvailable:FillMaterial= new FillMaterial(0xFF0000, 1);
		
		private var material_icon_canBuild:FillMaterial = new FillMaterial(0xFF0000, 1);

		
		
		// Possible to combine both texture atlases....for single Spriteset, for now, keep it seperate for easy development
		
		// Skin textures for HuD  (for now, leave this out)
		public var skinsSpriteSet:SpriteSet;
		public var skins:TextureAtlasMaterial;  // a texture atlas for the entire skinned UI 
		
		// Icons for HuD
		public var hudMeshSet:SpriteMeshSetClonesContainer;
		public var hudMeshMaterial:TextureAtlasMaterial; //
	
		// The overlays
		
		public var overlays:MeshSet;
		private var overlayRoot:Object3D = new Object3D();
		
		public var circleRadarCuller:CircleRadiusCuller;
		
		// The differnet font settings
		public var txt_numpad:FontSettings;  // these can be baked 1-10, or even put to skin!
		public var txt_chat:FontSettings;	// dynamic text
		public var txt_tips:FontSettings;
		
		public var txt_chatChannel:TextBoxChannel;
		private var layout_chatChannel:BindLayoutTextBox;
		private var overlay_chatChannel:BindLayoutObjCenterScale;
		
		public var txt_tipsChannel:TextBoxChannel;
		private var overlay_tipsChannel:BindLayoutObjCenterScale;
		//private var layout_tipsChannel:BindLayoutTextBox;
		
		private var txt_chatInput:FontSettings;
		private var chatTextInput:TextLineInputter;
		private var keypollToDisable:KeyPoll;
		private var chatInputWidth:Number = 300;
		
		static public const MAX_CHARS:int = 60;
		private var consoleFont:ConsoleFont = new ConsoleFont();
		
		private var txtSpawner:TextSpawner;
		private var _stage:Stage;
		public var playerName:String = "Player";
		public var playerColor:uint = 2;
		
		private var layout:SaboteurHUDLayout;
		
	
		private var stage:Stage;
		
		private var itemSlots:Vector.<SpriteMeshSetClone> = new Vector.<SpriteMeshSetClone>();
		private var itemSet:SpriteMeshSetClonesContainer = new SpriteMeshSetClonesContainer(new Material());
		private var itemSetSlots:Vector.<SpriteMeshSetClone> = new Vector.<SpriteMeshSetClone>(9,true);

		public const BOX_EMPTY:Vector.<Number> = new <Number>[7/8, 0, 1/8, 1/8];
		public const BOX_GRAY:Vector.<Number> = new <Number>[1/8, 0, 1/8, 1/8];
		public const BOX_BLUE:Vector.<Number> = new <Number>[2/8, 0, 1/8, 1/8];
		public const BOX_RED:Vector.<Number> = new <Number>[3/8, 0, 1/8, 1/8];
		public const BOX_GREEN:Vector.<Number> = new <Number>[4/8, 0, 1/8, 1/8];
		public const BOX_PURPLE:Vector.<Number> = new <Number>[5/8, 0, 1/8, 1/8];
		public const BOX_YELLOW:Vector.<Number> = new <Number>[6/8, 0, 1/8, 1/8];
		public const CATEGORIES:Vector.<Vector.<Number>> = new <Vector.<Number>>[null, BOX_GRAY, BOX_BLUE, BOX_RED, BOX_GREEN, BOX_PURPLE, BOX_YELLOW];
		
		public static const DISABLED_PATH_BOX_INDEX:int = 0;
		
		public static const BOX_DARKGRAY:Vector.<Number> = new <Number>[7/8, 1/8, 1/8, 1/8];
		public static const BOX_BRIGHT:Vector.<Number> = new <Number>[7/8, 2/8, 1/8, 1/8];
		public static const BOX_WHITE:Vector.<Number> = new <Number>[1/8, 1/8, 1/8, 1/8];
		static public const ITEM_CUBE_SIZE:Number = 64;
		
		private var hudTextSettings:FontSettings;
		
		
		public function SaboteurHud(engine:Engine, stage:Stage, keypollToDisable:KeyPoll=null) 
		{
			this.engine = engine;
			this.stage = stage;
			
			ASSETS = [SaboteurHudAssets];

			
			super();
		}
		
		public function setupItemTextureSet(pathSheet:TextureAtlasMaterial, minimap:SaboteurMinimap):void {  
		// later: to include action sheet icons or something

			var atlasMaterial:TextureAtlasMaterial = pathSheet.clone() as TextureAtlasMaterial;
		var myBmpData:BitmapData = 	(atlasMaterial.diffuseMap as BitmapTextureResource).data;
		myBmpData = myBmpData.clone();
		myBmpData.threshold(myBmpData, myBmpData.rect, new Point(), "==", 0, 0xFFEEEEEE);
		atlasMaterial.diffuseMap = new BitmapTextureResource(myBmpData);
		atlasMaterial.diffuseMap.upload(context3D);
			atlasMaterial.alphaThreshold = .9;
			atlasMaterial.flags = TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST;
			this.minimap = minimap;
			itemSet.material = atlasMaterial;
		
		}
		
		
		
		private function checkEnter(e:KeyboardEvent):void 
		{
			if (chatTextInput.activated) return; 
			var cc:uint = e.charCode;
			if (e.keyCode === Keyboard.ENTER ) {   // temP??
				
				activateChatInput();
			}
		}
		
		public function setSlot(slotIndex:int, activated:Boolean, category:int):void {
			var targetBox:Vector.<Number>;
			var hudSprite:SpriteMeshSetClone = itemSlots[slotIndex];
			
			
			
			if (activated) {
				if (category > 1) {
					targetBox = CATEGORIES[category];
					hudSprite.u = targetBox[0];
					hudSprite.v = targetBox[1] + targetBox[3];
				}
				else {
					targetBox = BOX_BRIGHT;
					hudSprite.u = targetBox[0];
					hudSprite.v = targetBox[1]; 
				}
				
			}
			else {
				if (category != 0) {
					targetBox = CATEGORIES[category];
					hudSprite.u = targetBox[0];
					hudSprite.v = targetBox[1] ;
				}
				else {
					targetBox = BOX_DARKGRAY;
					hudSprite.u = targetBox[0];
					hudSprite.v = targetBox[1]; 
				}
				
			}
			setActivated(activated, true);
			
		}
		
		public function setEnabledCardSlot(slotIndex:int, enabled:Boolean=true):void {
			var hudSprite:SpriteMeshSetClone = slotIndex >= 0 && slotIndex < itemSlots.length ? itemSlots[slotIndex] : null;
			if (hudSprite != null) {
				if (!enabled) {
					setSlot(slotIndex, false,  SaboteurHud.DISABLED_PATH_BOX_INDEX );
				}
				else {
					
					
				}
			}
		}
		
		private function myInit():void {
			chatTextInput = new TextLineInputter(stage);
			this.keypollToDisable = keypollToDisable;
			normPlane.rotationX = Math.PI;
			
			layout = new SaboteurHUDLayout(stage);
		//	stage.addChild(layout);
			txtSpawner = new TextSpawner(engine);
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkEnter);
		}
		
		override protected function init():void {

			myInit();
			setupText();
			setupHudAssets();
			
			setupTools(); 
			
			
			setupMinimapAndRadar();
			spriteGeometry.upload(context3D);
			
			normPlane.geometry.upload(context3D);
			itemSet.geometry.upload(context3D);
			
			overlays = new MeshSet(overlayRoot);  // TODO: use MeshSetClonesContainer instead
			overlays.setMaterialToAllSurfaces( overlayMaterial);
			//throw new Error(overlays._surfaces.length);
			overlays.geometry.upload(context3D);
			
			super.init();
		}
		
		private function setupHudAssets():void 
		{
			hudBmpData =  new SaboteurHudAssets.$_SHEET().bitmapData;
			var hudResource:BitmapTextureResource = new BitmapTextureResource(hudBmpData);
			hudResource.upload(context3D);
			
			hudMeshMaterial = new TextureAtlasMaterial(hudResource);// null, 1);
			hudMeshMaterial.alphaThreshold = .9;
			
			hudMeshMaterial.flags = TextureAtlasMaterial.FLAG_MIPNONE;  // | TextureAtlasMaterial.FLAG_PIXEL_NEAREST
		
			hudMeshSet = new SpriteMeshSetClonesContainer(hudMeshMaterial);
			hudMeshSet.objectRenderPriority = Renderer.NEXT_LAYER;
			hudMeshSet.name = "hud";
			hudMeshSet.geometry.upload(context3D);
			var sprClone:SpriteMeshSetClone;
			
			sprClone = hudMeshSet.createClone() as SpriteMeshSetClone;
			
			
			var mainItemHud:Object3D = createItemSlots();
			mainItemHud.scaleX = .75;
			mainItemHud.scaleY = .75;
			layout_hudItems =  new BindDockPin(mainItemHud, BindDockPin.BOTTOM, BindDockPin.LEFT);
			layout.onLayoutUpdate.add(layout_hudItems.update);
			_mainItemHud = mainItemHud;
			//layout_hudItems.minCenterY = 480 * .5;

			
			var statusBoxHolder:Object3D = new Object3D();
			layout_topLeft = new BindDockPin(statusBoxHolder, BindDockPin.TOP, BindDockPin.LEFT);
			layout.onLayoutUpdate.add(layout_topLeft.update);
			
			
			var u:Number = BOX_DARKGRAY[0];
			var v:Number = BOX_DARKGRAY[1];
			var w:Number =BOX_DARKGRAY[2];
			var size:Number = w * hudBmpData.width
			var hudSprite:SpriteMeshSetClone = createHudSprite(u, v, w, w, 5 + size, 2 + size * .5);
			
			hudSprite.root._parent = statusBoxHolder;
			hudSprite.root._scaleX *= 2;
			//hudSprite.root._scaleX *= .85;
			hudSprite.root._scaleY *= .85;
			hudMeshSet.addClone(hudSprite);
			
			
			// Build indicator
			var bottomRight:Object3D = new Object3D();
			layout_bottomRight = new BindDockPin(bottomRight, BindDockPin.BOTTOM, BindDockPin.RIGHT);
			layout.onLayoutUpdate.add(layout_bottomRight.update);
			hudSprite = createHudSprite(18 / hudBmpData.width, 411 / hudBmpData.height, 23 / hudBmpData.width, 39 / hudBmpData.height);
			hudSprite.root._x -= 52;
			hudSprite.root._y -= 42;
			hudSprite.root._parent = bottomRight;
			hudMeshSet.addClone(hudSprite);
			
			layout_bottomRightOverlay = new  BindDockPin(bottomRight = getOverlay(), BindDockPin.BOTTOM, BindDockPin.RIGHT);
			layout.onLayoutUpdate.add(layout_bottomRightOverlay.update);
			bottomRight._scaleX = 50;
			bottomRight._scaleY = 46;
			layout_bottomRightOverlay.offsetX = -52;
			layout_bottomRightOverlay.offsetY = -42;
			
			// TODO: numbers and icons for build indicator
			
			// Text 
			var mat:Material = getNewDefaultFontMaterial(0xDDEEAA);

			var blHudTextSpriteSet:SpriteSet;
			hudTextSettings = new FontSettings(consoleFont, mat, blHudTextSpriteSet = getNewTextSpriteSet(20, mat, _textGeometry ), "hudtext" );
			blHudTextSpriteSet.alwaysOnTop = true;
			
			layout_bottomLeftText = new BindDockPin(blHudTextSpriteSet, BindDockPin.BOTTOM, BindDockPin.LEFT);
			layout.onLayoutUpdate.add(layout_bottomLeftText.update);
			
			size *= .75;
			///*
			hudTextSettings.writeData("1",  size * 1 - 4,  -size-16, 2000, false,0);
			hudTextSettings.writeData("2",  size * 2 - 4,  -size-16, 2000, false, 1);
			
			hudTextSettings.writeData("3",  size * 3 - 4,  -size-16,2000, false,2);
			hudTextSettings.writeData("4",  size * 1 - 4,  -size*2-16,2000, false,3);
			hudTextSettings.writeData("5",  size * 2 - 4,  -size*2-16,2000, false,4);
		hudTextSettings.writeData("6",  size * 3 - 4,  -size*2-16,2000, false,5);
			hudTextSettings.writeData("7",  size * 1 - 4,  -size*3-16,2000, false,6);
			hudTextSettings.writeData("8",  size * 2 - 4,  -size*3-16,2000, false,7);
			hudTextSettings.writeData("9",  size * 3 - 4,  -size * 3 - 16, 2000, false, 8);
			
			
			hudTextSettings.writeData("F",  size * 3 - 10,  -16, 2000, false, 9);
			hudTextSettings.writeData("R",  size * 3 - 10,  -38, 2000, false, 10);
			
			//*/
			
			//hudTextSettings.spriteSet.spriteData = new <Number>[45, -67.49996002197265, 0, 0, 0.03515625, 0.1484375, 0.0078125, 0.0703125, 94.49996398925781, -67.49996002197265, 0, 0, 0.046875, 0.1484375, 0.013671875, 0.0703125, 142.49996398925782, -67.49996002197265, 0, 0, 0.064453125, 0.1484375, 0.013671875, 0.0703125, 46.499960021972655, -115.49996002197265, 0, 0, 0.08203125, 0.1484375, 0.013671875, 0.0703125, 94.49996002197265, -115.49996002197265, 0, 0, 0.099609375, 0.1484375, 0.013671875, 0.0703125, 142.49996002197267, -115.49996002197265, 0, 0, 0.1171875, 0.1484375, 0.013671875, 0.0703125, 46.499960021972655, -163.49996002197267, 0, 0, 0.134765625, 0.1484375, 0.013671875, 0.0703125, 94.49996002197265, -163.49996002197267, 0, 0, 0.15234375, 0.1484375, 0.013671875, 0.0703125, 142.49996398925782, -163.49996002197267, 0, 0, 0.169921875, 0.1484375, 0.013671875, 0.0703125, 136.49996002197267, -19.499960021972655, 0, 0, 0.171875, 0.25, 0.013671875, 0.0703125, 136.49996002197267, -41.499960021972655, 0, 0, 0.169921875, 0.3515625, 0.013671875, 0.0703125];
			//throw new Error(hudTextSettings.spriteSet.spriteData);
			
			var str:String;
			
			
			var c:int = _startHudWordIndex = 11 ;
			
			var wordLen:int;
			var totalWordLen:int = 0;
			
			
			
			str = "Build -";
			hudTextSettings.writeData(str, 130, -17, 2000, false, c);
			hudTextSettings.shiftLetterPositions(c, hudTextSettings.boundsCache.length, -hudTextSettings.boundParagraph.get_intervalX(), 0);
			c +=  (wordLen=hudTextSettings.boundsCache.length);
			hudWordIndices.push(totalWordLen + _startHudWordIndex);
			hudWordLengths.push(wordLen);
			totalWordLen += wordLen;
			
			
			str = "Activate -";
			hudTextSettings.writeData(str, 130, -17, 2000, false, c);
			hudTextSettings.shiftLetterPositions(c, hudTextSettings.boundsCache.length, -hudTextSettings.boundParagraph.get_intervalX(), 0);
			c +=  (wordLen = hudTextSettings.boundsCache.length);
			hudWordIndices.push(totalWordLen + _startHudWordIndex);
			hudWordLengths.push(wordLen);
			totalWordLen += wordLen;
			
			
			
			///*
			str = "Exit -";
			hudTextSettings.writeData(str, 130, -38, 2000, false, c);
			hudTextSettings.shiftLetterPositions(c, hudTextSettings.boundsCache.length, -hudTextSettings.boundParagraph.get_intervalX(), 0);
			c += (wordLen=hudTextSettings.boundsCache.length);
			hudWordIndices.push(totalWordLen + _startHudWordIndex);
			hudWordLengths.push(wordLen);
			totalWordLen += wordLen;
			
			//*/
			
			totalHudWordLengths = totalWordLen;
			
			hudTextSettings.spriteSet._numSprites = c;
			
			setActivated(false);
			//throw new Error(hudTextSettings.spriteSet.spriteData);
			
		}
		
		
		public static const HUD_TEXT_BUILD:int = 0;
		public static const HUD_TEXT_ACTIVATE:int = 1;
		public static const HUD_START_LETTER_INDEX:int = 9;
		public static const HUD_LETTER_AMOUNT:int = 2;
		private var hudWordIndices:Vector.<int> = new Vector.<int>();
		private var hudWordLengths:Vector.<int> = new Vector.<int>();
		private var totalHudWordLengths:int;
		private var _startHudWordIndex:int;
		
		
		private function createItemSlots():Object3D {
			var w:Number;
			var v:Number;
			var u:Number;
			var parenter:Object3D = new Object3D();
			var itemDefaultBox:Vector.<Number> = BOX_DARKGRAY;
			u = itemDefaultBox[0];
			v = itemDefaultBox[1];
			w = itemDefaultBox[2];
			
			
			
			var size:Number = w * hudBmpData.width
			for (var y:int = 0; y > -3; y--) {
				for (var x:int = 0; x < 3; x++) {
					var hudSprite:SpriteMeshSetClone = createHudSprite(u, v, w, w, size*.5+ 10+ x * size, -10  -size*1.5+ y * size);
					hudSprite.root._parent = parenter;
					hudMeshSet.addClone(hudSprite);
					itemSlots.push(hudSprite);
				}
			}
			itemSlots.fixed = true;
			
			
			itemDefaultBox = BOX_EMPTY;
			u = itemDefaultBox[0];
			v = itemDefaultBox[1];
			w = itemDefaultBox[2];

			hudSprite =  createHudSprite(u, v, w, w, size * .5 + 10 , -10   -size*1.5 + size);
			hudSprite.root._parent = parenter;
			hudMeshSet.addClone(hudSprite);
			
			// last 2 slots scaleX*2
			hudSprite =  createHudSprite(u, v, w, w, size * 1.5 + 10 , -10   -size*1.5 + size);
			hudSprite.root._parent = parenter;
			hudMeshSet.addClone(hudSprite);
			
			hudSprite.root._scaleX *= 2;
			hudSprite.root._x += size * .5;
			
	
			// black cover
			hudSprite =  createHudSprite(u, v, w, w, size * 1.5 + 10 , -10   -size * 1.5 + size);
			hudSprite.u += w * .5;
			hudSprite.v += w * .5;
			hudSprite.uw = 0;
			hudSprite.vw = 0;
			hudSprite.root._scaleY  -= 10;
			
			
			hudSprite.root._scaleX  -= 20;
			hudSprite.root.x += hudSprite.root._scaleX;
			hudSprite.root._scaleX *= 2;
			
			hudSprite.root.x -= 19;
			hudSprite.root._scaleX += 20;

			
			hudSprite.root._parent = parenter;
			hudMeshSet.addClone(hudSprite);
			

			//  health and stamina bars
			hudSprite = createHudSprite(0,0,size  / hudBmpData.width, size * 4 / hudBmpData.height, size * 0 + 10 + size*.5 , -10   -size*6  );
			hudSprite.root._parent = parenter;
			
			//hudMeshSet.addClone(hudSprite);
			
			_healthBars = hudSprite;
			
			// 
			return parenter;
		}
		
	
		
		public function syncWithInventory(inventory:PlayerInventory):void {  var itemSetSpr:SpriteMeshSetClone;
		// helper method to sync view with inventory model, also needs minimap dependency atm (for now)!
			var capacity:int = inventory.getCapacity();
			var itemHudSprite:SpriteMeshSetClone;
			
			for (var i:int = 0; i < capacity; i++) {
				itemHudSprite = itemSlots[i];
				if (itemHudSprite.index < 0) {
					hudMeshSet.addClone(itemHudSprite);
				}
				
				var category:int = PlayerInventory.getCategoryIndexer(inventory.itemSlots[i]);
				setSlot(i, false, category);
				if (category != 0) { // got item, ensure it's correct icon representation
					itemSetSpr = itemSetSlots[i] || (itemSetSlots[i] = itemSet.getNewSprite());
					
					if (category != PlayerInventory.CATEGORY_PATH) {  // item category
						inventory.itemSlots[i] - inventory.numPathCards;
					}
					else {  // path category
						minimap.setSprJettyUVCoordinatesAndSizeByIndex(  inventory.pathUtil.getIndexByValue( inventory.getPathValueAtSlot(i) ), itemSetSpr );
						itemSetSpr.root._x = itemSlots[i].root._x;
						itemSetSpr.root._y =  itemSlots[i].root._y;
						itemSetSpr.root._scaleX *= 1.25;
						itemSetSpr.root._scaleY *= 1.25;
						itemSetSpr.root._parent = _mainItemHud;
						itemSetSpr.root._rotationZ = 0;// Math.PI * .5;
					}
					itemSetSpr.root._rotationX = Math.PI;
					
					if (itemSetSpr.index < 0) {
						itemSet.addClone(itemSetSpr);
					}
				}
				else {
					itemSetSpr = itemSetSlots[i];
					if (itemSetSpr != null && itemSetSpr.index  >= 0) {
						itemSet.removeClone(itemSetSpr);
						
					}
				}
			}
			itemSet.numClones  = capacity;
			
			var endIndex:int = i;
			while (i < 9) {
				itemHudSprite = itemSlots[i];
				if (itemHudSprite.index >= 0) {
					hudMeshSet.removeClone(itemHudSprite);
				}
				
				i++;
			}
			
			var size:Number = ITEM_CUBE_SIZE;
			var numRows:int = Math.ceil(capacity / 3);
			_healthBars.root._y = -10 - numRows*size - size*3;
			_healthBars.root.transformChanged = true;
			
			
			hudTextSettings.setLetterZ(0, endIndex, 0);
			if (endIndex < 9) {
				hudTextSettings.setLetterZ(endIndex, 9 - endIndex, -1);
			}
			
			//hudTextSettings.setLetterZ(9, 1, -1);
			//hudTextSettings.setLetterZ(10, 1, -1);
			
		}
		
		private function setActivated(activated:Boolean, isPath:Boolean=false):void {
			hudTextSettings.setLetterZ(_startHudWordIndex, totalHudWordLengths, activated ? 0 : -1);
			hudTextSettings.setLetterZ(HUD_START_LETTER_INDEX, HUD_LETTER_AMOUNT,activated ? 0 : -1);
			if (activated) hudTextSettings.setLetterZ( hudWordIndices[isPath ? HUD_TEXT_ACTIVATE : HUD_TEXT_BUILD] , hudWordLengths[isPath ? HUD_TEXT_ACTIVATE : HUD_TEXT_BUILD], -1);		
		}
		
		
		private function createHudSprite(u:Number, v:Number, uw:Number, vw:Number, x:Number = 0, y:Number = 0 ):SpriteMeshSetClone {


			var sprClone:SpriteMeshSetClone = hudMeshSet.createClone() as SpriteMeshSetClone;
			sprClone.u = u;
			sprClone.v = v;
			sprClone.uw = uw;
			sprClone.vw = vw;
			sprClone.root._scaleX = uw * hudBmpData.width;
			sprClone.root._scaleY = vw * hudBmpData.height;
			sprClone.root._rotationX = Math.PI;
			sprClone.root._x = x;
			sprClone.root._y = y;
			sprClone.root.transformChanged = true;
			return sprClone;
		}
		
		private function setupMinimapAndRadar():void 
		{
			radarHolder = new Object3D();
			radarGridHolder = new Object3D();
			radarHolder.addChild(radarGridHolder);
			radarGridMaterial = new RadarGrid2DMaterial(0x000000, .99999, 32, JettySpawner.H );
			
			radarGridMaterial.gridCoordinates.width =  12;
			radarGridMaterial.gridCoordinates.height = radarGridMaterial.gridSquareWidth/radarGridMaterial.gridSquareHeight * (radarGridMaterial.gridCoordinates.width);
				
			
			
			radarGridMaterial.lineThickness = 1.0;
			var rw:Number;
			var rh:Number;
			radarGridSprite = getNormalSpritePlane(radarGridMaterial, rw=radarGridMaterial.gridCoordinates.width * radarGridMaterial.gridSquareWidth, rh=radarGridMaterial.gridCoordinates.height * radarGridMaterial.gridSquareHeight); // new Sprite3D(radarGridMaterial.gridCoordinates.width * radarGridMaterial.gridSquareWidth, radarGridMaterial.gridCoordinates.height * radarGridMaterial.gridSquareHeight, radarGridMaterial);
		
			//	uploadResources(radarGridSprite.getResources());
			radarGridSprite.z = -.01;
		//	radarGridHolder.addChild( new Sprite3D(rw, rh, radarGridMaterial));
		
			
			//var layouterRadar:BindLayoutObjCenterScale;
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, radarGridSprite, false).update);
			//new BindLayoutObjCenterScale(, radarGridSprite, false)
			
			
			
			radarBgMaterial = new FillCircleMaterial(0xFFFFFF, 1);
			radarGridBg = getNormalSpritePlane(radarBgMaterial, rw, rh);
			
			radarGridBg.z = 0;

			
			radarHolder.scaleX = .5;
			radarHolder.scaleY = .5;
			
			

			radarHolder.addChild(radarGridBg);
			radarHolder.addChild(radarGridSprite);
			radarHolder.rotationX = Math.PI;
			layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, radarHolder, false).update);
			
			circleRadarCuller = new CircleRadiusCuller(rw*.5, radarGridHolder);
			
			
			radarBlueprintOverlay = getNormalSpritePlane(new FillHudMaterial(0xFF0000, 1), radarGridMaterial.gridSquareWidth, radarGridMaterial.gridSquareHeight);
			radarBlueprintOverlay.z = 0;
			radarBlueprintOverlay.visible = true;
			radarGridHolder.addChild(radarBlueprintOverlay);
			//minimap = new SaboteurMinimap(
		}
		
		private function getNormalPlane(mat:Material, scaleX:Number,scaleY:Number):Mesh {
			var mesh:Mesh = normPlane.clone() as Mesh;
			mesh.setMaterialToAllSurfaces(mat);
			mesh.scaleX = scaleX;
			mesh.scaleY = scaleY;
			return mesh;
		}
		
		
		private var spriteGeometry:Geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(1, 0, 1, .5);
		private function getNormalSpritePlane(mat:Material, scaleX:Number, scaleY:Number):Mesh {
			var mesh:Mesh = new Mesh();
			mesh.geometry = spriteGeometry;
			mesh.scaleX = scaleX;
			mesh.scaleY = scaleY;
			//mesh.rotationX = Math.PI;
			mesh.addSurface(mat, 0, 2);
			return mesh;
		}
		
		public var overlayMaterial:FillMaterial = new FillMaterial(0x000000, .25);
		private var normPlane:Plane = new Plane(1,1,1,1,false,false,overlayMaterial, overlayMaterial);

		private var engine:Engine;
		private var radarGridBg:Mesh;
		private var hudBmpData:BitmapData;
		private var layout_hudItems:BindDockPin;
		private var layout_topLeft:BindDockPin;
		private var layout_bottomRight:BindDockPin;
		private var _textGeometry:Geometry;
		private var layout_bottomLeftText:BindDockPin;
		private var layout_bottomRightOverlay:BindDockPin;
		private var minimap:SaboteurMinimap;
		private var _healthBars:SpriteMeshSetClone;
		private var _mainItemHud:Object3D;
		public var radarBlueprintOverlay:Mesh;
		public var radarHolder:Object3D;
		public var radarGridHolder:Object3D;
		
		private function getOverlay():Object3D {
			return overlayRoot.addChild( normPlane.clone() );
		}
		
	
		
		private function activateChatInput():void {
					if (keypollToDisable != null) {
				keypollToDisable.disable();
			}
			chatTextInput.activate();
	
			
			//  this will automaticlaly write
			txt_chatInput.writeFinalData("|", 0, 0, chatInputWidth, false, 0);
		}
		private function deactivateChatInput():void {
			chatTextInput.deactivate();
			if (keypollToDisable != null) {
				keypollToDisable.enable();
			}
		}
		
		// Utility to bind layout AABBs against Object3D position or (Start Index position on SpriteData, with optional layouting sceheme with range or custom method ). 
		public function layoutItems():void {
			
		}
		
		public function addToHud3D(obj:Object3D):void {

			// overlays
			obj.addChild(hudTextSettings.spriteSet);
			obj.addChild(itemSet); 
			itemSet.objectRenderPriority = Renderer.NEXT_LAYER;
			
			obj.addChild(overlays);
			// tools
			
			// minimap and radar
		//	obj.addChild(radarGridSprite);
			obj.addChild(radarHolder);
			obj.addChild(hudMeshSet);
			//obj.addChild(radarGridSprite);
			
			// text
			obj.addChild(txt_tips.spriteSet);
			obj.addChild(txt_numpad.spriteSet);
			obj.addChild(txt_chat.spriteSet);
			obj.addChild(txt_chatInput.spriteSet);
			
			
			
		}
		
		public function writeChatText(text:String):void {
			txt_chatChannel.appendMessage(text);
		}
		public function writeTipText(text:String):void {
			txt_tipsChannel.appendMessage(text);
		}
		
		/*
		public function refreshChatText():void {
			txt_chatChannel.refresh();
		}
		public function refreshTipText():void {
			txt_tipsChannel.refresh();
		}
		*/
		
		
		
		private function setupText():void 
		{
			consoleFont.bmpResource.upload(context3D);
			chatTextInput.glyphRange = consoleFont.fontV._glyphRange;
			
			var geom:Geometry  = SpriteGeometryUtil.createNormalizedSpriteGeometry(MAX_CHARS, 0, 1, 1, 0, 0, 2);
			_textGeometry = geom;
			geom.upload(context3D);
			
			
			var mat:Material;
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_numpad = new FontSettings(consoleFont, mat , getNewTextSpriteSet(10, mat, geom) );
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_tips = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_tipsChannel = new TextBoxChannel(new <FontSettings>[txt_tips], 5, 10, 3);
			//overlay_tipsChannel = new BindLayoutObjCenterScale(layout.contLeft.validateAABB, getOverlay());
			//layout.onLayoutUpdate.add(overlay_tipsChannel.update);
			
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contMiddleLeft.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopLeft.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contRight.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contLeft.validateAABB, getOverlay()).update);
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_chat = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_chatChannel = new TextBoxChannel(new <FontSettings>[txt_chat], 5, 10, 3);
			txt_chatChannel.timeout = -1;
			txt_chatChannel.history = new StringLog();
			txt_chatChannel.lineSpacing = 10.2;
			txt_chatChannel.vSpacing = 4;
			layout_chatChannel = new BindLayoutTextBox(layout.contTop.validateAABB, txt_chatChannel.styles[0].spriteSet, txt_chatChannel, 8, 4, 0, 0);
			layout.onLayoutUpdate.add(layout_chatChannel.update);
		//	overlay_chatChannel = new BindLayoutObjCenterScale(layout.contTop.validateAABB, getOverlay());
		//	layout.onLayoutUpdate.add(overlay_chatChannel.update);
			
			txt_chatInput = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			
			chatTextInput.onTextChange.add( onChatTextChange);
			chatTextInput.onTextCommit.add( onChatTextCommit);
			chatTextInput.onTextEscape.add( onChatTextESC);
			
			txtSpawner.addTextBoxChannel( txt_chatChannel);
			txtSpawner.addTextBoxChannel( txt_tipsChannel);
			
		}
		
		private function onChatTextCommit(str:String):void 
		{
			if (str != "" ) { 
				
				txt_chatChannel.appendSpanTagMessage('<span u="'+playerColor+'">'+ playerName+': </span><![CDATA['+str+']]>');
			//	txt_chatChannel.refresh();
			}
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextESC(str:String):void 
		{	
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextChange(str:String):void 
		{
			// todo: bind width to layout
			txt_chatInput.writeFinalData(str+"|", 0, 0, chatInputWidth, false, 0);
		}
		
		private function getNewFontMaterial(color:uint):MaskColorAtlasMaterial {
			var mat:MaskColorAtlasMaterial =  new MaskColorAtlasMaterial(consoleFont.bmpResource);
			mat.transparentPass = false;
			mat.color = color;
			mat.alphaThreshold = .8;
			mat.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		private function getNewDefaultFontMaterial(color:uint):TextureAtlasMaterial {
			var mat:TextureAtlasMaterial =  new TextureAtlasMaterial(consoleFont.bmpResource);
			//mat.transparentPass = false;
			mat.alphaThreshold =.8;
			mat.flags = (TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		
		private function getNewTextSpriteSet(estimatedMaxChars:int, material:Material, geom:Geometry):SpriteSet {
			var spr:SpriteSet = new SpriteSet(0, true, material, consoleFont.bmpResource.data.width, consoleFont.bmpResource.data.height, estimatedMaxChars, 2 );
			
			return spr;
		}
		
		private function setupTools():void 
		{
			
		}

		
	}

}