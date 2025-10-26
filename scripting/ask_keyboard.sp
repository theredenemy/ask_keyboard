#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1
public Plugin myinfo =
{
	name = "ask_keyboard",
	author = "TheRedEnemy",
	description = "",
	version = "1.0.0",
	url = "https://github.com/theredenemy/ask_keyboard"
};


public void OnPluginStart()
{
	RegServerCmd("ask_input", ask_enter_command);
	PrintToServer("Ask Keyboard Has Loaded");
}

public void OnMapStart()
{
	char mapname[128];
	char askcode[128];
	GetCurrentMap(mapname, sizeof(mapname));
	PrintToServer(mapname);
}

public Action ask_enter_command(int args)
{
	char arg[128];
    char full[256];
 
    GetCmdArgString(full, sizeof(full));
	PrintToServer("Argument string: %s", full);
    PrintToServer("Argument count: %d", args);
	GetCmdArg(1, arg, sizeof(arg));
	PrintToServer(arg);
	return Plugin_Handled;

}
