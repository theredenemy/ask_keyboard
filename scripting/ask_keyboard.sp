#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <string>
#include <files>
#pragma newdecls required
#pragma semicolon 1
#define MAX_LEN_ASK 256
#define MAX_CMD_LEN 256
#define ASK_CODES_FILE "ask_codes.txt"
#define debugmode false
char g_askcode[MAX_LEN_ASK];
char g_mapname[128];
bool debug = debugmode;
ConVar g_invaildcmd;
ConVar g_codeemptycmd;
ConVar g_showcodeentry;
public Plugin myinfo =
{
	name = "ask_keyboard",
	author = "TheRedEnemy",
	description = "",
	version = "1.2.2",
	url = "https://github.com/theredenemy/ask_keyboard"
};
void clearAsk()
{
	g_askcode = "\0";
}

void makeConfig()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", ASK_CODES_FILE);
	if (!FileExists(path))
	{
		PrintToServer(path);
		KeyValues kv = new KeyValues("Ask_Codes");
		kv.SetString("a s k", "say ASK ; ask_reset");
		kv.SetString("v i e w", "changelevel view");
		kv.SetString("m a z e", "changelevel mazemazemazemaze");
		kv.SetString("o r d spave p l a y", "changelevel ord_play");
		kv.SetString("k j e g l v ae gen", "changelevel subroutine_hello");
		kv.SetString("q u i z", "changelevel quiz");
		kv.SetString("ao p e n spave d os r", "changelevel souer");
		kv.SetString("s o u e r", "changelevel souer");
		kv.SetString("d os r", "changelevel souer");
		kv.SetString("k u l c s", "changelevel plotmas");
		kv.SetString("m a p gen", "changelevel stork");
		kv.SetString("gen", "changelevel stork");
		kv.SetString("s t ao l", "changelevel stal");
		kv.SetString("j s t ao l", "changelevel stal");
		kv.SetString("k u r t", "changelevel kurt");
		kv.SetString("w h o r u", "changelevel speckle");
		kv.SetString("w h o a r e u", "changelevel speckle");
		kv.SetString("h o w a r e u", "changelevel speckle");
		kv.SetString("s i n c e", "changelevel blemor_e");
		kv.SetString("w h e n", "changelevel stork");
		kv.SetString("c o u l d", "changelevel belod");
		kv.SetString("y o u", "changelevel speckle");
		kv.SetString("s e a r c h", "changelevel crishy_is");
		kv.SetString("o u r", "changelevel souer");
		kv.SetString("d r e a m s", "changelevel plotmas");
		kv.SetString("a n o m i d ae", "changelevel veritas");
		kv.Rewind();
		kv.ExportToFile(path);
		delete kv;
	}
}
public void OnPluginStart()
{
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
	RegServerCmd("ask_input", ask_input_command);
	RegServerCmd("ask_reset", ask_reset_command);
	RegServerCmd("ask_submit", ask_submit_command);
	RegServerCmd("ask_clear", ask_clear_command);
	g_invaildcmd = CreateConVar("ask_invaildcmd", "changelevel noaccess");
	g_codeemptycmd = CreateConVar("ask_codeemptycmd", "changelevel noaccess");
	g_showcodeentry = CreateConVar("ask_showcodeentry", "1");
	clearAsk();
	makeConfig();
	PrintToServer("Ask Keyboard Has Loaded");
}

public void OnMapStart()
{
	g_mapname = "\0";
	clearAsk();
	GetCurrentMap(g_mapname, sizeof(g_mapname));
	PrintToServer(g_mapname);
}
public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	clearAsk();
	PrintToServer("Round Start");
	return Plugin_Continue;
}
public Action ask_reset_command(int args)
{
	clearAsk();
	ServerCommand("mp_restartgame 1");
	return Plugin_Handled;
}

public Action ask_clear_command(int args)
{
	clearAsk();
	return Plugin_Handled;
}
public Action ask_input_command(int args)
{
	char arg[MAX_LEN_ASK];
    char full[256];
	int showcodeentry = GetConVarInt(g_showcodeentry);
	if (debug == true)
	{
		char debug_len[256];
		IntToString(strlen(g_askcode), debug_len, sizeof(debug_len));
		PrintToServer(debug_len);
	}
	if (args > 1)
	{
		PrintToServer("ONLY ONE INPUT AT A TIME");
		return Plugin_Handled;
	}
	else if(args < 1)
	{
		PrintToServer("[SM] Usage: ask_input <input>");
		return Plugin_Handled;
	}

	if (strlen(g_askcode) + strlen(arg) + 5 >= MAX_LEN_ASK)
	{
		PrintHintTextToAll("ERROR : Array Out Of Bounds RESET");
		PrintToServer("ERROR : Array Out Of Bounds RESET");
		clearAsk();
		ServerCommand("mp_restartgame 1");
		return Plugin_Handled;
	}
    GetCmdArgString(full, sizeof(full));
	
	GetCmdArg(1, arg, sizeof(arg));
	
	int askcode_len = strlen(g_askcode);
	if (askcode_len > 0)
	{
		StrCat(g_askcode, sizeof(g_askcode), " ");
	}

	StrCat(g_askcode, sizeof(g_askcode), arg);
	PrintToServer(g_askcode);
	if (showcodeentry == 1)
	{
		PrintToChatAll("\x077F00FFINPUTS\x01 : %s ", g_askcode);
	}
	
	return Plugin_Handled;

}

public Action ask_submit_command(int args)
{
	char path[PLATFORM_MAX_PATH];
	char cmd[MAX_CMD_LEN];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", ASK_CODES_FILE);
	KeyValues kv = new KeyValues("Ask_Codes");

	if (!g_askcode[0])
	{
		g_codeemptycmd.GetString(cmd, MAX_CMD_LEN);
		PrintToServer("CODE IS EMPTY");
		ServerCommand("%s", cmd);
		delete kv;
		return Plugin_Handled;
	}

	if (!kv.ImportFromFile(path))
	{
		PrintToServer("NO FILE");
		delete kv;
		return Plugin_Handled;
	}

	if (kv.JumpToKey(g_askcode, false))
	{
		PrintToServer("VAILD CODE");
		kv.GetString(NULL_STRING, cmd, sizeof(cmd));
		PrintToServer(cmd);
		ServerCommand("%s", cmd);
		
		delete kv;
		return Plugin_Handled;
	}
	else
	{
		g_invaildcmd.GetString(cmd, MAX_CMD_LEN);
		PrintToServer("INVAILD CODE");
		ServerCommand("%s", cmd);

		delete kv;
		return Plugin_Handled;
	}
}
