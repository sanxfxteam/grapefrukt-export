
package com.grapefrukt.exporter.serializers.data {
	import com.grapefrukt.exporter.animations.Animation;
	import com.grapefrukt.exporter.animations.AnimationFrame;
	import com.grapefrukt.exporter.animations.AnimationMarker;
	import com.grapefrukt.exporter.animations.AnimationPart;
	import com.grapefrukt.exporter.collections.AnimationCollection;
	import com.grapefrukt.exporter.collections.TextureSheetCollection;
	import com.grapefrukt.exporter.misc.Child;
	import com.grapefrukt.exporter.settings.Settings;
	import com.grapefrukt.exporter.textures.BitmapTexture;
	import com.grapefrukt.exporter.textures.FontSheet;
	import com.grapefrukt.exporter.textures.MultiframeBitmapTexture;
	import com.grapefrukt.exporter.textures.TextureBase;
	import com.grapefrukt.exporter.textures.TextureSheet;
	import com.grapefrukt.exporter.textures.VectorTexture;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.geom.Rectangle;
	
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
			if (!s)
				_output.writeUnsignedInt(0);
			else
			{
				_output.writeUnsignedInt(s.length);
				_output.writeUTFBytes(s);
			}
		}
		
		protected function _serialize(target:*) {
			if (target is AnimationCollection)		return serializeAnimationCollection(AnimationCollection(target));
		}

		protected function serializeChild(c:Child) {
			_output.writeUTFBytes('Anch');
			writeString(c.name);
			writeString(c.getSpriteId());
			var r:Rectangle = c.getRect();
			_output.writeFloat(r.width * 0.5);
			_output.writeFloat(r.height * 0.5);
			writeString(c.text);
			_output.writeFloat(c.textsize);
			_output.writeUnsignedInt(c.textalign);
			_output.writeUnsignedInt(c.bgcolor);
		}
		
		protected function serializeAnimationCollection(collection:AnimationCollection) {
			_output.writeUTFBytes('Aprj');
			writeString(collection.name);
			
			var animation:Animation = collection.getAtIndex(0);
			_output.writeUTFBytes('Ancs');
			_output.writeUnsignedInt(animation.parts.length);
			for each (var part:AnimationPart in animation.parts) {
				serializeChild(part.child);
			}
			
			_output.writeUTFBytes('Anco');
			_output.writeUnsignedInt(collection.size);
			for (var i:int = 0; i < collection.size; i++) {
				serializeAnimation(collection.getAtIndex(i));
			}
		}
		
		protected function serializeAnimation(animation:Animation) {
			_output.writeUTFBytes('Anim');
			writeString(animation.name);
			_output.writeUnsignedInt(animation.frameCount);
			_output.writeInt(animation.loopAt);
			
			_output.writeUnsignedInt(animation.markers.length);
			for each (var marker:AnimationMarker in animation.markers) {
				_output.writeUTFBytes('Anma');
				writeString(marker.name);
				_output.writeInt(marker.frame);
			}
			
			_output.writeUnsignedInt(animation.partCount);
			for each (var part:AnimationPart in animation.parts) {
				_output.writeUTFBytes('Anpa');
				writeString(part.name);
				_output.writeUnsignedInt(part.frames.length);
				for (var i:int = 0; i < part.frames.length; i++) {
					serializeAnimationFrame(part.child, part.frames[i]);
				}
			}
		}
		
		protected function serializeAnimationFrame(child:Child, frame:AnimationFrame) {
			var flags:int = 0;
			const F_VISIBLE:int = 1;
			const F_MATRIX:int = 2;
			
			if (frame.visible)
				flags |= F_VISIBLE;
			if (Settings.exportMatrix)
				flags |= F_MATRIX;
			_output.writeUnsignedInt(flags);
			if (frame.visible) {
				var x:Number = frame.x;
				var y:Number = frame.y;
				if (child.spriteid == "TextField")
				{
					x += child.getRect().width * 0.5;
					y += child.getRect().height * 0.5;
				}
				_output.writeFloat(x * 0.5);
				_output.writeFloat(y * 0.5);
				if (Settings.exportMatrix)
				{
					_output.writeFloat(frame.matrix.a);
					_output.writeFloat(-frame.matrix.b);
					_output.writeFloat(-frame.matrix.c);
					_output.writeFloat(frame.matrix.d);
				}
				else
				{
					_output.writeFloat(frame.scaleX);
					_output.writeFloat(frame.scaleY);
					_output.writeFloat(frame.rotation * 0.0174532925);
				}
				_output.writeFloat(frame.alpha);
			}
		}
	
	}

}