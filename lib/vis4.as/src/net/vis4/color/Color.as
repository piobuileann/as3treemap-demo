package net.vis4.color 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Color
	 * 
	 * @author Gregor Aisch, http://vis4.net
	 * 
	 * // Beispiel 1:
	 * // Einlesen einer Integer-Farbe, Sättigung auf 50% setzen, Hex-Farbe ausgeben
	 * 
	 * var color:Color = Color.fromInt(0xFF0000);
	 * color.saturation = 0.5;
	 * trace(color.hexValue); // Ausgabe: "#BF3F3F"
	 * 
	 * 
	 * // Beispiel 2:
	 * // Einlesen einer RGB-Farbe, Helligkeit auf 70% begrenzen, RGB-Were ausgeben
	 * 
	 * color = Color.fromRGB(220, 250, 180);
	 * if (color.lightness &gt; 0.7) color.lightness = 0.7;
	 * trace(color.red, color.green, color.blue); // Ausgabe: "188 245 111"
	 * 
	 * 
	 * // Beispiel 3:
	 * // Einlesen einer HSV-Farbe, Umwandlung in den HSL-Raum, Helligkeit auf 50% setzen,
	 * // zurück in den HSV-Raum umwandeln, Ausgabe
	 * 
	 * color = Color.fromHSV(0, .7, .9);
	 * trace(color.hue, color.saturation, color.value); // Ausgabe: "0 0.7 0.9"
	 * color.mode = Color.HSL;
	 * trace(color.hue, color.saturation, color.lightness); // Ausgabe: "0 0.755 0.582"
	 * color.lightness = 0.5;
	 * color.mode = Color.HSV;
	 * trace(color.hue, color.saturation, color.value); // Ausgabe: "0 0.861 0.874"
	 * 
	 */
	public class Color 
	{
		/**
		 * hue saturation value
		 */
		public static const HSV:String = 'hsv';
		
		/**
		 * hue saturation intensity
		 */
		public static const HSI:String = 'hsi';
		
		/**
		 * hue saturation lightness
		 */
		public static const HSL:String = 'hsl';
		
		/**
		 * hue saturation brightness
		 */
		public static const HSB:String = 'hsb';
		
		private var 
			_mode:String;
			
		private var 
			_u:uint, _x:String,
			_r:uint, _g:uint, _b:uint,
			_h:Number = 0, // hue
			_s:Number = 1, // saturation
			_v:Number = 1, // value
			_i:Number = 1, // intensity
			_l:Number = 0.5, // lightness
			_br:Number = 0.5; // brightness or luminance	
		
		/**
		 * constructor method.
		 * 
		 * <p>usage example:</p>
		 * <listing>var col:Color = new Color(Color.HSL);
		 * col.intColor = 0xFF0000;
		 * col.saturation = .5;
		 * trace(col.hexColor); // output is "#BF4040"
		 * </listing>
		 * 
		 * @param mode current color space mode
		 */
		public function Color(mode:String = 'hsl') 
		{
			if (mode != HSV && mode != HSI && mode != HSL && mode != HSB) throw new Error('unknown color mode ' + mode);
			_mode = mode;
		}
		

		public function set mode(mode:String):void 
		{
			if (mode != HSV && mode != HSI && mode != HSL && mode != HSB) throw new Error('unknown color mode ' + mode);
			_mode = mode;
			// recalc hsx-color
			rgb2hsx();	
		}
		
		/**
		 * current color space mode. you can convert a color between different color spaces by setting a different mode.
		 * 
		 * <p>example:</p>
		 * <listing>
		 * color = Color.fromHSL(60, .5, 1);
		 * color.mode = Color.HSV;
		 * trace(color.hue, color.saturation, color.value);
		 * </listing>
		 */		
		public function get mode():String
		{
			return _mode;
		}
		
		/**
		 * creates a new instance from an integer color.
		 * 
		 * <p>example:</p>
		 * <listing>
		 * color = Color.fromInt(0xFF0000, Color.HSB);
		 * trace(color.hue, color.saturation, color.brightness);
		 * </listing>
		 * 
		 * @param color
		 * @mode 
		 */
		public static function fromInt(color:uint, mode:String = 'hsl'):Color
		{
			var c:Color = new Color(mode);
			c._int = color;
			return c;
		}

		/**
		 * creates a new instance from a string value (eg. "#FF0000")
		 * 
		 * @param color
		 * @mode 
		 */		
		public static function fromHex(color:String, mode:String = 'hsl'):Color
		{
			var c:Color = new Color(mode);
			c._hex = color;
			return c;
		}
		
		public static function fromRGB(r:uint, g:uint, b:uint, mode:String = 'hsl'):Color
		{
			var c:Color = new Color(mode);
			c.setRGB(r, g, b);
			return c;
		}
		
		public static function fromHSV(h:Number, s:Number, v:Number, mode:String = 'hsv'):Color
		{
			var c:Color = new Color(mode);
			c.setHSV(h, s, v);
			return c;
		}		
		
		public static function fromHSI(h:Number, s:Number, i:Number, mode:String = 'hsi'):Color
		{
			var c:Color = new Color(mode);
			c.setHSI(h, s, i);
			return c;
		}	
		
		public static function fromHSL(h:Number, s:Number, l:Number, mode:String = 'hsl'):Color
		{
			var c:Color = new Color(mode);
			c.setHSL(h, s, l);
			return c;
		}	
		
		public static function fromHSB(h:Number, s:Number, b:Number, mode:String = 'hsb'):Color
		{
			var c:Color = new Color(mode);
			c.setHSB(h, s, b);
			return c;
		}
		
		public function set _int(i:uint):void 
		{
			_u = i;
			int2rgb();
			int2hex();
			rgb2hsx();
		}
		
		public function get _int():uint { return _u; }
		
		public function set _hex(h:String):void
		{
			_x = h;
			hex2int();
			int2rgb();
			rgb2hsx();
		}
		
		public function get _hex():String { return _x; }

		public function set _red(r:uint):void 
		{
			_r = r;
			rgb2int();
			int2hex();
			rgb2hsx();
		}		

		public function set _green(g:uint):void 
		{
			_g = g;
			rgb2int();
			int2hex();
			rgb2hsx();
		}		

		public function set _blue(b:uint):void 
		{
			_b = b;
			rgb2int();
			int2hex();
			rgb2hsx();
		}
		
		/**
		 * sets a new color 
		 * 
		 * @param r red value
		 * @param g green value
		 * @param b blue value
		 */	
		public function setRGB(r:uint, g:uint, b:uint):void {
			_r = r; _g = g; _b = b;
			rgb2int();
			int2hex();
			rgb2hsx();
		}		
		
		public function get _red():uint { return _r; }
		public function get _green():uint { return _g; }
		public function get _blue():uint { return _b; }


		public function set _hue(h:Number):void 
		{
			while (h < 0) h += 360;			
			_h = h % 360;
			
			hsx2rgb();
			rgb2int();
			int2hex();						
		}

		/**
		 * saturation of the current color. only supported in HSV mode
		 */			
		public function set _saturation(s:Number):void 
		{
			_s = trim(s);
			hsx2rgb();
			rgb2int();
			int2hex();
		}
		
		private function trim(value:Number):Number
		{
			return Math.max(0, Math.min(1, value));
		}
		
		/**
		 * value of the current color. only supported in HSV mode
		 */	
		public function set _value(v:Number):void 
		{
			if (_mode == HSV) {
				_v = trim(v);
				hsv2rgb();
				rgb2int();
				int2hex();
			} else throw new Error('value not supported in ' + _mode + ' mode');
		}

		/**
		 * intensity of the current color. only supported in HSI mode
		 */	
		public function set _intensity(i:Number):void 
		{
			if (_mode == HSI) {
				_i = trim(i);
				hsi2rgb();
				rgb2int();
				int2hex();
			} else throw new Error('intensity not supported in ' + _mode + ' mode');
		}

		/**
		 * lightness of the current color. only supported in HSL mode
		 */			
		public function set _lightness(l:Number):void 
		{
			if (_mode == HSL) {
				_l = trim(l);
				hsl2rgb();
				rgb2int();
				int2hex();
			} else throw new Error('lightness not supported in ' + _mode + ' mode');
		}
	
		public function set _brightness(b:Number):void 
		{
			if (_mode == HSB) {
				_br = trim(b);
				hsb2rgb();
				rgb2int();
				int2hex();
			} else throw new Error('brightness not supported in ' + _mode + ' mode');
		}
		
		/**
		 * sets a new color and changes the mode to HSV
		 * 
		 * @param h hue value, in degrees [0..360]
		 * @param s saturation [0..1]
		 * @param v value [0..1]
		 */		
		public function setHSV(h:Number, s:Number, v:Number):void {
			if (_mode != HSV) _mode = HSV;
			_h = h; _s = trim(s); _v = trim(v);
			hsv2rgb();
			rgb2int();
			int2hex();
		}

		/**
		 * sets a new color and changes the mode to HSI
		 * 
		 * @param h hue value, in degrees [0..360]
		 * @param s saturation [0..1]
		 * @param i intensitiy [0..1]
		 */
		public function setHSI(h:Number, s:Number, i:Number):void {
			if (_mode != HSI) _mode = HSI; 
			_h = h; _s = trim(s); _i = trim(i);
			hsi2rgb();
			rgb2int();
			int2hex();
		}

		/**
		 * sets a new color and changes the mode to HSL
		 * 
		 * @param h hue value, in degrees [0..360]
		 * @param s saturation [0..1]
		 * @param l lightness [0..1]
		 */
		public function setHSL(h:Number, s:Number, l:Number):void {
			if (_mode != HSL) _mode = HSL;
			_h = h; _s = trim(s); _l = trim(l);
			hsl2rgb();
			rgb2int();
			int2hex();
		}

		/**
		 * sets a new color and changes the mode to HSB
		 * 
		 * @param h hue value of the new color in degrees, @see #hue
		 * @param s saturation of the new color [0..1]
		 * @param b brightness of the new color [0..1]
		 */
		public function setHSB(h:Number, s:Number, b:Number):void {
			if (_mode != HSB) _mode = HSB;
			_h = h; _s = trim(s); _br = trim(b);
			hsb2rgb();
			rgb2int();
			int2hex();
		}

		/**
		 * hue of the current color in degrees [0..360].
		 * 
		 * <p>some sample values: 0° = red, 60° = yellow, 120° = green, 180° = cyan, 240° = blue, 300° = pink </p>
		 * 
		 * <p>example: drawing of a rainbow gradient</p>
		 * <listing>
		 * color = Color.fromHSL(0, 1, .5); // starting from red
		 * for (var h:int = 0; h < 360; h++) {
		 *    color.hue = h;
		 *    graphics.beginFill(color.intColor);
		 *    graphics.drawRect(h, 0, 1, 30);
		 *    graphics.endFill();
		 * }
		 * </listing>
		 */				
		public function get _hue():Number { return _h; }
		
		/**
		 * saturation of the current color. only supported in HSI mode
		 */			
		public function get _saturation():Number { return _s; }
		
		/**
		 * value of the current color. only supported in HSV mode
		 */	
		public function get _value():Number 
		{
			if (_mode == HSV) return _v; 
			else throw new Error('value not supported in ' + _mode + ' mode');
		}
		
		/**
		 * intensity of the current color. only supported in HSI mode
		 */	
		public function get _intensity():Number 
		{
			if (_mode == HSI) return _i; 
			else throw new Error('intensity not supported in ' + _mode + ' mode');
		}
		
		/**
		 * lightness of the current color. only supported in HSL mode
		 */	
		public function get _lightness():Number 
		{
			if (_mode == HSL) return _l; 
			else throw new Error('lightness not supported in ' + _mode + ' mode');
		}	
		
		/**
		 * brightness of the current color. only supported in HSB mode
		 */	
		public function get _brightness():Number 
		{
			if (_mode == HSB) return _br; 
			else throw new Error('brightness not supported in ' + _mode + ' mode');
		}	
		
		public function hue(val:*):Color 
		{
			_evaluate('_hue', val);
			return this;
		}
		
		public function saturation(val:*):Color 
		{
			_evaluate('_saturation', val);
			return this;
		}
		
		public function lightness(val:*):Color 
		{
			_evaluate('_lightness', val);
			return this;
		}
		
		public function brightness(val:*):Color 
		{
			_evaluate('_brightness', val);
			return this;
		}
		
		public function intensity(val:*):Color 
		{
			_evaluate('_intensity', val);
			return this;
		}
		
		public function value(val:*):Color 
		{
			_evaluate('_value', val);
			return this;
		}
		
		private function _evaluate(propName:String, val:*):void
		{
			if (typeof(val) == "string") {
				if (val.charAt(0) == "+" && !isNaN(val.substr(1))) {
					this[propName] = Number(this[propName]) + Number(val.substr(1));
				} else if (val.charAt(0) == "-" && !isNaN(val.substr(1))) {
					this[propName] = this[propName] - Number(val.substr(1));
				} if (val.charAt(0) == "*" && !isNaN(val.substr(1))) {
					this[propName] = this[propName] * Number(val.substr(1));
				} else if (val.charAt(0) == "/" && !isNaN(val.substr(1))) {
					this[propName] = this[propName] / Number(val.substr(1));
				} 
			} else if (!isNaN(val)) {
				this[propName] = Number(val);
			}
		}
		
		private function rgb2int():void
		{
			_u = _r << 16 | _g << 8 | _b;
			onChange();
		}
		
		private function int2rgb():void
		{
			_r = _u >> 16;
			_g = _u >> 8 & 0xFF;
			_b = _u & 0xFF;				
		}	

		private function hex2int():void
		{
			_u = uint('0x' + _x.substr(1, 6));
			onChange();
		}
		
		private function onChange():void
		{
			
		}
		
		private function int2hex():void
		{
			var str:String = "000000" + _u.toString(16).toUpperCase()
			_x = "#" + str.substr(str.length - 6);
		}
		
		private function rgb2hsv():void
		{
			var min:uint = Math.min(Math.min(_r, _g), _b),
				max:uint = Math.max(Math.max(_r, _g), _b),
				delta:int = max - min;
			
			_v = max/255;
			_s = delta / max;
			if (_s == 0) {
				_h = Number.NaN;
			} else {
				if (_r == max) _h = (_g - _b) / delta;
				if (_g == max) _h = 2+(_b - _r) / delta;
				if (_b == max) _h = 4+(_r - _g) / delta;
				_h *= 60;
				if (_h < 0) _h += 360;
			}
		}
		
		
		private function hsv2rgb():void
		{
			var h:Number = _h, v:Number = _v*255, i:uint, f:Number, p:uint, q:uint, t:uint;
			
			if (_s == 0 && isNaN(_h)) {
				_r = _g = _b = v;
			} else {
				if (h == 360) h = 0;
				h /= 60;
				i = Math.floor(h);
				f = h - i;
				p = v * (1 - _s);
				q = v * (1 - _s * f);
				t = v * (1 - _s * (1 - f));
				
				switch (i) {
					case 0: _rgb(v, t, p); break;
					case 1: _rgb(q, v, p); break;
					case 2: _rgb(p, v, t); break;
					case 3: _rgb(p, q, v); break;
					case 4: _rgb(t, p, v); break;
					case 5: _rgb(v, p, q); 
				}
			}			
		}		
		
		private function rgb2hsi():void // http://fourier.eng.hmc.edu/e161/lectures/color_processing/node3.html
		{
			var min:Number,
				max:Number = Math.max(Math.max(_r, _g), _b),
				sum:uint = _r + _g + _b,
				delta:int = max - min,
				r:Number, g:Number, b:Number;
			
			r = _r / sum;
			g = _g / sum;
			b = _b / sum;
			
			min = Math.min(Math.min(r, g), b);
			//trace('rgb = ',r,g,b,' min = ' + min);
			
			_i = (_r + _g + _b) / 765;			
			_h = acos((_r - .5*_g - .5*_b) / Math.sqrt( (_r - _g) * (_r - _g) + (_r - _b) * (_g - _b)) );			
			_s = 1 - 3 * min;
			
			if (_b > _g) _h = 360 - _h;
		}	
			
		private function hsi2rgb():void // http://fourier.eng.hmc.edu/e161/lectures/color_processing/node4.html
		{
			var h:Number = _h, r:Number, b:Number, g:Number;
			
			if (h <= 120) {
				b = (1 - _s) / 3;
				r = (1 + (_s * cos(h)) / cos(60 - h)) / 3;
				g = 1 - (b + r);
			} else if (h <= 240) {
				h -= 120;
				r = (1 - _s) / 3;
				g = (1 + (_s * cos(h)) / cos(60 - h)) / 3;
				b = 1 - (r + g);
			} else {
				h -= 240;
				g = (1 - _s) / 3;
				b = (1 + (_s * cos(h)) / cos(60 - h)) / 3;
				r = 1 - (g + b);
			}
			_r = Math.min(255, r*_i*3*255);
			_g = Math.min(255, g*_i*3*255);
			_b = Math.min(255, b*_i*3*255);			
		}
		
		private function rgb2hsl():void
		{
			var r:Number = _r / 255, 
				g:Number = _g / 255, 
				b:Number = _b / 255,
				min:Number = Math.min(Math.min(r, g), b),
				max:Number = Math.max(Math.max(r, g), b);
			
			_l = (max + min) / 2;
			if (max == min) {
				_s = 0;
				_h = Number.NaN;
			} else {
				if (_l < .5) {
					_s = (max - min) / (max + min);
				} else {
					_s = (max - min) / (2 - max - min);
				}
			}
			if (r == max) _h = (g - b) / (max - min);
			else if (g == max) _h = 2 + (b - r) / (max - min);
			else if (b == max) _h = 4 + (r - g) / (max - min);
			
			_h *= 60;
			if (_h < 0) _h += 360;
		}
		
		private function hsl2rgb():void
		{
			if (_s == 0) {
				_r = _g = _b = _l*255;
			} else {
				var t1:Number, t2:Number, t3:Array = [0,0,0], c:Array = [0,0,0];
				if (_l < .5) {
					t2 = _l * (1 + _s);
				} else {
					t2 = _l + _s - _l * _s;
				}
				t1 = 2 * _l - t2;
				var h:Number = _h / 360;
				t3[0] = h + 1 / 3;
				t3[1] = h;
				t3[2] = h - 1 / 3;
				for (var i:uint = 0; i < 3; i++) {
					if (t3[i] < 0) t3[i] += 1;
					if (t3[i] > 1) t3[i] -= 1;
					
					if (6 * t3[i] < 1) c[i] = t1 + (t2 - t1) * 6 * t3[i];
					else if (2 * t3[i] < 1) c[i] = t2;
					else if (3 * t3[i] < 2) c[i] = t1 + (t2 - t1) * ((2 / 3) - t3[i]) * 6;
					else c[i] = t1;
				}
				_r = c[0] * 255;
				_g = c[1] * 255;
				_b = c[2] * 255;
			}
		}	
		
		private function rgb2hsb():void
		{
			rgb2hsl();
			_br = _rgbLuminance();
		}
		
		private function hsb2rgb():void
		{
			var treshold:Number = 0.001;
			var l_min:Number = 0, l_max:Number = 1, l_est:Number = 0.5;
			var current_brightness:Number;
			
			// first try
			_l = l_est;
			hsl2rgb();
			current_brightness = _rgbLuminance();
			var trys:uint = 0;
			
			while (Math.abs(current_brightness - _br) > treshold && trys < 100) {
				
				if (current_brightness > _br) {
					// too bright, next try darker
					l_max = l_est;					
				} else {
					// too dark, next try brighter
					l_min = l_est;
				}
				l_est = (l_min + l_max) / 2;
				_l = l_est;
				hsl2rgb();
				current_brightness = _rgbLuminance();
				trys++;
			}
			_br = current_brightness;
			
		}
		
		private function hsx2rgb():void
		{
			switch (_mode) {
				case HSV: hsv2rgb(); break;
				case HSI: hsi2rgb(); break;
				case HSL: hsl2rgb(); break;
				case HSB: hsb2rgb(); break;
			}
		}
		
		private function rgb2hsx():void
		{
			switch (_mode) {
				case HSV: rgb2hsv(); break;
				case HSI: rgb2hsi(); break;
				case HSL: rgb2hsl(); break;
				case HSB: rgb2hsb(); break;
			}
		}	
		
		private function cos(d:Number):Number {
			return Math.cos(deg2rad(d));
		}
		
		private function acos(d:Number):Number {
			return rad2deg(Math.acos(d));
		}
		
		private function deg2rad(d:Number):Number {
			return d * Math.PI / 180;
		}
		
		private function rad2deg(r:Number):Number {
			return r * 180 / Math.PI;
		}
				
		private function _rgb(r:uint, g:uint, b:uint):void {
			_r = r; _g = g; _b = b;
		}
		
		private function _rgbLuminance():Number
		{
			return (0.2126 * _r + 0.7152 * _g + 0.0722 * _b) / 255; 
		}
		
		/**
		 * 
		 * @return
		 */
		public function clone():Color
		{
			return Color.fromInt(_u, _mode);
		}
	}
	
}