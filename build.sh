#!/bin/sh
set -Ceu;
src="$1";
dest="$2";
datadir="$3";

patchdata="$datadir/_patchdata";
lib="$datadir/_lib";

hash jq;

tmp="$(mktemp -d)";
cleanup() {
	rm -r "$tmp";
}
trap cleanup EXIT;




do_jq() {
	jq --tab --sort-keys "$@";
}

_dopatch() {
	_path="data/minecraft/$1";
	echo "$_path";
	do_jq "$2" < "$src/$_path" > "$dest/$_path";
}

recipe_count() {
	_dopatch "recipes/$1" ".result.count = $2";
}

colours() {
	for c in black blue brown cyan gray green light_blue light_gray lime magenta orange pink purple red white yellow; do {

		"$@" "$c";

	}; done;
}

wood_types() {
        for w in acacia birch crimson dark_oak jungle mangrove oak spruce warped; do {

                "$@" "$w";

        }; done;
}

boat_types() {
        for w in acacia birch dark_oak jungle mangrove oak spruce; do {

		"$@" "$w";

	}; done;

}

door_types() {
	wood_types "$@";
	"$@" "iron";
}

# NB: netherite tools are upgraded, not crafted.
tool_materials() {
	for material in wooden stone iron golden diamond; do {
		"$@" "$material";
	}; done;
}

button_types() {
	wood_types "$@";
	"$@" stone;
	"$@" polished_blackstone;
}



_prefix_count() {
	recipe_count "${3}_${1}.json" "$2";
}
colours_count() {
	colours _prefix_count "$1" "$2";
}

wood_types_count() {
	wood_types _prefix_count "$1" "$2";
}

boat_types_count() {
	boat_types _prefix_count "$1" "$2";
}

door_types_count() {
	door_types _prefix_count "$1" "$2";
}

tool_materials_count() {
	tool_materials _prefix_count "$1" "$2";
}

button_types_count() {
	button_types _prefix_count "$1" "$2";
}



do_patch_complex() {
	_path="data/minecraft/$1";
	_script="$lib/jq/$2";
	shift 2;
	echo "$_path";
	do_jq -f "$_script" "$@" < "$src/$_path" > "$dest/$_path";
}

do_patch_addon_slurp() {
	_path="data/minecraft/$1";
	_script="$lib/jq/$2";
	shift 2;

	echo "$_path";

	"$@" > "$tmp/__addon_slurp.stage1";
	cat "$src/$_path" "$tmp/__addon_slurp.stage1" > "$tmp/__addon_slurp";

	do_jq -s -f "$_script" < "$tmp/__addon_slurp" > "$dest/$_path";

	(cd "$tmp"; rm __addon_slurp*);
}

ore_base_drops() {
	do_patch_complex "loot_tables/blocks/$1" "inject_ore_base_count.jq" --argjson min "$2" --argjson max "$3";
}




echo "## cleanup";
rm -r "$dest/data";

echo "## static files";
rsync -rvut "$datadir/data.static/data" "$dest/";
echo "## dynamic patches"







colours_count bed 6;

door_types_count trapdoor 24;

wood_types_count stairs 8;
wood_types_count planks 8;
wood_types_count fence 32;
wood_types_count sign 16;
wood_types_count fence_gate 16;
boat_types_count boat 5;





recipe_count stick.json 64;
recipe_count ladder.json 10;
recipe_count crafting_table.json 4;
recipe_count bucket.json 3;
recipe_count barrel.json 7;
recipe_count chest.json 6;
recipe_count composter.json 6;
recipe_count beehive.json 8;

recipe_count furnace.json 8;
recipe_count blast_furnace.json 4;


for rail in rail activator_rail detector_rail; do recipe_count ${rail}.json 40; done;
# XXX: honestly think this recipe should also have iron to make volumetric sense...
recipe_count powered_rail.json 24;





button_types_count button 64;
button_types_count pressure_plate 16;
for w in light heavy; do recipe_count ${w}_weighted_pressure_plate.json 2; done;

recipe_count piston.json 8;
recipe_count observer.json 8;
recipe_count repeater.json 8;
recipe_count comparator.json 8;
recipe_count redstone_torch.json 4;
recipe_count dispenser.json 8;
recipe_count dropper.json 8;
recipe_count hopper.json 4;
recipe_count note_block.json 8;
recipe_count daylight_detector.json 8;

# iron is the limiting factor for the loop in the tripwire hooks
recipe_count tripwire_hook.json 12;



recipe_count tnt.json 4;
recipe_count lightning_rod.json 8;



recipe_count brewing_stand.json 8;
recipe_count blaze_powder.json 4;



for i in diamond deepslate_diamond iron deepslate_iron; do {
	ore_base_drops ${i}_ore.json 2 4;
}; done;



### patching based on files follows

(cd "$patchdata/entity_loot"; ls -1) > "$tmp/entity_loot.lst";

(IFS='
';

	while read filename; do {
		do_patch_addon_slurp \
			"loot_tables/entities/$filename" \
			"simple_entity_uniform_count_and_looting_patch.jq" \
			cat "$patchdata/entity_loot/$filename";
	}; done;

) < "$tmp/entity_loot.lst";







recipe_count glass_bottle.json 24;
