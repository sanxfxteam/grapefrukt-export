/*
Copyright 2011 Martin Jonasson, grapefrukt games. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY grapefrukt games "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL grapefrukt games OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of grapefrukt games.
*/

package com.grapefrukt.exporter.serializers.data {
	import com.grapefrukt.exporter.animations.Animation;
	import com.grapefrukt.exporter.animations.AnimationFrame;
	import com.grapefrukt.exporter.animations.AnimationMarker;
	import com.grapefrukt.exporter.animations.AnimationPart;
	import com.grapefrukt.exporter.misc.Child;
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
	import flash.geom.Rectangle;
	import fl.motion.MatrixTransformer;
	
	
	/**
	 * ...
	 * @author Martin Jonasson, m@grapefrukt.com
	 */
	public class XMLDataSerializer extends BaseDataSerializer implements IDataSerializer  {
		
		public function serialize(target:*, useFilters:Boolean = true):ByteArray {
			var xml:XML = _serialize(target);
			var ba:ByteArray = new ByteArray;
			ba.writeUTFBytes(xml.toXMLString());
			
			if (useFilters) return filter(ba);
			return ba;
		}
		
		protected function _serialize(target:*):XML {

			if (target is Animation)				return serializeAnimation(Animation(target));
			if (target is AnimationCollection)		return serializeAnimationCollection(AnimationCollection(target));
			if (target is AnimationFrame)			return serializeAnimationFrame(AnimationFrame(target));
			
			throw new Error("no code to serialize " + target);
			return null;
		}

		protected function serializeChild(c:Child) {
			var partXML:XML = <Element></Element>;
			partXML.@name = c.name;
			partXML.@spriteid = c.getSpriteId();
			var r:Rectangle = c.getRect();
			partXML.@rectwidth = r.width;
			partXML.@rectheight = r.height;
			if (c.text) partXML.@text = c.text;
			if (c.textsize) partXML.@textsize = c.textsize;
			if (c.textalign) partXML.@textalign = c.textalign;
			if (c.bgcolor) partXML.@bgcolor = c.bgcolor;
			return partXML;
		}
		
		protected function serializeAnimationCollection(collection:AnimationCollection):XML {
			var res:XML = <All></All>;
			res.@name = collection.name;
			
			var elts:XML = <Elements></Elements>;
			var animation:Animation = collection.getAtIndex(0);
			for each (var part:AnimationPart in animation.parts) {
				elts.appendChild(serializeChild(part.child));
			}
			res.appendChild(elts);
			
			var xml:XML = <Animations></Animations>;
			for (var i:int = 0; i < collection.size; i++) {
				xml.appendChild(_serialize(collection.getAtIndex(i)));
			}
			res.appendChild(xml);
			return res;
		}
		
		protected function serializeAnimation(animation:Animation):XML {
			var xml:XML = <Animation></Animation>;
			xml.@name 		= animation.name;
			xml.@frameCount = animation.frameCount;
			if (animation.loopAt != -1) 							xml.@loopAt = animation.loopAt;
			if (animation.mask) 									xml.@mask	= animation.mask;
			if (animation.framerate != Settings.defaultFramerate) 	xml.framerate	= animation.framerate;
			
			for each (var marker:AnimationMarker in animation.markers) {
				var markerXML:XML = <Marker></Marker>;
				markerXML.@name = marker.name;
				markerXML.@frame = marker.frame;
				xml.appendChild(markerXML);
			}
			
			for each (var part:AnimationPart in animation.parts) {
				var partXML:XML = <Part></Part>;
				partXML.@name = part.name;
				partXML.@spriteid = part.child.getSpriteId();
				partXML.@zindex = part.GetZIndex();
				for (var i:int = 0; i < part.frames.length; i++) {
					var frameXML:XML = _serialize(part.frames[i]);
					if (frameXML) {
						frameXML.@index = i;
						partXML.appendChild(frameXML);
					}
				}
				
				xml.appendChild(partXML)
			}
			
			return xml;
		}
		
		protected function serializeAnimationFrame(frame:AnimationFrame):XML {
			var xml:XML = <Frame></Frame>;
			
			if (frame.visible) {
				if (!equal(frame.x, 0, Settings.positionPrecision))			xml.@x 			= frame.x.toFixed(Settings.positionPrecision);
				if (!equal(frame.y, 0, Settings.positionPrecision))			xml.@y 			= frame.y.toFixed(Settings.positionPrecision);
				if (Settings.exportMatrix)
				{
					xml.@a = frame.matrix.a.toFixed(Settings.scalePrecision);
					xml.@b = (-frame.matrix.b).toFixed(Settings.scalePrecision);
					xml.@c = (-frame.matrix.c).toFixed(Settings.scalePrecision);
					xml.@d = frame.matrix.d.toFixed(Settings.scalePrecision);
				}
				else
				{
					if (!equal(frame.scaleX, 1, Settings.scalePrecision)) 		xml.@scaleX 	= frame.scaleX.toFixed(Settings.scalePrecision);
					if (!equal(frame.scaleY, 1, Settings.scalePrecision)) 		xml.@scaleY 	= frame.scaleY.toFixed(Settings.scalePrecision);
					if (!equal(frame.rotation, 0, Settings.rotationPrecision)) 	xml.@rotation 	= frame.rotation.toFixed(Settings.rotationPrecision);
				}
				if (!equal(frame.alpha, 1, Settings.alphaPrecision)) 		xml.@alpha 		= frame.alpha.toFixed(Settings.alphaPrecision);
				xml.@zindex = frame.zindex;
			} else {
				return null;
			}
			
			return xml;
		}
		
		private function equal(value1:Number, value2:Number, precision:uint):Boolean {
			return value1.toFixed(precision) == value2.toFixed(precision);
		}
		
	}

}