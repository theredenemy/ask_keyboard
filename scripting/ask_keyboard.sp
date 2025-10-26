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
	PrintToServer("hello");
}

public void OnMapStart()
{
	PrintToServer("placeholder");
}
