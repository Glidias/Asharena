package systems.player.a3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationNotify;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.animation.events.NotifyEvent;
	import alternativa.engine3d.animation.keys.Keyframe;
	import alternativa.engine3d.animation.keys.NumberKey;
	import alternativa.engine3d.animation.keys.NumberTrack;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.animation.keys.TransformKey;
	import alternativa.engine3d.animation.keys.TransformTrack;
	import alternativa.engine3d.core.Object3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;

	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * A model blueprint / switcher for animation state 
	 * @author Glidias
	 */
	public class AnimationManager implements IExternalizable
	{
		public var animClips:Vector.<AnimationClip>;
		private var animGroups:Vector.<Vector.<int>>;	
		private var switcher:AnimationSwitcher;
		private var _fixed:Boolean;
		
		public function AnimationManager(animClips:Vector.<AnimationClip>=null, animGroups:Vector.<Vector.<int>>=null, fixed:Boolean=true, animEndLoops:Dictionary=null) 
		{
			animEndLoops = animEndLoops || new Dictionary();
			if (animClips != null) init(animClips, animGroups, fixed);
		}
		
		private function init(animClips:Vector.<AnimationClip>, animGroups:Vector.<Vector.<int>>=null, fixed:Boolean=true):void {
			this.animClips = animClips;
			this.animGroups = animGroups;
		
			// initSwitcher
			var len:int = animClips.length;
			switcher = new AnimationSwitcher();
			for (var i:int = 0; i < len; i++) {
				switcher.addAnimation(animClips[i]);
			}
			
			_fixed = fixed;
		}
		
		
		/* INTERFACE flash.utils.IExternalizable */
		
		public function writeExternal(output:IDataOutput):void 
		{
			output.writeBoolean( _fixed);
			
			
			var i:int;
			var len:int = animClips.length;  
			output.writeByte(len);
			for (i = 0; i < len; i++) {
				writeAnimationClip( animClips[i] , output);
			}
		
		
			output.writeBoolean( animGroups != null);
			if (animGroups != null) writeAnimationGroups(output);

		}
		

		private function writeAnimationGroups(output:IDataOutput):void {
			var len:int = animGroups.length;
			output.writeByte(len);
			for (var i:int = 0; i < len; i++) {
				var anims:Vector.<int> = animGroups[i];
				if (anims == null) {
					output.writeByte(0);
					continue;
				}
				var uLen:int = anims.length;
				output.writeByte(uLen);
				for (var u:int=0; u < uLen; u++) {
					output.writeByte(anims[u]);
				}
			}
		}
		private function readAnimationGroups(input:IDataInput, fixed:Boolean):Vector.<Vector.<int>> {
			var len:int = input.readByte();
			var animGroups:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(len, fixed);
			for (var i:int = 0; i < len; i++) {
				var uLen:int = input.readByte();
				if (uLen <= 0) continue;
				var anims:Vector.<int> = new Vector.<int>(uLen, fixed);
				animGroups[i] = anims;
				for (var u:int=0; u < uLen; u++) {
					anims[u] = input.readByte();
				}
			}
			return animGroups;
		}
		
		public function readExternal(input:IDataInput):void 
		{
			var fixed:Boolean = input.readBoolean();
			
			var len:int = input.readByte();
			animClips =  new Vector.<AnimationClip>(len);
			for (var i:int = 0; i < len; i++) {
				animClips[i] = readAnimationClip(input);
			}
		
			animGroups = input.readBoolean() ? readAnimationGroups(input, fixed) : null;
		
			init(animClips, animGroups, fixed );
		}
		
		
		// Parse from XML
		
		public static function fromAnimationAndXML(animation:AnimationClip, animXML:XML, animFPS:int=0, tableLookup:Vector.<String>=null):AnimationManager {
			var animManager:AnimationManager;	
			var animList:XMLList = animXML..a;
			if (animFPS == 0) animFPS = animXML.@fps != undefined ? Number(animXML.@fps) || 24 : 24;
			var useAnimLoop:Boolean = animXML.@loop == "true" || animXML.@loop == "false" ? animXML.@loop == "true" : animation.loop;
			var len:int;
			var i:int;

			var animations:Vector.<AnimationClip> = new Vector.<AnimationClip>();
			
			len = animList.length()
			for (i = 0; i < len; i++) {
				var xml:XML = animList[i];
				var sa:Array = xml.@f.split("-");
				var sa_1:Number = Number(sa[0]);
				var sa_2:Number = Number(sa[1]);
				var newAnim:AnimationClip = animation.slice( (sa_1 <= 1 ? 0 : sa_1) / animFPS, sa_2 / animFPS);
				var notifyList:XMLList = xml.n;
				var uLen:int = notifyList.length();
				for (var u:int = 0; u < uLen; u++) {
					var uXML:XML = notifyList[u];
					newAnim.addNotify((Number(uXML)-sa_1)/animFPS , uXML.@id);
				}
			//	var useFPS:Number = xml.@fps != undefined ? Number(xml.@fps) : animFPS;
				newAnim.speed = 1;// Math.round(newAnim.length * animFPS) / useFPS; 
				newAnim.name = xml.@id;
				
				newAnim.loop = xml.@loop == "true" || xml.@loop == "false" ? xml.@loop == "true" : useAnimLoop;
				
				//if (newAnim.loop && uLen > 0) new AnimEndLoop(newAnim);  // todo: determine context from which..
				
				newAnim.name = animList[i].@id;
				animations[i] = newAnim;	
			}
			
			animManager = new AnimationManager(animations, null, true);
			animManager.setupAnimGroups(animXML, tableLookup);
			return animManager;
		}
		
		public function cloneAnimation(toClone:AnimationClip):AnimationClip {
			var newAnim:AnimationClip = toClone.clone();
			newAnim.loop = toClone.loop;
			newAnim.speed = toClone.speed;
			newAnim.time = 0;
			return newAnim;
		}
		
		
		public function switchAnim(animation:AnimationClip, time:Number) : void {
			_currentAnim = animation;
			switcher.activate(animation, time);
		}
		
		
		public function setupAnimGroups(xml:XML, tableLookup:Vector.<String>=null):void {
			var xmlList:XMLList = xml..a.(hasOwnProperty("@g"));
		
			var len:int = xmlList.length();
			if (len == 0) return;
			
			
			var dict:Dictionary = new Dictionary();
			var i:int;
	
			animGroups = tableLookup != null ? new Vector.<Vector.<int>>(tableLookup.length) : new Vector.<Vector.<int>>();
			var intList:Vector.<int>;
			for (i = 0; i < len; i++) {
				xml = xmlList[i];
				var prop:String = xml.@g != undefined ? xml.@g : null;
				if (prop == null) continue;
				intList = dict[prop];
				if (intList == null) {
					intList = new Vector.<int>();
					dict[prop] = intList;
					if (tableLookup == null) animGroups.push(intList)
					else animGroups[tableLookup.indexOf(prop)] = intList;
				}
				intList.push(getAnimationIndexByName(xml.@id));
			}
			
			len = animGroups.length;
			for (i = 0; i < len; i++ ) {
				intList = animGroups[i];
				if (intList == null) {
					//animGroups[i] = intList = new <int>[0];
				}
				else intList.fixed = _fixed;
			}
			
			animGroups.fixed = _fixed;
		}
		

		private var _alreadySetup:Boolean = false;
		
		
		public function setupFor(target:Object):void {
			if (_alreadySetup) return;
			_alreadySetup = true;
			var len:int = animClips.length;

			for (var i:int = 0; i < len; i++) {
				var oldAnim:AnimationClip =  animClips[i];
				
				oldAnim.attach(target, true);
			}
		}
		
		public function cloneFor(target:Object):AnimationManager {
			var len:int = animClips.length;
			var newClips:Vector.<AnimationClip> = new Vector.<AnimationClip>(len);
			var dictEndLoops:Dictionary = new Dictionary();
			var newC:AnimationClip;
			for (var i:int = 0; i < len; i++) {
				var oldAnim:AnimationClip =  animClips[i];
				newClips[i] = newC = oldAnim.clone();
				//if (newC.loop != oldAnim.loop) throw new Error("LOOP MISMATCH!");
				newC.loop = oldAnim.loop;
				//if (newC.speed != oldAnim.speed) throw new Error("SPEED MISMATCH!");
				newC.speed = oldAnim.speed;
				var chkNotifiers:Vector.<AnimationNotify> = oldAnim.notifiers;
				var nLen:int = chkNotifiers.length;
				for (var n:int = 0; n < nLen; n++) {
					var notifier:AnimationNotify = chkNotifiers[n];
		
					newC.addNotify( notifier.time, notifier.name);
				}
				if (newC.loop && nLen > 0 ) dictEndLoops[newC.name] = new AnimEndLoop(newC);
				newC.time = 0;
				//newC.speed
				newC.attach(target, true);
			}
			return new AnimationManager(newClips, animGroups, _fixed, dictEndLoops);
		}
		
		
		
		
		public static var MANAGERS:Dictionary = new Dictionary();
	
		
		public var _currentAnim:AnimationClip;
		
		public static function getAnimManagerByKey(key:*):AnimationManager {
			return MANAGERS[key] || (new AnimationManager(new <AnimationClip>[],null,false));
		}
		public static function registerAnimManager(key:*, rootInstance:AnimationManager):void {
			MANAGERS[key] = rootInstance;
		}
		
		/**
		 * Plays a certain random animation from a group category
		 * @param	index	Category index
		 * @param	time	The time to transition to animation
		 * @return	True if animation is found, or False if no animation found
		 */
		public function playGroup(index:int, time:Number):AnimationClip {
			if (animGroups == null) return null;
			var anim:AnimationClip = getAnimationFromGroup(index);
			if (anim == null) return null;
			_currentAnim = anim;
			switcher.activate(anim , time);
			return anim;
		}
		
		public function getAnimationFromGroup(index:int):AnimationClip {
			//if (animGroups == null) throw new Error("IS NULL!");
			var listAnims:Vector.<int> = animGroups[index];
			return listAnims!= null ? animClips[ listAnims[int(Math.random() * listAnims.length)] ] : null;
		}		
		
		public function getAnimationGroup(index:int):Vector.<int> {
			if (animGroups == null || (index >=animGroups.length)) return null;
			return animGroups[index];
		}
		
		public function getAnimationsByGroup(index:int):Vector.<AnimationClip> {
			var vec:Vector.<AnimationClip> = new Vector.<AnimationClip>();
			var animGroups:Vector.<int> =  getAnimationGroup(index);
			if (animGroups == null) return vec;
			var len:int = animGroups.length;
			for (var i:int = i; i < len; i++) {
				vec[i] = animClips[animGroups[i]];
			}
			vec.fixed = _fixed;
			return vec;
		}

		
		public function getAnimationByName(name:String):AnimationClip {
			var i:int = animClips.length; 
			while (--i > -1) {
				var animClip:AnimationClip = animClips[i];
				if (animClip.name === name) return animClip;
			}
			throw new Error("FAILED TO GET ANIMATION!"+name);
			return null;
		}
		
		public function getAnimationIndexByName(name:String):int {
			var i:int = animClips.length;
			while (--i > -1) {
				if (animClips[i].name === name) return i;
			}
			return -1;
		}
		
		public function getSwitcher():AnimationSwitcher 
		{
			return switcher;
		}
		
		public function get fixed():Boolean 
		{
			return _fixed;
		}
		
		public function get currentAnim():AnimationClip 
		{
			return _currentAnim;
		}
		
		
		
		// --Serialization helpers
		
		private function writeNotifiers(vec:Vector.<AnimationNotify>, output:IDataOutput):void {
			var len:int = vec.length;
			output.writeByte(len);
			for (var i:int = 0; i < len; i++) {
				var anim:AnimationNotify = vec[i];
				output.writeFloat(anim.time);
				output.writeObject(anim.name != null ? anim.name : "0");
			};
		}
		
		private function readNotifiers(input:IDataInput, clip:AnimationClip):void {
			var len:int = input.readByte();
			if (len == 0 ) return;
			for (var i:int = 0; i < len; i++) {
				var time:Number = input.readFloat();
				clip.addNotify(time, input.readObject() );
			};
			if (clip.loop) new AnimEndLoop(clip);
		}
		
		private function writeAnimationClip(anim:AnimationClip, output:IDataOutput):void {
				var uLen:int;
				
				output.writeObject(anim.name);
				output.writeBoolean(anim.loop);	
				//output.writeFloat(anim.length);  // speed
			
				
				uLen = anim.numTracks;
				output.writeShort(uLen);
				for (var u:int = 0; u < uLen; u++) {
					var track:Track = anim.getTrackAt(u);  // is't the case, could be NUmberTrack or various other trakc types
					output.writeBoolean( track is TransformTrack );
					
					if (track is TransformTrack) {
						writeTransformTrack(track as TransformTrack, output);	
					}
					else if (track is NumberTrack) {
						writeNumberTrack(track as NumberTrack, output);
					}
					else  {
						throw new Error("Could not resolve track type!");
					}
				}
				
				var notifiers:Vector.<AnimationNotify> = anim.notifiers;
				if (notifiers != null) {
					writeNotifiers(notifiers, output);
				}
				else output.writeByte(0);
		}	
		
		
		private function readAnimationClip(input:IDataInput):AnimationClip {
			var anim:AnimationClip;
			anim =  new AnimationClip( input.readObject() );
			anim.loop = input.readBoolean();
			//anim.length = input.readFloat();  // speed
			
			
			var uLen:int = input.readShort();
			for (var u:int = 0; u < uLen; u++) {
				anim.addTrack( input.readBoolean() ? readTransformTrack(input) : readNumberTrack(input) );
			}	
			
			readNotifiers(input, anim);
			
			return anim;
		}
		
		private function writeNumberTrack(numberTrack:NumberTrack, output:IDataOutput):void 
		{
			output.writeObject( numberTrack.object );
			output.writeObject( numberTrack.property );
			var key:NumberKey;
			var count:int = 0;
			for (key = numberTrack.keyList; key != null; key = key.next) {
				count++;
			}
			output.writeShort(count);
		
			for ( key = numberTrack.keyList; key != null; key = key.next) {
				output.writeFloat(key._time);
				output.writeFloat(key._value);
			}
		}
		
		private function readNumberTrack(input:IDataInput):NumberTrack {
			var track:NumberTrack = new NumberTrack(input.readObject(), input.readObject() );
			var len:int = input.readShort();
			for (var i:int = 0; i < len; i++) {
				track.addKey(input.readFloat(), input.readFloat() );
			}
			return track;
		}
		
		private function writeTransformTrack(transformTrack:TransformTrack, output:IDataOutput):void 
		{
			
			output.writeObject(transformTrack.object);
			
			var keys:Vector.<Keyframe> = transformTrack.keys;
			if (keys == null) throw new Error("COuld not find keys!");
			var len:int = keys.length;
			output.writeShort(len);
			
			for (var i:int = 0; i < len; i++) {
				var tKey:TransformKey = keys[i] as TransformKey;
				if (tKey == null) throw new Error("COudl not find TransformKey:" + tKey);
				var matrix3D:Matrix3D = tKey.value as Matrix3D;
				if (matrix3D == null) throw new Error("Could not find matrix!");
				
				output.writeFloat( tKey._time);
				
				//writeMatrix3D( matrix3D, output); 
				writeComponentsFromMatrix3D(matrix3D, output);
				//writeKeyComponents(tKey, output);
			}
		}
		
		private function writeKeyComponents(transformKey:TransformKey, output:IDataOutput):void {
			output.writeFloat(transformKey.x);
			output.writeFloat(transformKey.y);
			output.writeFloat(transformKey.z);
			output.writeFloat(transformKey.rotation.x);
			output.writeFloat(transformKey.rotation.y);
			output.writeFloat(transformKey.rotation.z);
		}
		
		private function writeMatrix3D(matrix:Matrix3D, output:IDataOutput):void {
			var data:Vector.<Number> = matrix.rawData;
			output.writeFloat(data[0]);
			output.writeFloat(data[1]);
			output.writeFloat(data[2]);
			output.writeFloat(data[3]);
			output.writeFloat(data[4]);
			output.writeFloat(data[5]);
			output.writeFloat(data[6]);
			output.writeFloat(data[7]);
			output.writeFloat(data[8]);
			output.writeFloat(data[9]);
			output.writeFloat(data[10]);
			output.writeFloat(data[11]);
			output.writeFloat(data[12]);
			output.writeFloat(data[13]);
			output.writeFloat(data[14]);
			output.writeFloat(data[15]);
		}
		
		public function writeComponentsFromMatrix3D(matrix:Matrix3D, output:IDataOutput):void {
			// hmm.. may need to transpose.
			
			var vec:Vector.<Vector3D> = matrix.decompose();
			var v:Vector3D;
			v = vec[0];
			output.writeFloat(v.x);
			output.writeFloat(v.y);
			output.writeFloat(v.z);
			
			v = vec[1];
			output.writeFloat(v.x);
			output.writeFloat(v.y);
			output.writeFloat(v.z);
		}
		
		public function getAnimGroups():Vector.<Vector.<int>> 
		{
			return animGroups;
		}
		
		
		
		private function readMatrix3D(input:IDataInput):Matrix3D {
			var data:Vector.<Number> = new Vector.<Number>(16, true);
			data[0] = input.readFloat();
			data[1] = input.readFloat();
			data[2] = input.readFloat();
			data[3] = input.readFloat();
			data[4] = input.readFloat();
			data[5] = input.readFloat();
			data[6] = input.readFloat();
			data[7] = input.readFloat();
			data[8] = input.readFloat();
			data[9] = input.readFloat();
			data[10] = input.readFloat();
			data[11] = input.readFloat();
			data[12] = input.readFloat();
			data[13] = input.readFloat();
			data[14] = input.readFloat();
			data[15] = input.readFloat();
			return new Matrix3D(data);
		}
		
		private function readTransformTrack(input:IDataInput):TransformTrack {
			var track:TransformTrack = new TransformTrack(input.readObject());
			var len:int = input.readShort();
			for (var i:int = 0; i < len; i++) {
				//track.addKey(input.readFloat(), readMatrix3D(input)  );
				track.addKeyComponents(input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat(), input.readFloat());
			}
			return track;
		}
		
		
	}

}