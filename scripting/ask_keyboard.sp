#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1
#define MAX_LEN_ASK 128
char g_askcode[MAX_LEN_ASK];
public Plugin myinfo =
{
	name = "ask_keyboard",
	author = "TheRedEnemy",
	description = "",
	version = "1.0.0",
	url = "https://github.com/theredenemy/ask_keyboard"
};
void clearAsk()
{
	g_askcode = "\0";
}
public void OnPluginStart()
{
	RegServerCmd("ask_input", ask_enter_command);
	RegServerCmd("ask_reset", ask_reset_command);
	clearAsk();
	PrintToServer("Ask Keyboard Has Loaded");
}

public void OnMapStart()
{
	char mapname[128];
	clearAsk();
	GetCurrentMap(mapname, sizeof(mapname));
	PrintToServer(mapname);
}
public Action ask_reset_command(int args)
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
