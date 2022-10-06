
def bail(x): x | . + "\n" | halt_error(10);

def apply_count(db):
#	bail(tostring + "\n" + (db | tostring))
	if (db.min) then (.count.min = db.min) else . end |
	if (db.max) then (.count.max = db.max) else . end
;

def patch_function(db):
	if .function == "minecraft:set_count" then
		apply_count(db.base)
	else
		if .function == "minecraft:looting_enchant" then
			apply_count(db.per_looting_lvl)
		else
			.
		end
	end
;

# XXX: do we want to implement injecting set_count if it's not the first entry?
def maybe_patch_functions(db_entry):
	if (db_entry | not) then
		.
	else
		map(patch_function(db_entry))
	end
;

def patch_functions(db_entry):
	.functions = (.functions | maybe_patch_functions(db_entry));

# we cannot apply if the entry is not a top-level minecraft:item.
# we currently don't have recursive descent implemented for complex entries.
def lookup_and_apply_entry(db):
#	bail(tostring)
	if (.type == "minecraft:item") then
		((db[.name]?) as $dbe | patch_functions($dbe))
	else
		.
	end
;	

# we only expect each pool to have a sole entry for now.
def mod_entries(db):
	if (length != 1) then
		bail("expected pool to have single entry, got " + (length | tostring) + ": " + tostring)
	else
		[ (.[0] | lookup_and_apply_entry(db)) ]
	end
;

def lookup_and_apply_pool(db): .entries = (.entries | mod_entries(db));

def process(db):
	if ((.pools | length) < 1) then 
		bail("pools empty")
	else
		(.pools = (.pools | map(lookup_and_apply_pool(db))))
	end
;



def main(db):
	if (.type == "minecraft:entity") then
		(. | process(db))
	else
		bail("incorrect type")
	end
;



# use with jq -s, concat original data with patch
.[1] as $db | (.[0] | main($db))

