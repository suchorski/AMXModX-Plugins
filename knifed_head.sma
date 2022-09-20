#include <amxmodx>
#include <cstrike>
#include <engine>
#include <fakemeta>

#define PLUGIN "Knifed Head"
#define VERSION "1.0"
#define AUTHOR "Suchorski"

new models[2][64] = { "models/merlin.mdl", "models/cowhead.mdl" };

new knifed[33][2];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_event("DeathMsg", "knifeKill", "a", "4=knife");
}

public plugin_precache() {
	for (new i = 0; i < 2; ++i) {
		precache_model(models[i]);
	}
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/gign/gign.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/gsg9/gsg9.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/sas/sas.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/urban/urban.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/vip/vip.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/arctic/arctic.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/guerilla/guerilla.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/leet/leet.mdl");
	force_unmodified(force_model_samebounds, {0, 0, 0}, {0, 0, 0}, "models/player/terror/terror.mdl");
}

public client_connect(id) {
	if (knifed[id][1] > 0) {
		remove_entity(knifed[id][1]);
	}
	knifed[id][1] = 0;
	knifed[id][0] = 0;
}

public client_disconnect(id) {
	if (knifed[id][1] > 0) {
		remove_entity(knifed[id][1]);
	}
	knifed[id][1] = 0;
	knifed[id][0] = 0;
}

public client_PreThink(id) {
	
	if (!is_user_connected(id)) {
		return PLUGIN_CONTINUE;
	}
	
	if (!is_user_alive(id) && knifed[id][1] > 0) {
		remove_entity(knifed[id][1]);
		knifed[id][1] = 0;
		return PLUGIN_CONTINUE;
	}
	
	if (!is_user_alive(id)) {
		return PLUGIN_CONTINUE;
	}
	
	if (knifed[id][1] < 1 && knifed[id][0] > 0) {
		knifed[id][1] = create_entity("info_target");
		if(knifed[id][1] > 0) {
			entity_set_int(knifed[id][1], EV_INT_movetype, MOVETYPE_FOLLOW);
			entity_set_edict(knifed[id][1], EV_ENT_aiment, id);
			entity_set_model(knifed[id][1], models[min(max(knifed[id][0] - 1, 0), 1)]);
		}
	}
	
	if (knifed[id][1] > 0 && knifed[id][0] > 0) {
		new modelID = get_model_id(id);
		entity_set_int(knifed[id][1], EV_INT_body, modelID);
	}
	
	if (knifed[id][1] < 1) {
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_CONTINUE
}

new modelname[9][] = {
	"gign",
	"gsg9",
	"sas",
	"urban",
	"vip",
	"arctic",
	"guerilla",
	"leet",
	"terror"
}

public get_model_id(id) {
	new modelStr[32], iNum=32, modelID;
	get_user_info(id, "model", modelStr, iNum);
	for (new i = 0; i < 9; i++) {
		if (equali(modelStr, modelname[i])) {
			modelID = i;
		}
	}	
	return modelID;
}

public knifeKill() {
	new iKiller = read_data(1), iVictim = read_data(2), isKnifed = knifed[iKiller][0];
	if (isKnifed == 1) {
		knifed[iKiller][0] = 0;
	}
	++knifed[iVictim][0];
}
