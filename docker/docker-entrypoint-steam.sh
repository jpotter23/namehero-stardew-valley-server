#!/bin/bash
#export HOME=/config

for modPath in /home/container/Stardew/game/Mods/*/
do
  mod=$(basename "$modPath")

  # Normalize mod name ot uppercase and only characters, eg. "Always On Server" => ENABLE_ALWAYSONSERVER_MOD
  var="ENABLE_$(echo "${mod^^}" | tr -cd '[A-Z]')_MOD"

  # Remove the mod if it's not enabled
  if [ "${!var}" != "true" ]; then
    echo "Removing ${modPath} (${var}=${!var})"
    rm -rf "$modPath"
    continue
  fi

  if [ -f "${modPath}/config.json.template" ]; then
    echo "Configuring ${modPath}config.json"

    # Seed the config.json only if one isn't manually mounted in (or is empty)
    if [ "$(cat "${modPath}config.json" 2> /dev/null)" == "" ]; then
      envsubst < "${modPath}config.json.template" > "${modPath}config.json"
    fi
  fi
done

# Run extra steps for certain mods
/home/container/Stardew/scripts/configure-remotecontrol-mod.sh
/home/container/Stardew/scripts/tail-smapi-log.sh &

# Ready to start!
export XAUTHORITY=~/.Xauthority
bash -c "/home/container/Stardew/start.sh"

sleep 233333333333333