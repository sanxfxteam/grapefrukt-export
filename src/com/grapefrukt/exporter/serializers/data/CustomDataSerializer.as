﻿
package com.grapefrukt.exporter.serializers.data {
	import com.grapefrukt.exporter.animations.Animation;
	import com.grapefrukt.exporter.animations.AnimationFrame;
	import com.grapefrukt.exporter.animations.AnimationMarker;
	import com.grapefrukt.exporter.animations.AnimationPart;
	import com.grapefrukt.exporter.collections.AnimationCollection;
	import com.grapefrukt.exporter.collections.TextureSheetCollection;
	import com.grapefrukt.exporter.settings.Settings;
	import com.grapefrukt.exporter.textures.BitmapTexture;
	import com.grapefrukt.exporter.textures.FontSheet;
	import com.grapefrukt.exporter.textures.MultiframeBitmapTexture;
	import com.grapefrukt.exporter.textures.TextureBase;
	import com.grapefrukt.exporter.textures.TextureSheet;
	import com.grapefrukt.exporter.textures.VectorTexture;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Massive Finger's Anim Export
	 */
	public class CustomDataSerializer extends BaseDataSerializer implements IDataSerializer  {
		
		protected var _output:ByteArray;
		
		public function serialize(target:*, useFilters:Boolean = true):ByteArray {
			_output = new ByteArray;
			_output.endian = Endian.LITTLE_ENDIAN;
			_serialize(target);
			return _output;
		}
		
		protected function writeString(s:String) {
			_output.writeUnsignedInt(s.length);
			_output.writeUTFBytes(s);	
		}
		
		/**
		* Replace all by RegEx;
		*/
		public static function replaceAll(strSource:String, strReplaceFrom:String, strReplaceTo:String):String {
			return strSource == null ? null : strSource.replace(new RegExp(strReplaceFrom, 'g'), strReplaceTo);
		}
		
		protected function _serialize(target:*) {
		
			if (target is Animation)				return serializeAnimation(Animation(target));
			if (target is AnimationCollection)		return serializeAnimationCollection(AnimationCollection(target));
			if (target is AnimationFrame)			return serializeAnimationFrame(AnimationFrame(target));
		}
		
		protected function serializeAnimationCollection(collection:AnimationCollection) {
			collection.sort();
			_output.writeUTFBytes('Anco');
			_output.writeUnsignedInt(collection.size);
			for (var i:int = 0; i < collection.size; i++) {
				_serialize(collection.getAtIndex(i));
			}
		}
		
		protected function serializeAnimation(animation:Animation) {
			_output.writeUTFBytes('Anim');
			writeString(animation.name);
			_output.writeUnsignedInt(animation.frameCount);
			_output.writeInt(animation.loopAt);
			_output.writeUnsignedInt(animation.partCount);
			
			animation.sort();
			
			for each (var part:AnimationPart in animation.parts) {
				_output.writeUTFBytes('Anpa');
				writeString(part.name);
				writeString(part.getSpriteId());
				_output.writeUnsignedInt(part.frames.length);
				for (var i:int = 0; i < part.frames.length; i++) {
					_serialize(part.frames[i]);
				}
			}
		}
		
		protected function serializeAnimationFrame(frame:AnimationFrame) {
			var flags:int = 0;
			const F_VISIBLE:int = 1;
			
			if (frame.visible)
				flags |= F_VISIBLE;
				
			_output.writeUnsignedInt(flags);
			if (frame.visible) {
				_output.writeFloat(frame.x * 0.5);
				_output.writeFloat(frame.y * 0.5);
				_output.writeFloat(frame.scaleX);
				_output.writeFloat(frame.scaleY);
				_output.writeFloat(frame.rotation * 0.0174532925);
				_output.writeFloat(frame.alpha);
			}
		}
	
	}

}