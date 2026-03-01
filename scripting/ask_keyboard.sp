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
public Plugin myinfo =
{
	name = "ask_keyboard",
	author = "TheRedEnemy",
	description = "",
	version = "1.1.4",
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
	PrintToChatAll("INPUTS : %s", g_askcode);
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
