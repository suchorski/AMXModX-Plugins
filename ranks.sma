#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <sorting>
#include <fakemeta>

#define PLUGIN "Patentes da Aeronautica"
#define VERSION "2.0"
#define AUTHOR "Suchorski"

#define write_coord_f(%1) engfunc(EngFunc_WriteCoord, %1)

#define POINTS_ATTACKER 3
#define BONUS_HS 2
#define BONUS_KNIFE 10
#define BONUS_GENERAL_LINE 3
#define BONUS_GENERAL_KILL 5
#define MAX_TB 1
#define MAX_MB 1
#define MAX_BR 1
#define VAULT_NAME "PATENTES"
#define POISON_SPRITE "sprites/skull.spr"

new rankPoints[] 		= {  1000, 900,  800,  500,   450, 400,  350,  300,  250,   150,  100,  50,   25,   10,    1,    0 };
new rankAbbreviations[][3] 	= { "TB", "MB", "BR", "CL", "TC", "MJ", "CP", "1T", "2T", "SO", "1S", "2S", "3S", "CB", "S1", "S2" };
new rankNames[][64]		= {
	"Tenente Brigadeiro", 	"Major Brigadeiro", 	"Brigadeiro",			"Coronel",
	"Tenente Coronel", 	"Major", 		"Capitao", 			"Primeiro Tenente",
	"Segundo Tenente", 	"Suboficial", 		"Primeiro Sargento", 		"Segundo Sargento",
	"Terceiro Sargento", 	"Cabo", 		"Soldado de Primeira Classe", 	"Soldado de Segunda Classe"
};

new vault, poisonSprite;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	vault = nvault_open(VAULT_NAME);
	if (vault == INVALID_HANDLE) {
		set_fail_state("Unable to load vault");
	} else {
		register_clcmd("amx_ranking_set", "set", ADMIN_LEVEL_A, "<target> <points>");
		register_clcmd("amx_ranking_del", "del", ADMIN_LEVEL_A, "<target>");
		register_clcmd("say /patente", "get", -1, "<target>");
		register_event("DeathMsg", "handleKill", "a");
		set_task(0.5, "updateHud", 0, "", 0, "b");
	}
}

public plugin_precache() {
	poisonSprite = precache_model(POISON_SPRITE);
}

public handleKill() {
	new attacker = read_data(1), victim = read_data(2), hs = read_data(3), inflictor[33], playerName[64], points, save[16];
	if (!is_user_connected(attacker) || attacker == victim) {
		get_user_name(victim, playerName, 63);
		points = nvault_get(vault, playerName);
		points = max(0, points - 20);
		num_to_str(points, save, 15);
		nvault_set(vault, playerName, save);
	} else {
		new status[32][3], playersCount = genStatus(status), aStatusIndex, vStatusIndex;
		read_data(4, inflictor, 32);
		aStatusIndex = getPlayerStatusIndex(status, playersCount, attacker);
		vStatusIndex = getPlayerStatusIndex(status, playersCount, victim);
		points = status[aStatusIndex][1];
		points += POINTS_ATTACKER;
		if (hs) {
			points += BONUS_HS;
		}
		if (status[vStatusIndex][2] < BONUS_GENERAL_LINE && status[aStatusIndex][2] >= BONUS_GENERAL_LINE) {
			poisonEffect(victim);
			points += BONUS_GENERAL_KILL;
		}
		if (!strcmp("knife", inflictor)) {
			points += BONUS_KNIFE;
		}
		num_to_str(points, save, 15);
		get_user_name(attacker, playerName, 63);
		nvault_set(vault, playerName, save);
		get_user_name(victim, playerName, 63);
		points = status[vStatusIndex][1];
		points = max(rankPoints[getRankIndex(points)], points - 1);
		num_to_str(points, save, 15);
		nvault_set(vault, playerName, save);
	}
}

public updateHud() {
	new status[32][3], playersCount = genStatus(status), list[1501], playerName[64];
	genRank(status, playersCount, list);
	for (new i = 0; i < playersCount; ++i) {
		new information[1701];
		get_user_name(status[i][0], playerName, 63);
		information[0] = '^0';
		format(information, 1700, "%s %s [Pontos: %s]^n^n", rankNames[status[i][2]], playerName, getNextPointsText(status[i][1]));
		strcat(information, list, 1700);
		new hud = CreateHudSyncObj();
		set_hudmessage(200, 100, 0, 0.01, 0.15, 0, 1.0, 1.0, 0.1, 0.2, 1);
		ShowSyncHudMsg(status[i][0], hud, information);
	}
}

public sorter(left[3], right[3]) {
	return min(max(right[1] - left[1], -1), 1)
}

public get(id, level, cid) {
	if (!cmd_access(id, level, cid, 3)) {
		return PLUGIN_HANDLED;
	}
	new playerName[64], points;
	read_argv(2, playerName, 63);
	points = nvault_get(vault, playerName);
	console_print(id, "%s %s tem %d pontos.", getRankName(points), playerName, points);
	client_print(id, print_chat, "%s %s tem %d pontos.", getRankName(points), playerName, points);
	return PLUGIN_HANDLED;
}

public set(id, level, cid) {
	if (!cmd_access(id, level, cid, 3)) {
		return PLUGIN_HANDLED;
	}
	new playerName[64], points[16];
	read_argv(1, playerName, 63);
	read_argv(2, points, 15);
	nvault_set(vault, playerName, points);
	console_print(id, "Defined.");
	return PLUGIN_HANDLED;
}

public del(id, level, cid) {
	if (!cmd_access(id, level, cid, 2)) {
		return PLUGIN_HANDLED;
	}
	new playerName[64];
	read_argv(1, playerName, 63);
	nvault_remove(vault, playerName);
	console_print(id, "Cleared.");
	return PLUGIN_HANDLED;
}

getPlayerStatusIndex(status[32][3], playersCount, playerId) {
	for (new i = 0; i < playersCount; ++i) {
		if (status[i][0] == playerId) {
			return i;
		}
	}
	return -1;
}

getRankIndex(points) {
	for (new i = 0; i < sizeof(rankPoints); ++i) {
		if (points >= rankPoints[i]) {
			return i;
		}
	}
	return sizeof(rankPoints) - 1;
}

getRankName(points) {
	for (new i = 0; i < sizeof(rankPoints); ++i) {
		if (points >= rankPoints[i]) {
			return rankNames[i];
		}
	}
	return rankNames[sizeof(rankPoints) - 1];
}

getNextPointsText(points) {
	new index = getRankIndex(points), text[64];
	if (index > 0) {
		format(text, 63, "%d/%d", points, rankPoints[index - 1]);
		} else {
		format(text, 63, "%d", points);
	}
	return text;
}

genStatus(status[32][3]) {
	new players[32], playersCount, playerName[64];
	new points, tbCount = MAX_TB, mbCount = MAX_MB, brCount = MAX_BR;
	get_players(players, playersCount);
	for (new i = 0; i < playersCount; ++i) {
		status[i][0] = players[i];
		get_user_name(players[i], playerName, 63);
		points = nvault_get(vault, playerName);
		status[i][1] = points;
		status[i][2] = getRankIndex(points);
	}
	SortCustom2D(status, playersCount, "sorter");
	for (new i = 0; i < playersCount; ++i) {
		if (status[i][2] == 0 && tbCount-- <= 0) {
			status[i][2] = 1;
		}
		if (status[i][2] == 1 && mbCount-- <= 0) {
			status[i][2] = 2;
		}
		if (status[i][2] == 2 && brCount-- <= 0) {
			status[i][2] = 3;
		}
	}
	return playersCount;
}

genRank(status[32][3], playersCount, message[1501]) {
	new name[33], append[101];
	message[0] = '^0';
	strcat(message, "ANTIGUIDADE^n", 1500);
	for (new i = 0; i < playersCount; ++i) {
		get_user_name(status[i][0], name, 32);
		format(append, 100, "^t^t%s %s^t^t^t[%d]^n", rankAbbreviations[status[i][2]], name, status[i][1]);
		strcat(message, append, 1500);
	}
	return message;
}

poisonEffect(playerId) {
	new Float:fOrigin[3];
	pev(playerId, pev_origin, fOrigin);
	fOrigin[2] += 35.0;
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPRITE);
	write_coord_f(fOrigin[0]);
	write_coord_f(fOrigin[1]);
	write_coord_f(fOrigin[2]);
	write_short(poisonSprite);
	write_byte(10);
	write_byte(255);
	message_end();
}
