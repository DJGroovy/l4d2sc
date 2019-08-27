/*
* ����ļ������� NMRIH �� NetProps ��
* ֻ��һ���ο�����
*/

public FindNetProps()
{
	// ����Ϊ��ҵ�����
	new viewtarget = FindSendPropInfo("CNMRiH_Player", "m_viewtarget");				// �����׼������
	new weapon = FindSendPropInfo("CNMRiH_Player", "m_hActiveWeapon");					// ����ֳֵ�����
	new infection = FindSendPropInfo("CNMRiH_Player", "m_flInfectionDeathTime");		// ����ܸ�Ⱦ��ʣ�������ʱ��
	new infectiont = FindSendPropInfo("CNMRiH_Player", "m_flInfectionTime");			// ��Ҹ�Ⱦ�󾭹���ʱ��
	new life = FindSendPropInfo("CNMRiH_Player", "m_lifeState");						// �������״̬
	new bonus = FindSendPropInfo("CNMRiH_Player", "m_iBonusProgress");					// ��һ�ȡ�������ƵĽ�չ
	new speed = FindSendPropInfo("CNMRiH_Player", "m_flMaxspeed");					// ��ҵ�����ƶ��ٶ�
	new observer = FindSendPropInfo("CNMRiH_Player", "m_hObserverTarget");				// ������ڹ۲��Ŀ��
	new place = FindSendPropInfo("CNMRiH_Player", "m_szLastPlaceName");				// �����󵽴�ĵط� (��������ʾ���������)
	new hud = FindSendPropInfo("CNMRiH_Player", "m_iHideHUD");						// ��ҵ� HUD �Ƿ����� (��ʾ��ҩ�����Ǹ�)
	new duck = FindSendPropInfo("CNMRiH_Player", "m_bDucking");						// ����Ƿ��ڶ���״̬ (�����ڶ��»ָ���)
	new fall = FindSendPropInfo("CNMRiH_Player", "m_flFallVelocity");					// ��ҵĴӸߴ�������ٶ� (�޸Ŀɷ�ֹˤ��)
	new poisoned = FindSendPropInfo("CNMRiH_Player", "m_bPoisoned");					// ����Ƿ��ж� (��ɶ)
	new step = FindSendPropInfo("CNMRiH_Player", "m_flStepSize");						// ��ҵĲ�����С (�����޸��ƶ��ٶ�)
	new last = FindSendPropInfo("CNMRiH_Player", "m_hLastWeapon");					// ��ҵ����һ������
	new ground = FindSendPropInfo("CNMRiH_Player", "m_hGroundEntity");					// ��ҵĵ���ʵ�� (���վ��ʲô������)
	new water = FindSendPropInfo("CNMRiH_Player", "m_nWaterLevel");					// ��ҵı�ˮ�͵ȼ� (�޸Ŀɷ�ֹ����)
	new sequence = FindSendPropInfo("CNMRiH_Player", "m_nSequence");					// ������ڼǷְ�ĵڼ���
	new stamina = FindSendPropInfo("CNMRiH_Player", "m_flStamina");					// ��ҵ�����״̬ (û���������ܲ��ܻӽ�ս������)
	new sprin = FindSendPropInfo("CNMRiH_Player", "m_bIsSprinting");					// ����Ƿ��ڱ��� (���Դ������ܲ�)
	new armor = FindSendPropInfo("CNMRiH_Player", "m_ArmorValue");					// ��ҵĻ���ֵ (���Է���ʬץô��)
	new ragdoll = FindSendPropInfo("CNMRiH_Player", "m_hRagdoll");					// ��ҵĲ�����ʵ�� (��ûɶ�ðɣ�)
	new walk = FindSendPropInfo("CNMRiH_Player", "m_bHasWalkieTalkie");				// ����Ƿ��жԽ���
	new sprint = FindSendPropInfo("CNMRiH_Player", "m_bSprintEnabled");				// ����Ƿ���Ա���
	new Grab = FindSendPropInfo("CNMRiH_Player", "m_bGrabbed");						// ���ץ��Ķ���
	new Token = FindSendPropInfo("CNMRiH_Player", "m_iTokens");						// ��ҵĸ������Ƶ�����
	new suicide = FindSendPropInfo("CNMRiH_Player", "_contemplatingSuicide");			// ����Ƿ������ɱ (��ǹ��׼�Լ�����û�п�ǹ)
	new respawnt = FindSendPropInfo("CNMRiH_Player", "_nextRespawnTime");				// �����һ�θ����ʱ��
	
	// ����������
	new name = FindSendPropInfo("CWeaponSDKBase", "m_iName");						// ����������
	new clip1 = FindSendPropInfo("CWeaponSDKBase", "m_iClip1");						// �����ĵ��� 1
	new clip2 = FindSendPropInfo("CWeaponSDKBase", "m_iClip2");						// �����ĵ��� 2
	new ammotype1 = FindSendPropInfo("CWeaponSDKBase", "m_iPrimaryAmmoType");			// �����ĵ�ҩ���� 1
	new ammotype2 = FindSendPropInfo("CWeaponSDKBase", "m_iSecondaryAmmoType");			// �����ĵ�ҩ���� 1
	
}