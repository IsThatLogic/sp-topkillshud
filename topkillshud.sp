#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Top Kills Hud",
	author = "log-ical",
	description = "Prints top scores on screen",
	version = "0.1",
	url = ""
};

enum struct PlayerData 
{
	int kills;
}

int fst;
int snd;
int trd;

PlayerData playerdata[MAXPLAYERS + 1];

// referesh rate of the text must match how long it's displayed for
// or you will get new and old text overlapping
#define TEXT_TIMER 0.6

public void OnPluginStart()
{
	CreateTimer(TEXT_TIMER, Timer_PrintKillsHud, _, TIMER_REPEAT);


	HookEvent("player_connect", Event_PlayerConnect);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_death", Event_PlayerDeath);
}

public void OnMapEnd()
{
	for(int i = 1; i < MAXPLAYERS; i++)
	{
		playerdata[i].kills = 0;
		fst = 0;
		snd = 0;
		trd = 0;
	}
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetEventInt(event, "userid");

	playerdata[client].kills = 0;
	if(client == fst)
	{
		playerdata[fst].kills = 0;
		fst = 0;
	}
	if(client == snd)
	{
		playerdata[snd].kills = 0;
		snd = 0;
	}
	if(client == trd)
	{
		playerdata[trd].kills = 0;
		trd = 0;
	}
	//playerdata[client].name = "";
}
public Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetEventInt(event, "userid");
	if(!IsValidClient(client))
		return;
	playerdata[client].kills = 0;
	//playerdata[client].name = clientname;
}
public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));	

	if(attacker == 0)
	{
		return;
	}

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));	

	if(GetClientTeam(attacker) != GetClientTeam(victim) && attacker != victim)
	{
		playerdata[attacker].kills++;
	}
}



public Action Timer_PrintKillsHud(Handle timer)
{
	for(int i = 1; i < MAXPLAYERS; i++)
	{
		if(IsValidClient(i) && playerdata[i].kills > 0)
		{
			if(playerdata[i].kills > playerdata[fst].kills)
			{
				fst = i;
				if(i == snd)
				{
					snd = 0;
				}
				if(i == trd)
				{
					trd = 0;
				}
			}
			else if(playerdata[i].kills > playerdata[snd].kills && i != fst)
			{
				snd = i;
				if(i == fst)
				{
					snd = 0;
				}
				if(i == trd)
				{
					trd = 0;
				}
			}
			else if(playerdata[i].kills > playerdata[trd].kills && i != fst && i != snd)
			{
				trd = i;
				if(i == fst)
				{
					snd = 0;
				}
				if(i == snd)
				{
					trd = 0;
				}
			}
		}
	}
	char buffer1[128] = "Top Kills:\n";
	char buffer2[128] = "";
	char buffer3[128] = "";
	char buffer4[128] = "";
	if(IsValidClient(fst) && playerdata[fst].kills > 0)
	{
		Format(buffer2, sizeof(buffer2), "1.) %N - %i\n", fst, playerdata[fst].kills);
	}
	if(IsValidClient(snd) && playerdata[snd].kills > 0)
	{
		Format(buffer3, sizeof(buffer3), "2.) %N - %i\n", snd, playerdata[snd].kills);
	}
	if(IsValidClient(trd) && playerdata[trd].kills > 0)
	{
		Format(buffer4, sizeof(buffer4), "3.) %N - %i\n", trd, playerdata[trd].kills);
	}
	char buf[512];
	Format(buf, sizeof(buf), "%s%s%s%s", buffer1, buffer2, buffer3, buffer4);
	Handle hudText = CreateHudSynchronizer();
	SetHudTextParams(0.15, -1.7, TEXT_TIMER, 255, 255, 255, 255);

	for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            ShowSyncHudText(i, hudText, buf);
        }
    }

	CloseHandle(hudText);

	return Plugin_Continue;
}

stock bool IsValidClient(int client)
{
    if (client <= 0)
        return false;
    
    if (client > MaxClients)
        return false;
    
    if (!IsClientConnected(client))
        return false;
    
    if (IsFakeClient(client))
        return false;

    return IsClientInGame(client);
}