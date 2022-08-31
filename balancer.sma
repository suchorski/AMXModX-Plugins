#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN "Balancer"
#define VERSION "1.0"
#define AUTHOR "Suchorski"

new amxBalancer;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	amxBalancer = register_cvar("amx_balancer","1");
	RegisterHam(Ham_TakeDamage, "player", "takeDamage");
}

public takeDamage(victim, inflictor, attacker, Float:damage, damagebits) {
	if (get_pcvar_num(amxBalancer) == 1) {
		new aFrags = get_user_frags(attacker);
		new aDeaths = get_user_deaths(attacker);
		new vFrags = get_user_frags(victim);
		new vDeaths = get_user_deaths(victim);
		new bonus = (aDeaths - aFrags) + (vFrags - vDeaths);
		if (bonus != 0) {
			console_print(attacker, "damage %s of %d percent, de %.0f para %.0f", (bonus < 0 ? "decreased" : "increased"), bonus, damage, damage * (1.0 + bonus / 100.0));
			console_print(victim, "damage %s of %d percent, de %.0f para %.0f", (bonus < 0 ? "decreased" : "increased"), bonus, damage, damage * (1.0 + bonus / 100.0));
			damage *= 1.0 + bonus / 100.0;
		}
		SetHamParamFloat(4, damage);
	}
	return HAM_HANDLED;
}
