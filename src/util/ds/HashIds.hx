package util.ds;

/**
 * A somewhat rough conversion of hashIds javascript version  ( http://hashids.org/javascript/ ) to Haxe so it's runnable in platforms like AS3.
 * Currently, only supports array-based parameter for encode(). 
 * 
 * @author Glenn Ko
 */
class HashIds
{
	public var alphabet:String;
	public var salt:String;
	var version:String;
	var minAlphabetLength:Float;
	var sepDiv:Float;
	var guardDiv:Float;
	var errorAlphabetLength:String;
	var errorAlphabetSpace:String;
	var minHashLength:Int;
	var seps:String;
	var guards:String;

	public function new(salt:String, minHashLength:Int=0, alphabet:String=null) {

		var uniqueAlphabet, i, j, len, sepsLength, diff, guardCount;

		this.version = "1.0.2";

		/* internal settings */

		this.minAlphabetLength = 16;
		this.sepDiv = 3.5;
		this.guardDiv = 12;

		/* error messages */

		this.errorAlphabetLength = "error: alphabet must contain at least X unique characters";
		this.errorAlphabetSpace = "error: alphabet cannot contain spaces";

		/* alphabet vars */

		this.alphabet =alphabet!=null ? alphabet :  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
		this.seps = "cfhistuCFHISTU";
		this.minHashLength = minHashLength > 0 ? minHashLength : 0;
		this.salt = salt;


		uniqueAlphabet = "";
		i = 0;
		 len = this.alphabet.length;
		while (i != len) {
			if (uniqueAlphabet.indexOf(this.alphabet.charAt(i)) == -1) {
				uniqueAlphabet += this.alphabet.charAt(i);
			}
			i++;
		}

		this.alphabet = uniqueAlphabet;

		if (this.alphabet.length < this.minAlphabetLength) {
			
			throw StringTools.replace(this.errorAlphabetLength, "X", Std.string(this.minAlphabetLength));
			//throw this.errorAlphabetLength.replace("X", this.minAlphabetLength);
		}

		if (this.alphabet.indexOf(" ") != -1) {
			throw this.errorAlphabetSpace;
		}

		/* seps should contain only characters present in alphabet; alphabet should not contains seps */
		i = 0;
		len = this.seps.length;
		while ( i != len) {

			j = this.alphabet.indexOf(this.seps.charAt(i));
			if (j == -1) {
				this.seps = this.seps.substr(0, i) + " " + this.seps.substr(i + 1);
			} else {
				this.alphabet = this.alphabet.substr(0, j) + " " + this.alphabet.substr(j + 1);
			}
			i++;
		}

		this.alphabet =  (~/ /g).replace(this.alphabet, ""); // .replace(~/ /g, "");

		this.seps = (~/ /g).replace(this.seps, ""); // this.seps.replace(, "");
		this.seps = this.consistentShuffle(this.seps, this.salt);

		if (!(this.seps.length!=0) || (this.alphabet.length / this.seps.length) > this.sepDiv) {

			sepsLength = Math.ceil(this.alphabet.length / this.sepDiv);

			if (sepsLength == 1) {
				sepsLength++;
			}

			if (sepsLength > this.seps.length) {

				diff = sepsLength - this.seps.length;
				this.seps += this.alphabet.substr(0, diff);
				this.alphabet = this.alphabet.substr(diff);

			} else {
				this.seps = this.seps.substr(0, sepsLength);
			}

		}

		this.alphabet = this.consistentShuffle(this.alphabet, this.salt);
		guardCount = Math.ceil(this.alphabet.length / this.guardDiv);

		if (this.alphabet.length < 3) {
			this.guards = this.seps.substr(0, guardCount);
			this.seps = this.seps.substr(guardCount);
		} else {
			this.guards = this.alphabet.substr(0, guardCount);
			this.alphabet = this.alphabet.substr(guardCount);
		}

	}
	
	public function encode(numbers:Array<UInt>) {

		
		
		/*
		if ( Std.is(numbers[0], Array) ) {
			numbers = numbers[0];
		}
		*/

	

		return this._encode(numbers);

	}
	
	public function decode(hash:String) {

	

		if (!(hash.length!=0) ) {  //|| Type.typeof( hash) != TString
			return [];
		}

		return this._decode(hash, this.alphabet);

	}
	
	/*
	public function encodeHex(str) {

		var i, len, numbers;

		str = str.toString();

		if (!~/^[0-9a-fA-F]+$/.test(str)) {
			return "";
		}

		numbers = str.match(~/[\w\W]{1,12}/g);

		i = 0;
		len = numbers.length;
		while (i != len) {
			numbers[i] = Std.parseInt("1" + numbers[i], 16);
			 i++;
		}

		return this.encode.apply(this, numbers);

	}
	*/
	
	/*
	public function decodeHex(hash) {

		var ret = [], i, len,
			numbers = this.decode(hash);

			i = 0;
			len = numbers.length;
		while (i != len) {
			ret += (numbers[i]).toString(16).substr(1);
			 i++;
		}

		return ret;

	}
	*/
	
	private inline function _encode(numbers:Array<Dynamic>) {

		var ret:String, lottery, i, len, number, buffer, last, sepsIndex, guardIndex:Int, guard, halfLength, excess,
			alphabet = this.alphabet,
			numbersSize = numbers.length,
			numbersHashInt:Float = 0;
		var i = 0;
		var len = numbers.length;
		while ( i != len) {
			numbersHashInt += (numbers[i] % (i + 100));
			 i++;
		}

		lottery = ret = alphabet.charAt(Std.int(numbersHashInt % alphabet.length));
		i = 0;
		len = numbers.length;
		while ( i != len) {

			number = numbers[i];
			buffer = lottery + this.salt + alphabet;

			alphabet = this.consistentShuffle(alphabet, buffer.substr(0, alphabet.length));
			last = this.hash(number, alphabet);

			ret += last;

			if (i + 1 < numbersSize) {
				number %= (last.charCodeAt(0) + i);
				sepsIndex = number % this.seps.length;
				ret += this.seps.charAt(sepsIndex);
			}
			i++;

		}

		if (ret.length < this.minHashLength) {

			guardIndex =Std.int( (numbersHashInt + ret.charCodeAt(0)) % this.guards.length );
			guard = this.guards.charAt(guardIndex);

			ret = guard + ret;

			if (ret.length < this.minHashLength) {

				guardIndex =Std.int( (numbersHashInt + ret.charCodeAt(2)) % this.guards.length);
				guard = this.guards.charAt(guardIndex);// [guardIndex];

				ret += guard;

			}

		}

		halfLength = Std.int(alphabet.length / 2);
		while (ret.length < this.minHashLength) {

			alphabet = this.consistentShuffle(alphabet, alphabet);
			ret = alphabet.substr(halfLength) + ret + alphabet.substr(0, halfLength);

			excess = ret.length - this.minHashLength;
			if (excess > 0) {
				ret = ret.substr(Std.int(excess / 2), this.minHashLength);
			}

		}

		return ret;

	}
	
	
	private inline function _decode(hash:String, alphabet:String) {

		var ret = [], i = 0,
			lottery, len, subHash, buffer,
			r = new EReg("[" + this.guards + "]", "g"),
			hashBreakdown = r.replace(hash, " ");
		//	hashBreakdown = StringTools.replace(hash, r, " ");// hash.replace(r, " "),
			var hashArray:Array<String> = hashBreakdown.split(" ");

		if (hashArray.length == 3 || hashArray.length == 2) {
			i = 1;
		}

		hashBreakdown = hashArray[i];
		if ( hashBreakdown.charAt(0) != null) {

			lottery = hashBreakdown.charAt(0);
			hashBreakdown = hashBreakdown.substr(1);

			r = new EReg("[" + this.seps + "]", "g");
			//hashBreakdown = hashBreakdown.replace(r, " "); 
			hashBreakdown = r.replace(hashBreakdown, " ");
			hashArray = hashBreakdown.split(" ");
			i = 0; len = hashArray.length;
			while  (i != len) {

				subHash = hashArray[i];
				buffer = lottery + this.salt + alphabet;

				alphabet = this.consistentShuffle(alphabet, buffer.substr(0, alphabet.length));
				ret.push(this.unhash(subHash, alphabet));
				i++;
			}

			if (this._encode(ret) != hash) {
				ret = [];
			}

		}

		return ret;

	}
	
	public function consistentShuffle(alphabet:String, salt:String) {

		var integer, j, temp, i, v, p;

		if (salt.length == 0) {
			return alphabet;
		}
		var i = alphabet.length - 1; v = 0; p = 0;
		while ( i > 0 ) {

			v %= salt.length;
			p += integer = salt.charCodeAt(v);
			j = (integer + v + p) % i;

			temp = alphabet.charAt(j);
			alphabet = alphabet.substr(0, j) + alphabet.charAt(i) + alphabet.substr(j + 1);
			alphabet = alphabet.substr(0, i) + temp + alphabet.substr(i + 1);
			i--; v++;
		}

		return alphabet;

	}
	
	private function hash(input:UInt, alphabet) {

		var hash = "",
			alphabetLength = alphabet.length;

		do {
			hash = alphabet.charAt(input % alphabetLength) + hash;
			input =Std.int(input / alphabetLength);
		} while (input!=0);

		return hash;

	}
	
	private function unhash(input:String, alphabet:String) {

		var number:Float = 0, pos, i;
		i = 0;
		for (i in 0...input.length) {
			pos = alphabet.indexOf(input.charAt(i));
			number += pos * Math.pow(alphabet.length, input.length - i - 1);
		}

		return number;

	}

	
}