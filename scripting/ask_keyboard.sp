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
char g_askcode[MAX_LEN_ASK];
char mapname[128];
ConVar g_invaildcmd;
ConVar g_codeemptycmd;
public Plugin myinfo =
{
	name = "ask_keyboard",
	author = "TheRedEnemy",
	description = "",
	version = "1.0.2",
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
	
	RegServerCmd("ask_input", ask_enter_command);
	RegServerCmd("ask_reset", ask_reset_command);
	RegServerCmd("ask_submit", ask_submit_command);
	RegServerCmd("ask_clear", ask_clear_command);
	g_invaildcmd = CreateConVar("ask_invaildcmd", "changelevel noaccess");
	g_codeemptycmd = CreateConVar("ask_codeemptycmd", "ask_reset");
	clearAsk();
	makeConfig();
	PrintToServer("Ask Keyboard Has Loaded");
}

public void OnMapStart()
{
	mapname = "\0";
	clearAsk();
	GetCurrentMap(mapname, sizeof(mapname));
	PrintToServer(mapname);
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
public Action ask_enter_command(int args)
{
	char arg[MAX_LEN_ASK];
    char full[256];
	if (args > 1)
	{
		PrintToServer("ONLY ONE INPUT AT A TIME");
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
