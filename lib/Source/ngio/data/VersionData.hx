package ngio.data;

/**
 * Group order: `[ 1 => major, 2 => minor, 3 => patch, 4 => prerelease, 5 => buildmetadata ]`
 */
private final semver = ~/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/;

abstract VersionData(String)
{
	public var major(get, never):Int;
	public var minor(get, never):Int;
	public var patch(get, never):Int;
	public var prerelease(get, never):Null<String>;
	public var buildMetadata(get, never):Null<String>;
	
	inline function get_major() return Std.parseInt(Version.assertValid(this).matched(1));
	inline function get_minor() return Std.parseInt(Version.assertValid(this).matched(2));
	inline function get_patch() return Std.parseInt(Version.assertValid(this).matched(3));
	inline function get_prerelease() return Version.assertValid(this).matched(4);
	inline function get_buildMetadata() return Version.assertValid(this).matched(5);
	
	inline public function toString() return this;
}

class Version
{
	public final major:Int;
	public final minor:Int;
	public final patch:Int;
	public final prerelease:Null<String>;
	public final buildMetadata:Null<String>;
	
	public inline function new (major, minor, patch, ?prerelease, ?buildMetadata)
	{
		this.major = major;
		this.minor = minor;
		this.patch = patch;
		this.prerelease = prerelease;
		this.buildMetadata = buildMetadata;
	}
	
	inline public function toString()
	{
		final displayPrerelease = (prerelease == null ? "" : '-$prerelease');
		final displayMeta = (buildMetadata == null ? "" : '+$buildMetadata');
		return '$major.$minor.$patch$displayPrerelease$displayMeta';
	}
	
	inline public function greaterThan(ver:Version) return compare(this, ver) > 0;
	inline public function lessThan(ver:Version) return compare(this, ver) < 0;
	inline public function equals(ver:Version) return compare(this, ver) == 0;
	
	inline static public function assertValid(ver:String)
	{
		if (false == semver.match(ver))
			throw '$ver is not a valid semver';
		
		return semver;
	}
	
	static public function fromString(ver:String)
	{
		final semver = assertValid(ver);
		
		return new Version
			( Std.parseInt(semver.matched(1))
			, Std.parseInt(semver.matched(2))
			, Std.parseInt(semver.matched(3))
			, semver.matched(4)
			, semver.matched(5)
			);
	}
	
	inline static public function majorFromString(ver:String) return Std.parseInt(assertValid(ver).matched(1));
	inline static public function minorFromString(ver:String) return Std.parseInt(assertValid(ver).matched(2));
	inline static public function patchFromString(ver:String) return Std.parseInt(assertValid(ver).matched(3));
	inline static public function prereleaseFromString(ver:String) return assertValid(ver).matched(4);
	inline static public function buildMetadataFromString(ver:String) return assertValid(ver).matched(5);
	
	static public function compare(a:Version, b:Version)
	{
		return if (a.major > b.major) 1;
		else   if (a.major < b.major) -1;
		else   if (a.minor > b.minor) 1;
		else   if (a.minor < b.minor) -1;
		else   if (a.patch > b.patch) 1;
		else   if (a.patch < b.patch) -1;
		else
			comparePrerelease(a.prerelease, b.prerelease);
	}
	
	static public function comparePrerelease(a:Null<String>, b:Null<String>):Int
	{
		return if (b == null) -1;
		else   if (a == null) 1;
		else
		{
			final splitA = a.split(".");
			final splitB = b.split(".");
			final lenA = splitA;
			final lenB = splitB;
			var diff = 0;
			final length = splitA.length > splitB.length ? splitA.length : splitB.length;
			for (i in 0...length)
			{
				if (splitA[i] == splitB[i])
					continue;
				
				diff = if (splitA.length < i + 1) -1;
				else if (splitB.length < i + 1) 1;
				else comparePrereleaseIdentifier(splitA[i], splitB[i]);
				
				break;
			}
			diff;
		}
	}
	
	static final isInt = ~/^\d+$/;
	static public function comparePrereleaseIdentifier(a:String, b:String)
	{
		return switch [isInt.match(a), isInt.match(b)]
		{
			case [false, true ]: 1;
			case [true , false]: -1;
			case [true , true ]: Std.parseInt(a) - Std.parseInt(b);
			case [_    , _    ]: a > b ? 1 : -1;
		}
	}
}