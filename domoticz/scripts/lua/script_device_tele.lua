#!/usr/bin/lua
commandArray = {}

-- Package complémentaires
package.path = package.path..";/src/domoticz/scripts/lua/modules/?.lua"
require 'livebox_tele'
require 'utils'

--
-- Fonction Commande de la télévision pour afficher une chaine sur CanalSat
-- la fonction callCommandeTV est définie dans livebox_tele.lua
-- @param ip_livebox_tv : code de la télécommande
-- @param channel_tv : Chaine à lancer
function commandeTeleCanalSat(channel_tv)

	-- Démarrage / ON
	if not getStatutTV() then
		logTV("Démarrage de la Livebox TV sur la chaine " .. channel_tv)
		callCommandeTV("116", false)
		pause(5)
		-- (Son -) callCommandeTV("114", true)
		-- CanalSat	normalement déjà configurée
		-- TODO : A tester à partir du statut
		-- Découpage de la chaine en chiffre
		size=string.len(channel_tv)
		for i=1,size,1 
		do
			touche=string.sub(channel_tv, i, i)
			callCommandeTV(512 + touche, false)
		end
		-- Son à +1 callCommandeTV("115", true)
	else
		logTV("La télévision est déjà allumée")
	end
end



-- Fonction principale
--   Action ssi l'état de Livebox Player est à On
--
if ( devicechanged[DEVICE_BOX] == 'On' ) then
	logTV("Démarrage de la télévision")
	-- Test de la variable
	channel_tv = uservariables["channel_tv"]
	if( channel_tv == nil ) then
		error("[ERREUR] La variable {channel_tv} n'est pas définie dans Domoticz")
		return 512
	else
		-- Lancement de la commande télé dans une coroutine
		co = coroutine.create(function ()
			commandeTeleCanalSat(channel_tv)
			end
		)
		coroutine.resume(co)
	end	
elseif ( devicechanged[DEVICE_BOX] == 'Off' ) then
	
	if getStatutTV() then
		logTV("Arrêt de la télévision")
		-- Lancement de la commande télé dans une coroutine
		co = coroutine.create(function ()
			callCommandeTV("116", false)
			end
		)
		coroutine.resume(co)
	else
		logTV("La télévision est déjà éteinte")
	end
end 
return commandArray