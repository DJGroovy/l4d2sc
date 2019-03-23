#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.6"

public Plugin:myinfo = 
{
	name = "弹药升级修复",
	author = "V10",
	description = "Fixes bugs with upgrade packs on server more than 8 players",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1619490"
}

#define MAX_UPGRADEPACKS 10
#define L4D_MAXPLAYERS 32
#define TEAM_SURVIVOR 2
#define HARDCHECKS 1
#define DEBUG 0

new g_SurvivorUseMaskO=-1;
new g_UpgradePackCanUseCountO = -1;

new Handle:g_hFindUseEntity = INVALID_HANDLE;
static Handle:IncendAmmoMultiplier = INVALID_HANDLE;
static Handle:SplosiveAmmoMultiplier = INVALID_HANDLE;
static Handle:SplosiveAmmoSuperimposed = INVALID_HANDLE;
new Handle:g_hCvarUseRadius = INVALID_HANDLE;
new Handle:g_pCvarUseAmmoFix = INVALID_HANDLE;

new Handle:g_UpgradePackResetTimers[MAX_UPGRADEPACKS];
new g_UpgradePackEntityId[MAX_UPGRADEPACKS];
new g_TotalUpgradesCount[MAX_UPGRADEPACKS];
new bool:g_UsedUpgradePack[MAX_UPGRADEPACKS][L4D_MAXPLAYERS+1];
new g_CurrentMaxPackId;
new g_LastUsedUpgradePackId;

new g_iLastUpgrade[MAXPLAYERS+1];
new g_iLastUpgradeAmmo[MAXPLAYERS+1];

new g_iLastClip[MAXPLAYERS+1];
new g_iLastAmmo[MAXPLAYERS+1];

#if HARDCHECKS == 0
	new bool:g_DelayButton[L4D_MAXPLAYERS+1];
#endif

public OnPluginStart()
{
	HookEvent("upgrade_pack_added",Event_UpgradePackAdded,EventHookMode_Pre);
	HookEvent("round_start",Event_RoundStart);
	
	CreateConVar("l4d2_upgradepackfix_version", PLUGIN_VERSION, "UpgradePackFix plugin version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	IncendAmmoMultiplier = CreateConVar("l4d2_upgradepackfix_incendammomulti", "1.0", "燃烧子弹倍率");
	SplosiveAmmoMultiplier = CreateConVar("l4d2_upgradepackfix_explosiveammomulti", "1.0", "高爆子弹倍率");
	SplosiveAmmoSuperimposed = CreateConVar("l4d2_upgradepackfix_superimposed", "0", "弹药升级叠加");
	g_pCvarUseAmmoFix = CreateConVar("l4d2_upgradepackfix_ammofix", "1", "弹药失踪修复");
	AutoExecConfig(true, "l4d2_upgradepack");
	
	g_SurvivorUseMaskO = FindSendPropInfo("CBaseUpgradeItem","m_iUsedBySurvivorsMask");
	
	new Handle:gConf = LoadGameConfigFile("upgradepackfix");
	
	g_UpgradePackCanUseCountO = GameConfGetOffset(gConf,"m_iUpgradePackCanUseCount");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, "CTerrorPlayer::FindUseEntity");
	PrepSDKCall_AddParameter(SDKType_Float,SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float,SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float,SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData,SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool,SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity,SDKPass_Pointer);
	g_hFindUseEntity = EndPrepSDKCall();
	
	CloseHandle(gConf);
	if (g_hFindUseEntity == INVALID_HANDLE){
		SetFailState("Can't get CTerrorPlayer::FindUseEntity SDKCall!");
		return;
	}			
	
	if (g_UpgradePackCanUseCountO == -1 || g_SurvivorUseMaskO == -1)
		SetFailState("Cannot get offsets");
	
	g_hCvarUseRadius = FindConVar("player_use_radius");
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (client == 0 || client > MaxClients) return Plugin_Continue;
#if HARDCHECKS == 1
	if (buttons & IN_USE){
#else
	if (buttons & IN_USE && !g_DelayButton[client]){
		g_DelayButton[client]=true;
		CreateTimer(0.2, ResetDelay, client);
#endif
		
		new UseEntity = FindUseEntity(client);	//GetClientAimTarget(client, false);
		if (!IsValidEntity(UseEntity))
			return Plugin_Continue;
		
		decl String:ClassName[30];
		GetEntityNetClass(UseEntity,ClassName,sizeof(ClassName));
		
		#if DEBUG
			LogMessage("OnPlayerRunCmd_USE client=%d, UseEntity=%d, entclass=%s",client,UseEntity,ClassName);
		#endif
		
		if (!strcmp(ClassName,"CBaseUpgradeItem")){
			g_LastUsedUpgradePackId = GetUpgradePackId(UseEntity);
			UpgradePackCheckUsable(client,g_LastUsedUpgradePackId);
		}else {
		  #if HARDCHECKS == 1
			decl Float:PackCoords[3];
			decl Float:UsedCoords[3];
			GetClientAbsOrigin(client, UsedCoords);
			if (g_LastUsedUpgradePackId>-1){
				if (IsValidEntity(g_UpgradePackEntityId[g_LastUsedUpgradePackId])){					
					GetEntityNetClass(g_UpgradePackEntityId[g_LastUsedUpgradePackId],ClassName,sizeof(ClassName));
					if (!strcmp(ClassName,"CBaseUpgradeItem")){
						GetEntPropVector(g_UpgradePackEntityId[g_LastUsedUpgradePackId], Prop_Send, "m_vecOrigin", PackCoords);
						new Float:dist=GetVectorDistance(PackCoords,UsedCoords);
					
						#if DEBUG
							LogMessage("Dist to last %f",dist);					
						#endif
					
						if (dist < 196.0){
							UpgradePackCheckUsable(client,g_LastUsedUpgradePackId);						
						}
					}else{
						g_LastUsedUpgradePackId=-1;
					}
				}else {
					g_LastUsedUpgradePackId=-1;
				}
			}
		  #endif
		}
	 
	}
	return Plugin_Continue;
}
public Event_UpgradePackAdded(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new UseEntity = FindUseEntity(client);	

	new upgradeid = GetEventInt(event, "upgradeid");
	decl String:class[256];
	GetEdictClassname(upgradeid, class, sizeof(class));
	//PrintToChatAll("Upgrade caught, entity = %i, entclass: %s", upgradeid, class);
	
	if (StrEqual(class, "upgrade_laser_sight"))
		return;
	
	#if DEBUG
		LogMessage("UpgradePackAdded client=%d, UseEntity=%d",client,UseEntity);
	#endif
	
	if (!IsValidEntity(UseEntity)) 
		return;
	
	new UpgradePackId = GetUpgradePackId(UseEntity);
	
	#if DEBUG
		LogMessage("upgrade pack used cl=%N. [%d,%d])",client,UpgradePackId,g_TotalUpgradesCount[UpgradePackId]);
	#endif
	
	g_UsedUpgradePack[UpgradePackId][client] = true;
	g_TotalUpgradesCount[UpgradePackId]--;	
	
	SetEntData(UseEntity, g_UpgradePackCanUseCountO, g_TotalUpgradesCount[UpgradePackId], 1,true);
	if (g_UpgradePackResetTimers[UpgradePackId] == INVALID_HANDLE)
		g_UpgradePackResetTimers[UpgradePackId] = CreateTimer(0.2,Timer_UpgradePackReset,UpgradePackId);
	
	new newammo = 0, upgrade = -1;
	new ammo = GetSpecialAmmoInPlayerGun(client);
	
	if (StrEqual(class, "upgrade_ammo_incendiary"))
	{
		upgrade = 1;
		newammo = RoundFloat(ammo * GetConVarFloat(IncendAmmoMultiplier));
	}
	else if (StrEqual(class, "upgrade_ammo_explosive"))	
	{
		upgrade = 2;
		newammo = RoundFloat(ammo * GetConVarFloat(SplosiveAmmoMultiplier));
	}
	
	if(GetConVarBool(SplosiveAmmoSuperimposed) && g_iLastUpgrade[client] == upgrade)
		newammo += g_iLastUpgradeAmmo[client];
	
	if (newammo > 1)
		SetSpecialAmmoInPlayerGun(client, newammo);
	
	new weapon = GetPlayerWeaponSlot(client, 0);
	if(weapon > MaxClients && GetConVarBool(g_pCvarUseAmmoFix))
	{
		new ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
		SetEntProp(weapon, Prop_Send, "m_iClip1", g_iLastClip[client]);
		SetEntProp(client, Prop_Send, "m_iAmmo", g_iLastAmmo[client], _, ammoType);
	}
	
	g_iLastUpgrade[client] = 0;
	g_iLastUpgradeAmmo[client] = 0;
	g_iLastClip[client] = 0;
	g_iLastAmmo[client] = 0;
//	UpgradePackReset(UpgradePackId);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	ClearUpgradePacks();
}

#if HARDCHECKS == 0
public Action:ResetDelay(Handle:timer, any:client)
{
	g_DelayButton[client] = false;
	return Plugin_Stop;
}
#endif

public Action:Timer_UpgradePackReset(Handle:timer, any:PackId)
{
	if (!IsValidEntity(g_UpgradePackEntityId[PackId]))
		return Plugin_Stop;
	UpgradePackReset(PackId);
	g_UpgradePackResetTimers[PackId]=INVALID_HANDLE;
	return Plugin_Stop;
}

GetUpgradePackId(entityId)
{
	for (new i; i < MAX_UPGRADEPACKS ; i++)
		if (g_UpgradePackEntityId[i] == entityId)
			return i;
		
	return CreateUpgradePack(entityId);	
}

UpgradePackCheckUsable(client,PackId)
{
	SetEntData(g_UpgradePackEntityId[PackId], g_SurvivorUseMaskO, (g_UsedUpgradePack[PackId][client] ? 255 : 0), 1, true);
	
	if (g_UsedUpgradePack[PackId][client] && g_UpgradePackResetTimers[PackId] == INVALID_HANDLE)
		g_UpgradePackResetTimers[PackId] = CreateTimer(0.2,Timer_UpgradePackReset,PackId);
	
	new weapon = GetPlayerWeaponSlot(client, 0);
	if(weapon > MaxClients)
	{
		new upgrade = GetEntProp(weapon, Prop_Send, "m_upgradeBitVec");
		if(upgrade & 1)
			g_iLastUpgrade[client] = 1;		// upgrade_ammo_incendiary
		else if(upgrade & 2)
			g_iLastUpgrade[client] = 2;		// upgrade_ammo_explosive
		
		if(upgrade & 3)
			g_iLastUpgradeAmmo[client] = GetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 1);
		
		new ammoType = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
		g_iLastClip[client] = GetEntProp(weapon, Prop_Send, "m_iClip1");
		g_iLastAmmo[client] = GetEntProp(client, Prop_Send, "m_iAmmo", _, ammoType);
	}
}

CreateUpgradePack(entityId)
{
	g_TotalUpgradesCount[g_CurrentMaxPackId] = GetTeamClientCount(TEAM_SURVIVOR);
	g_UpgradePackEntityId[g_CurrentMaxPackId] = entityId;
	
	#if DEBUG
		LogMessage("created upgrade pack id=%d, ent=%d, upgreades=%d)",g_CurrentMaxPackId,entityId,g_TotalUpgradesCount[g_CurrentMaxPackId]);
	#endif
	
	for (new i = 1; i <= MaxClients; i++)
		g_UsedUpgradePack[g_CurrentMaxPackId][i] = false;
	
	new result = g_CurrentMaxPackId;
	g_CurrentMaxPackId++;
	if (g_CurrentMaxPackId == MAX_UPGRADEPACKS) 
		g_CurrentMaxPackId = 0;	
	return result;
}

ClearUpgradePacks()
{
	g_CurrentMaxPackId=0;
	g_LastUsedUpgradePackId = -1;
	for (new i; i < MAX_UPGRADEPACKS ; i++){
		g_UpgradePackEntityId[i] = -1;
		g_TotalUpgradesCount[i] = 0;
		for (new j = 1; j <= MaxClients; j++)
			g_UsedUpgradePack[i][j] = false;
	}
	for (new i = 1; i <= MaxClients; ++i)
	{
		g_iLastUpgrade[i] = 0;
		g_iLastUpgradeAmmo[i] = 0;
		g_iLastAmmo[i] = 0;
		g_iLastClip[i] = 0;
	}
}

UpgradePackReset(PackId)
{
	SetEntData(g_UpgradePackEntityId[PackId], g_SurvivorUseMaskO, 0, 1,true);
}

FindUseEntity(client){	return SDKCall(g_hFindUseEntity,client,GetConVarFloat(g_hCvarUseRadius),0.0,0.0,0,false);}



stock GetSpecialAmmoInPlayerGun(client) //returns the amount of special rounds in your gun
{
	if (!client) client = 1;
	new gunent = GetPlayerWeaponSlot(client, 0);
	if (IsValidEdict(gunent))
		return GetEntProp(gunent, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 1);
	else return 0;
}

stock SetSpecialAmmoInPlayerGun(client, amount)
{
	if (!client) client = 1;
	if(amount > 255) amount = 255;
	new gunent = GetPlayerWeaponSlot(client, 0);
	if (IsValidEdict(gunent))
		SetEntProp(gunent, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", amount, 1);
}

