#!/usr/bin/env bash

set -euo pipefail

## Convert my Obsidian Vault to org-mode.
## Dependencies:
##   unzip
##   wget
##   pandoc
##   fd

# Expects to exist in the same folder that contains "Austin's Obsidian Vault-20220506T153643Z-001.zip"
VAULT_ZIP="Austin's Obsidian Vault.zip"
OBS="AustinObsidian"
MD="AustinMd"
ORG="AustinOrg"

rm -rf "$OBS" "$MD" "$ORG"
# https://stackoverflow.com/a/11114547
SCRIPT=`realpath "$0"`
SCRIPTPATH=`dirname "$SCRIPT"`

cd "$SCRIPTPATH"

unzip "$VAULT_ZIP"
mv "Austin's Obsidian Vault" "$OBS"

fd __MACOSX . | xargs rm -rf

# Usage: ./obsidian-export_Linux-x86_64.bin [OPTIONS]
#
# Positional arguments:
#   source                     Read notes from this source
#   destination                Write notes to this destination
#
# Optional arguments:
#   -h, --help                 Display program help
#   -v, --version              Display version information
#   --start-at START-AT        Only export notes under this sub-path
#   --frontmatter FRONTMATTER-STRATEGY
#                              Frontmatter strategy (one of: always, never, auto) (default: auto)
#   --ignore-file IGNORE-FILE  Read ignore patterns from files with this name (default: .export-ignore)
#   --hidden                   Export hidden files (default: false)
#   --no-git                   Disable git integration (default: false)
#   --no-recursive-embeds      Don't process embeds recursively (default: false)
#   --hard-linebreaks          Convert soft line breaks to hard line breaks. This mimics Obsidian's 'Strict line breaks' setting (default: false)
BIN=./obsidian-export/result/bin/obsidian-export
BIN_ARGS="--"

#chmod +x $BIN

mkdir -p "$MD"
$BIN --no-recursive-embeds --hard-linebreaks "$OBS" "$MD"

fd -e md . ./AustinMd | while read file
do
    # remove the directory prefix for the markdown file,
    # replace it with the org directory suffix
    orgfile="$ORG/"${file#$MD\/}
    # remove the extension suffix for the markdown file,
    # replace it with the org file suffix
    orgfile=${orgfile%md}"org"
    orgdir=`dirname "$orgfile"`
    mkdir -p "$orgdir"
    pandoc "$file" -o "$orgfile"
done

# Find and replace "%20", which should be " ", and ".md", which should be ".org"
fd -e "org" . ./AustinOrg --exec sed -i -e "s/%20/ /g; s/\.md/.org/g" '{}'

mv "$ORG/Obsidian Nexus.org" $ORG/Nexus.org
