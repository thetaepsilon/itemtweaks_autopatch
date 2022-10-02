#!/bin/sh
set -Ceu;
src="$1";
dest="$2";
libdir="$3";

hash jq;

_dopatch() {
	_path="data/minecraft/$1";
	echo "$_path";
	jq --tab "$2" < "$src/$_path" > "$dest/$_path";
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
	_script="$libdir/jq/$2";
	shift 2;
	echo "$_path";
	jq --tab -f "$_script" "$@" < "$src/$_path" > "$dest/$_path";
}

ore_base_drops() {
	do_patch_complex "loot_tables/blocks/$1" "inject_ore_base_count.jq" --argjson min "$2" --argjson max "$3";
}





test -d "$dest/data";
test -d "./data.static";

echo "## cleanup";
(
	cd "$dest/data";

	# stupid globstar handling...
	ls -1 | (IFS='
';
		while read name; do rm -r "$name"; done
	);

	#mkdir -p minecraft/recipes;
);
echo "## static files";
rsync -rvut "./data.static/" "$dest/data/";
echo "## dynamic patches"







colours_count bed 6;

door_types_count trapdoor 24;

wood_types_count stairs 8;
wood_types_count planks 8;
wood_types_count fence 32;
boat_types_count boat 5;





recipe_count stick.json 64;
recipe_count ladder.json 10;
recipe_count crafting_table.json 4;
recipe_count bucket.json 3;
recipe_count barrel.json 7;
recipe_count chest.json 6;

recipe_count furnace.json 8;


for rail in rail activator_rail detector_rail; do recipe_count ${rail}.json 40; done;
# XXX: honestly think this recipe should also have iron to make volumetric sense...
recipe_count powered_rail.json 24;



for tool in shovel hoe axe sword pickaxe; do tool_materials_count "$tool" 2; done;
recipe_count flint_and_steel.json 2;
recipe_count shield.json 2;



button_types_count button 64;
recipe_count piston.json 8;
recipe_count observer.json 8;

recipe_count repeater.json 8;
recipe_count comparator.json 8;
recipe_count redstone_torch.json 4;

recipe_count brewing_stand.json 8;
recipe_count blaze_powder.json 4;



for i in diamond deepslate_diamond iron deepslate_iron; do {
	ore_base_drops ${i}_ore.json 2 3;
}; done;
