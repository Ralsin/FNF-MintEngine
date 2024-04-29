package funkin.externs;

#if (cpp && windows)
@:headerInclude('windows.h')
@:headerInclude('psapi.h')
#end

#if hl
@:hlNative("WinAPI")
#end
class WinAPI {
	#if windows
	/*** Gets more accurate RAM usage (according to various sources, not even task manager is reliable so it WILL differ from it's display). **/
	#if cpp
	@:functionCode('
		PROCESS_MEMORY_COUNTERS pmc;
    	if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc)))
        	return (int)pmc.WorkingSetSize;
	')
	#end
	public static function get_process_memory():Int {
		return 0;
	}
	#end
}
