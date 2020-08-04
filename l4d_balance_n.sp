/* Plugin Template generated by Pawn Studio */

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>

#define ZOMBIECLASS_SURVIVOR	9
#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6
int ZOMBIECLASS_TANK = 5;

int GameMode;
int L4D2Version;

bool Debug = false;
/* 
* 
* some code from "L4D2 Monster Bots",	author = "Machine"
* 
*/
public Plugin myinfo = 
{
	name = "难度平衡",
	author = "Pan Xiaohai",
	description = "<- Description ->",
	version = "1.3",
	url = "<- URL ->"
} 

bool ShowHud[MAXPLAYERS+1];
 
int CurrentAverage; 

int PlayerIntensity[MAXPLAYERS+1];
int PlayerTotalIntensity[MAXPLAYERS+1];
int PlayerTick[MAXPLAYERS+1];

bool NeedDrawHud = false;
bool HaveTank = false;

int AllTotalIntensity;
int AllTotalTick = 1; 

int CiCount;
int SiCount;
int SurvivorCount;

int MobTick;

int MaxSpecial;
int MaxCommon;

int AdustTick;
int DirectorStopTick;
bool DirectorStoped;

ConVar l4d_balance_difficulty_min;
ConVar l4d_balance_difficulty_max;

ConVar l4d_balance_enable; 
ConVar l4d_balance_reaction_time; 
ConVar l4d_balance_setting_password;
ConVar l4d_balance_hud;

ConVar l4d_balance_include_bot;

ConVar l4d_balance_health_increment; 
ConVar l4d_balance_health_witch;
ConVar l4d_balance_health_tank; 
ConVar l4d_balance_health_hunter;
ConVar l4d_balance_health_smoker; 
ConVar l4d_balance_health_boomer;
ConVar l4d_balance_health_charger; 
ConVar l4d_balance_health_jockey; 
ConVar l4d_balance_health_spitter; 
ConVar l4d_balance_health_zombie; 

ConVar l4d_balance_limit_special; 
ConVar l4d_balance_limit_special_add; 
ConVar l4d_balance_limit_common;
ConVar l4d_balance_limit_common_add;

public void OnPluginStart()
{
	GameCheck(); 	
	if(GameMode != 1) return;
	l4d_balance_enable = CreateConVar("l4d_balance_enable", "1", "是否开启插件", FCVAR_NONE, true, 0.0, true, 1.0);
	l4d_balance_reaction_time = CreateConVar("l4d_balance_reaction_time", "10", "平衡反应时间", FCVAR_NONE, true, 1.0, true, 30.0); 
	
	l4d_balance_difficulty_min = 	CreateConVar("l4d_balance_difficulty_min", "30", "最小难度", FCVAR_NONE, true, 0.0, true, 100.0);
	l4d_balance_difficulty_max = 	CreateConVar("l4d_balance_difficulty_max", "90", "最大难度", FCVAR_NONE, true, 0.0, true, 100.0);	
	l4d_balance_include_bot = 	 	CreateConVar("l4d_balance_include_bot", "1", "平衡是否包括机器人.0=不包括.1=包括", FCVAR_NONE, true, 0.0, true, 1.0); 
	l4d_balance_hud = 	 			CreateConVar("l4d_balance_hud", "1", "自动开启HUD", FCVAR_NONE, true, 0.0, true, 1.0); 
	l4d_balance_setting_password = 	CreateConVar("l4d_balance_setting_password", "", "password for seting diffulty"); 

	l4d_balance_health_increment = 	CreateConVar("l4d_balance_health_add", "20", "每加入一名生还者，特感血量加多少(百分比)", FCVAR_NONE, true); 	
	l4d_balance_health_tank = 		CreateConVar("l4d_balance_health_tank", "8000", "tank 初始血量", FCVAR_NONE, true, 1.0); 	
	l4d_balance_health_witch =		CreateConVar("l4d_balance_health_witch", "1000", "witch 初始血量", FCVAR_NONE, true, 1.0);
	l4d_balance_health_hunter =		CreateConVar("l4d_balance_health_hunter", "250", "hunter 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_smoker = 	CreateConVar("l4d_balance_health_smoker", "250", "smoker 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_boomer =		CreateConVar("l4d_balance_health_boomer", "50", "boomer 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_charger = 	CreateConVar("l4d_balance_health_charger", "600", "charger 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_jockey = 	CreateConVar("l4d_balance_health_jockey", "325", "jockey 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_spitter = 	CreateConVar("l4d_balance_health_spitter", "100", "spitter 初始血量", FCVAR_NONE, true, 1.0); 
	l4d_balance_health_zombie = 	CreateConVar("l4d_balance_health_zombie", "50", "普感 初始血量", FCVAR_NONE, true, 1.0); 

	l4d_balance_limit_special	= 	CreateConVar("l4d_balance_limit_special", "4", "初始特感上限", FCVAR_NONE, true, 0.0);
	l4d_balance_limit_special_add = CreateConVar("l4d_balance_limit_special_add", "1.5", "每加入一名生还者，特感上限增加多少", FCVAR_NONE, true, 0.0);
	l4d_balance_limit_common = 		CreateConVar("l4d_balance_limit_common", "30", "初始普感上限", FCVAR_NONE, true, 0.0); 
	l4d_balance_limit_common_add = 	CreateConVar("l4d_balance_limit_common_add", "6.5", "每加入一名生还者，普感上限增加多少", FCVAR_NONE, true, 0.0); 
 	
	AutoExecConfig(true, "l4d_balance");
	
	RegConsoleCmd("sm_balance", sm_balance); 
	RegConsoleCmd("sm_difficulty", sm_difficulty); 
	RegConsoleCmd("sm_dinfo", sm_dinfo); 
	HookEvent("player_spawn", player_spawn);
	HookEvent("player_first_spawn", player_first_spawn);
	HookEvent("player_death", player_death); 
	
	HookEvent("round_start", round_start, EventHookMode_PostNoCopy);
	HookEvent("round_end", round_end, EventHookMode_PostNoCopy);
	HookEvent("finale_win", map_transition, EventHookMode_PostNoCopy);
	HookEvent("mission_lost", round_end, EventHookMode_PostNoCopy);
	HookEvent("round_start_pre_entity",  round_end, EventHookMode_PostNoCopy);
	HookEvent("round_start_post_nav",  round_end, EventHookMode_PostNoCopy);
	HookEvent("map_transition",  map_transition, EventHookMode_PostNoCopy);
	HookEvent("player_left_start_area", player_left_start_area, EventHookMode_PostNoCopy);
	HookEvent("survival_round_start", player_left_start_area, EventHookMode_PostNoCopy);
	// HookEvent("door_unlocked", door_unlocked);
	ResetAllState();
}

public Action sm_balance(int client, int args)
{
	if(client > 0)
	{
		ShowHud[client]=!ShowHud[client]; 
	}
}
 
public Action sm_dinfo(int client, int args)
{
	if(client > 0)
	{
		char msgstr[500] = "";
		Format(msgstr, 500, "生还者数量 : %d \n", SurvivorCount);
		Format(msgstr, 500, "\n%sTank血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_tank)), RoundFloat( GetConVarFloat(FindConVar("z_tank_health"))));
		Format(msgstr, 500, "%sWitch血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_witch)), RoundFloat( GetConVarFloat(FindConVar("z_witch_health"))));
		Format(msgstr, 500, "%s普感血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_zombie)), RoundFloat( GetConVarFloat(FindConVar("z_health"))));
		Format(msgstr, 500, "%sSmoker血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_smoker)), RoundFloat( GetConVarFloat(FindConVar("z_gas_health"))));
		Format(msgstr, 500, "%sHunter血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_hunter)), RoundFloat( GetConVarFloat(FindConVar("z_hunter_health"))));
		Format(msgstr, 500, "%sBoomer血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_boomer)), RoundFloat( GetConVarFloat(FindConVar("z_exploding_health"))));
		if(L4D2Version)
		{
			Format(msgstr, 500, "%sCharger血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_charger)), RoundFloat( GetConVarFloat(FindConVar("z_charger_health"))));
			Format(msgstr, 500, "%sSpitter血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_spitter)), RoundFloat( GetConVarFloat(FindConVar("z_spitter_health"))));
			Format(msgstr, 500, "%sJockey血量: %d to %d \n", msgstr, RoundFloat(GetConVarFloat(l4d_balance_health_jockey)), RoundFloat( GetConVarFloat(FindConVar("z_jockey_health"))));
		}
		Format(msgstr, 500, "\n%s特感上限 : %d to %d \n", msgstr, GetConVarInt(l4d_balance_limit_special),  MaxSpecial);
		Format(msgstr, 500, "%sz_common_limit: %d to %d \n", msgstr, GetConVarInt(l4d_balance_limit_common),  RoundFloat( GetConVarFloat(FindConVar("z_common_limit"))));
		Format(msgstr, 500, "%sz_background_limit: %d \n", msgstr, RoundFloat( GetConVarFloat(FindConVar("z_background_limit"))));
		Format(msgstr, 500, "%sz_mega_mob_size: %d \n", msgstr,  RoundFloat( GetConVarFloat(FindConVar("z_mega_mob_size"))));

		PrintToChat(client, "请查看控制台输出");
		PrintToConsole(client, msgstr);
	}
}
 
public Action sm_difficulty(int client, int args)
{
	if(client > 0)
	{
		char password[20] = "";
		char arg[20];
		GetConVarString(l4d_balance_setting_password, password, sizeof(password));
		GetCmdArg(1, arg, sizeof(arg));
		//PrintToChatAll("arg %s, password %s", arg, password);
		if(password[0] != EOS && StrEqual(arg, password))
		{
			GetCmdArg(2, arg, sizeof(arg));		 
			int d = StringToInt(arg);
			if(d >= 0 && d <= 100)
			{				
				PrintToChatAll("The difficulty change from %d to %d", GetConVarInt(l4d_balance_difficulty_min), d);
				SetConVarInt(FindConVar("l4d_balance_difficulty"), d);
			}
			else
			{
				PrintToChat(client, "Value must >= 0 and <= 100");				
			}
		}
		else
		{
			PrintToChat(client, "Your password is incorrect");
			PrintToChatAll("The current difficulty is %d", GetConVarInt(l4d_balance_difficulty_min));
		}
	}
}

public void player_spawn(Event hEvent, const char[] strName, bool DontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid")); 
	if(client > 0)
	{
		ShowHud[client] = false;
		// if(IsClientInGame(client)) PrintToChat(client, "!balance to turn on Hud");
	}
}

public void player_first_spawn(Event hEvent, const char[] strName, bool DontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3)
	{
		int zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if(zClass == 8)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(l4d_balance_health_tank));
			SetEntProp(client, Prop_Data, "m_iMaxHealth", GetConVarInt(l4d_balance_health_tank));
		}
	}
}

public void player_death(Event hEvent, const char[] strName, bool DontBroadcast)
{
	if(!GetConVarBool(l4d_balance_hud))
		return;
	
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(client > 0)
	{
		ShowHud[client] = true;
		if(IsClientInGame(client)) PrintToChat(client, "聊天框输入 !balance 关闭面板");
	}
}

public void round_start(Event event, const char[] name, bool dontBroadcast)
{
	int flags = GetConVarFlags(FindConVar("z_max_player_zombies"));
	SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, false);
	SetConVarFlags(FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY);

	if(GameMode != 1) return;		
	ResetAllState();
}

public void player_left_start_area(Event event, const char[] name, bool dontBroadcast)
{
	if(GameMode != 1) return;	
	CreateTimer(1.0, TimerUpdatePlayer, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	
	CreateTimer(1.5, TimerShowHud, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(30.0, TimerDelayStartAjust, 0, TIMER_FLAG_NO_MAPCHANGE);	
	PrintToServer("balance: player_left_start_area");
}

public void door_unlocked(Event event, const char[] name, bool dontBroadcast)
{
	if(GameMode != 1) return;	
	CreateTimer(1.0, TimerUpdatePlayer, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	
	CreateTimer(1.5, TimerShowHud, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(30.0, TimerDelayStartAjust, 0, TIMER_FLAG_NO_MAPCHANGE);
}

public void round_end(Event event, const char[] name, bool dontBroadcast)
{
	ResetAllState();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == 3)
			{
				if (IsFakeClient(i))
				{
					KickClient(i);
				}
			}
		}
	}	
}

public void map_transition(Event event, const char[] name, bool dontBroadcast)
{
	int totalaverage = AllTotalIntensity / AllTotalTick; 
	PrintToServer("\x04[balance] \x01Map Change"); 
	PrintToServer("\x04[balance] \x01server intensity average %d", totalaverage); 
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2)
		{	
			PrintToServer("\x04[balance] \x01%N intensity average %d", i, PlayerTotalIntensity[i]/PlayerTick[i]); 
		}
	}  
	ResetAllState(); 
}

void ResetAllState()
{ 
	AllTotalIntensity = 0;
	AllTotalTick = 1;
	DirectorStoped = false;
	AdustTick = GetConVarInt(l4d_balance_reaction_time);
	DirectorStopTick = GetConVarInt(l4d_balance_reaction_time);
	CiCount = SiCount = 0;
	NeedDrawHud = false;
	MobTick = 0;
	HaveTank = false;
	SurvivorCount = 1;
	for(int i = 1; i <= MaxClients; i++)
	{
		PlayerIntensity[i] = 0;
		PlayerTotalIntensity[i] = 0;
		PlayerTick[i] = 1;
	}
}

public Action TimerUpdatePlayer(Handle timer, any data)
{
	int playercout = 0;
	int currentAverage = 0;
	int infectedCount = 0;
	int difficult = GetConVarInt(l4d_balance_difficulty_min);
	bool needDrawHud = false;
	bool haveTank = false;
 	int survivorCount = 0;
	bool includeBot = GetConVarInt(l4d_balance_include_bot) == 1;
	for( int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == 2)
			{
				bool fake = IsFakeClient(i);
				if(!includeBot && fake) continue;
				if(IsPlayerAlive(i))
				{
					PlayerIntensity[i] = GetEntProp(i, Prop_Send, "m_clientIntensity" );
					PlayerTotalIntensity[i] += PlayerIntensity[i]; 
					currentAverage += PlayerIntensity[i];
				}
				else
				{
					PlayerIntensity[i] = difficult;
					PlayerTotalIntensity[i] += PlayerIntensity[i]; 
					currentAverage += PlayerIntensity[i];
				}				
				PlayerTick[i]++; 
				playercout++;
				if(ShowHud[i] && !fake) needDrawHud = true;
				survivorCount++;
			}
			else if(IsPlayerAlive(i))
			{
				infectedCount++;
				if(IsInfected(i, ZOMBIECLASS_TANK)) haveTank = true;
			}
		}
		else PlayerIntensity[i] = 0;
	}  
	SurvivorCount = survivorCount;
	HaveTank = haveTank;
	NeedDrawHud = needDrawHud;
	if(playercout > 0) CurrentAverage = currentAverage / playercout; 
	else CurrentAverage = 0;
	AllTotalIntensity += CurrentAverage;
	AllTotalTick++;	
	
	SiCount = infectedCount;
	
	int reactionTime = GetConVarInt(l4d_balance_reaction_time); 
	 
	if(CurrentAverage < difficult) AdustTick--;
	else AdustTick++;
	if(AdustTick <= 0) AdustTick = 0;
	if(AdustTick >= reactionTime) AdustTick = reactionTime;
	
	if(HaveTank) AdustTick = reactionTime;
	
	if(CurrentAverage > GetConVarInt(l4d_balance_difficulty_max)) DirectorStopTick--;
	else DirectorStopTick++;
	if(DirectorStopTick <= 0) DirectorStopTick = 0;
	if(DirectorStopTick >= reactionTime) DirectorStopTick = reactionTime;
	
	if(Debug)
	{
		int totalaverage = AllTotalIntensity/AllTotalTick; 
		PrintToServer("\x04[balance] \x01current intensity %d, average %d", CurrentAverage, totalaverage); 
	}

	return Plugin_Continue;
}

public Action TimerAjust(Handle timer, any data)
{
	int siNeed = 0;
	int ciNeed = 0;
	int mobNeed = 0;
	int enable = GetConVarInt(l4d_balance_enable);
	if(enable == 0) return Plugin_Continue;
	
	bool havePlayer = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i))
		{
			havePlayer = true;
			break;
		}
	}
	if(!havePlayer)
		return Plugin_Continue;
	
	int reactionTime = GetConVarInt(l4d_balance_reaction_time);
	UpdateSeting();
	if(DirectorStopTick == 0)
	{
		if(!DirectorStoped)
		{
			PrintToServer("Director Stopped"); 
		}
		SetConVarInt(FindConVar("director_no_specials"), 1);
		SetConVarInt(FindConVar("director_no_mobs"), 1);
		DirectorStoped=true;
	}
	else
	{
		if(DirectorStoped)
		{
			PrintToServer("Director Started"); 
		}
		SetConVarInt(FindConVar("director_no_specials"), 0);
		SetConVarInt(FindConVar("director_no_mobs"), 0);		
		DirectorStoped = false;
	}	
	CiCount = GetInfectedCount();
	
	if(AdustTick == 0 ) 
	{			
		SetConVarInt(FindConVar("z_max_player_zombies"), 8);
		if(SiCount < MaxSpecial)
		{ 
			siNeed = 1;	  
		}
		MobTick += 2;
		if(CiCount < MaxCommon)
		{
			ciNeed = 0; 
			if( MobTick >= reactionTime)
			{				
				mobNeed = 1;
			}
		}
		if(siNeed > 0 || ciNeed > 0 || mobNeed > 0) Z_Spawn_Old(siNeed, ciNeed, mobNeed);
	}
	else MobTick = 0;
	return Plugin_Continue;
}

void UpdateSeting()
{ 
	float inc = GetConVarFloat(l4d_balance_health_increment) / 100.0;	
	int survivorCount = SurvivorCount;
	if(survivorCount < 4) survivorCount = 4;	
	inc = inc * (survivorCount - 4);
	SetConVarFloat(FindConVar("z_health"),  GetConVarFloat(l4d_balance_health_zombie) * (1.0 + inc));	
	SetConVarFloat(FindConVar("z_hunter_health"),  GetConVarFloat(l4d_balance_health_hunter) * (1.0 + inc));
	SetConVarFloat(FindConVar("z_gas_health"),  GetConVarFloat(l4d_balance_health_smoker) * (1.0 + inc));
	SetConVarFloat(FindConVar("z_exploding_health"),  GetConVarFloat(l4d_balance_health_boomer) * (1.0 + inc));
	if(L4D2Version)
	{
		SetConVarFloat(FindConVar("z_charger_health"), GetConVarFloat(l4d_balance_health_charger) * (1.0 + inc));
		SetConVarFloat(FindConVar("z_spitter_health"),  GetConVarFloat(l4d_balance_health_spitter) * (1.0 + inc));
		SetConVarFloat(FindConVar("z_jockey_health"),  GetConVarFloat(l4d_balance_health_jockey) * (1.0 + inc));
	}
	SetConVarFloat(FindConVar("z_witch_health"),  GetConVarFloat(l4d_balance_health_witch) * (1.0 + inc));
	SetConVarFloat(FindConVar("z_tank_health"),  GetConVarFloat(l4d_balance_health_tank) * (1.0 + inc));
 
	MaxSpecial = GetConVarInt(l4d_balance_limit_special);
	MaxSpecial += RoundToZero(GetConVarFloat(l4d_balance_limit_special_add) * (survivorCount - 4));
	
	MaxCommon = GetConVarInt(l4d_balance_limit_common); 
	MaxCommon += RoundToZero(GetConVarFloat(l4d_balance_limit_common_add) * (survivorCount - 4));
	SetConVarFloat(FindConVar("z_common_limit"), MaxCommon * 1.0);
	SetConVarFloat(FindConVar("z_background_limit"), MaxCommon * 0.5);
	SetConVarFloat(FindConVar("z_mega_mob_size"), MaxCommon * 1.0);
}
 
public Action TimerDelayStartAjust(Handle timer, any data)
{
	CreateTimer(2.0, TimerAjust, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);	
}

Handle pInfHUD 		= INVALID_HANDLE;
public Action TimerShowHud(Handle timer, any data)
{
	if(!NeedDrawHud)return Plugin_Continue;
	pInfHUD = CreatePanel(GetMenuStyleHandle(MenuStyle_Default));
	char buffer[65];	
 	SetPanelTitle(pInfHUD, "难度平衡系统"); 
	Format(buffer, sizeof(buffer), "当前难度 ( %d ~ %d )", GetConVarInt(l4d_balance_difficulty_min),GetConVarInt(l4d_balance_difficulty_max));	
	DrawPanelItem(pInfHUD, buffer, ITEMDRAW_RAWLINE);
	DrawPanelItem(pInfHUD, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
 
	Format(buffer, sizeof(buffer), "当前 : %d ",  CurrentAverage);
	DrawPanelItem(pInfHUD, buffer);
	
	int totalaverage = AllTotalIntensity / AllTotalTick;
	Format(buffer, sizeof(buffer), "平均 : %d ", totalaverage);
	DrawPanelItem(pInfHUD, buffer);
	
	if(AdustTick == 0) Format(buffer, sizeof(buffer), "增加难度");
	else Format(buffer, sizeof(buffer), "增加难度倒计时: %d ",  AdustTick);
	DrawPanelItem(pInfHUD, buffer);	
	
	if(DirectorStopTick == 0) Format(buffer, sizeof(buffer), "降低难度");
	else Format(buffer, sizeof(buffer), "降低难度倒计时: %d ",  DirectorStopTick);
	DrawPanelItem(pInfHUD, buffer);		
	
	DrawPanelItem(pInfHUD, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE); 
	DrawPanelItem(pInfHUD, "感染者", ITEMDRAW_RAWLINE);
	
	int sicount = SiCount;
 	 
	int cicount = CiCount;
	
	Format(buffer, sizeof(buffer), "特殊感染者 : %d/%d ", sicount, MaxSpecial);
	DrawPanelItem(pInfHUD, buffer );
	Format(buffer, sizeof(buffer), "普通感染者 : %d/%d ", cicount, MaxCommon);
	DrawPanelItem(pInfHUD, buffer );	
	
	DrawPanelItem(pInfHUD, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE); 
	DrawPanelItem(pInfHUD, "生还者压力"); 
	DrawPanelItem(pInfHUD, " ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	
	bool includeBot = GetConVarInt(l4d_balance_include_bot) == 1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) == 3) continue;
		if (!includeBot && IsFakeClient(i)) continue;  
		{
			int a = PlayerTotalIntensity[i] / PlayerTick[i];
			Format(buffer, sizeof(buffer), "%N (%d) : %d ", i  ,a, PlayerIntensity[i]);
			DrawPanelItem(pInfHUD, buffer ,ITEMDRAW_RAWLINE);
		}
	}	
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i)) continue;
		if(IsFakeClient(i)) continue;  
		if(!ShowHud[i]) continue;
		if (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None)
		{	
			SendPanelToClient(pInfHUD, i, Menu_InfHUDPanel, 1); 			
		} 
	}
	CloseHandle(pInfHUD);  
	return Plugin_Continue;
}

public int Menu_InfHUDPanel(Menu menu, MenuAction action, int param1, int param2) { return; }

void Z_Spawn_Old(int siCount, int ciCount, int mob)
{
	int bot = CreateFakeClient("Monster");
	if (bot > 0)
	{		
		ChangeClientTeam(bot,3);
		for(int i = 0; i < siCount; i++)
		{ 
			int random = GetRandomInt(1, 6);
			if(!L4D2Version) random = GetRandomInt(1, 3);
			switch(random)
			{
				case 1:
					SpawnCommand(bot, "z_spawn_old", "smoker auto");
				case 2:
					SpawnCommand(bot, "z_spawn_old", "boomer auto");
				case 3:
					SpawnCommand(bot, "z_spawn_old", "hunter auto");
				case 4:
					SpawnCommand(bot, "z_spawn_old", "spitter auto");
				case 5:
					SpawnCommand(bot, "z_spawn_old", "jockey auto");
				case 6:
					SpawnCommand(bot, "z_spawn_old", "charger auto");
			}
		} 
		for(int i = 0; i < ciCount; i++)
		{
			SpawnCommand(bot, "z_spawn_old", "auto");
		} 
		if(mob > 0)
		{
			SpawnCommand(bot, "z_spawn", "mob"); 			
			MobTick = 0;
		}
		Kickbot(INVALID_HANDLE, bot);
		//CreateTimer(0.1,Kickbot,bot);
	}	  
}

public Action Kickbot(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		if (IsFakeClient(client))
		{
			KickClient(client);
		}
	}
}

stock void SpawnCommand(int client, char[] command, char[] arguments = "")
{
	if (client)
	{ 
		int flags = GetCommandFlags(command);
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
		FakeClientCommand(client, "%s %s", command, arguments);
		SetCommandFlags(command, flags);
	}
}

int GetInfectedCount()
{
	int ent = -1;
	int count = 0;
	while ((ent = FindEntityByClassname(ent,  "infected" )) != -1)
	{
		count++;
	}
	return count;
}

void GameCheck()
{
	char GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	if (StrEqual(GameName, "survival", false))
		GameMode = 3;
	else if (StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false))
		GameMode = 2;
	else if (StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false))
		GameMode = 1;
	else
	{
		GameMode = 0;
 	}
	
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrEqual(GameName, "left4dead2", false))
	{
		ZOMBIECLASS_TANK = 8;
		L4D2Version = true;
	}	
	else
	{
		ZOMBIECLASS_TANK = 5;
		L4D2Version = false;
	}
}

int IsInfected(int client, int type)
{
	int class = GetEntProp(client, Prop_Send, "m_zombieClass");
	if(type == class) return true;
	else return false;
}