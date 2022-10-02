

# the stock ores of interest contain a single pool, which has a single entry.
# this single entry is an alternatives where one of the children refers to silk touch.
# we only want to operate on that.
def contains_silktouch(x): x | [.. | select(.enchantment? == "minecraft:silk_touch")] | length | . > 0;
def is_silktouch_alternative_single_entry(x): ((x | length) == 1) and (x[0].type == "minecraft:alternatives") and contains_silktouch(x[0]);

# the actual modifier function we want to patch in
def set_count(min; max): {
	"add": false,
	"function": "minecraft:set_count",
	"count": {
		"type": "minecraft:uniform",
		"min": min,
		"max": max
	}
};

# guard against existing set_count as a base - I'm not sure if dupes of this would cause a game error
def cleanse: map(select(.function != "minecraft:set_count"));
def inject_set_count: .functions = [set_count($min; $max)] + (.functions | cleanse);

def only_patch_non_silktouch: if (contains_silktouch(.) | not) then inject_set_count else . end;

def patch_alt_entry(x): x | (.children = (.children | map(only_patch_non_silktouch)));

def fixpool: if is_silktouch_alternative_single_entry(.entries) then (.entries[0] = patch_alt_entry(.entries[0])) else . end;


.pools = (.pools | map(fixpool))
