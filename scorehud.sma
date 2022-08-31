#include <amxmodx>
#include <amxmisc>
#include <sorting>

#define PLUGIN "Score HUD"
#define VERSION "1.0"
#define AUTHOR "Suchorski"

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	set_task(0.5, "updateHud", 10, "", 0, "b");
}

public updateHud() {
	new players[32], playersCount, status[32][4], message[1501];
	get_players(players, playersCount);
	for (new i = 0; i < playersCount; ++i) {
		status[i][0] = players[i];
		status[i][1] = get_user_frags(players[i]);
		status[i][2] = get_user_deaths(players[i]);
		status[i][3] = get_user_team(players[i]);
	}
	SortCustom2D(status, playersCount, "sorter");
	new hud = CreateHudSyncObj();
	set_hudmessage(250, 250, 250, 0.8, 0.15, 0, 1.0, 1.0, 0.1, 0.2, 3);
	genScoreboard(status, playersCount, message);
	ShowSyncHudMsg(0, hud, message);
}

public mm(num) {
	return min(max(num, -1), 1);
}

public sorter(left[3], right[3]) {
	new positive = mm((right[1] - right[2]) - (left[1] - left[2]));
	if (positive != 0) {
		return positive;
	}
	new frags = mm(right[1] - left[1]);
	if (frags != 0) {
		return frags;
	}
	return mm(left[2] - right[2]);
}

public genScoreboard(status[32][4], playersCount, message[1501]) {
	new name[33], append[101];
	message[0] = '^0';
	strcat(message, "RANKING DO MAPA^n", 1500);
	for (new i = 0; i < playersCount; ++i) {
		if (status[i][3] == 1 || status[i][3] == 2) {
			get_user_name(status[i][0], name, 32);
			format(append, 100, "%s^t^t^t[%s]^n", name, (status[i][3] == 1 ? "TR" : "CT"));
			strcat(message, append, 1500);
		}
	}
	return message;
}
