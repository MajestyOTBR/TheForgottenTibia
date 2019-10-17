local condition = Condition(CONDITION_OUTFIT)
condition:setTicks(120000)
condition:setOutfit({lookType = 111})

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local playerId = player.uid
	if item.actionid == 25300 then
		player:addCondition(condition)

		player:setStorageValue(SvargrondArena.Storages.Pit, 0)
		player:teleportTo(SvargrondArena.kickPosition)
		player:say('Coward!', TALKTYPE_MONSTER_SAY)
		SvargrondArena.cancelEvents(playerId)
		return true
	end

	local pitId = player:getStorageValue(SvargrondArena.Storages.Pit)
	local arenaId = player:getStorageValue(SvargrondArena.Storages.Arena)
	if pitId > 10 then
		player:teleportTo(SvargrondArena.rewardPosition)
		player:setStorageValue(SvargrondArena.Storages.Pit, 0)

		if arenaId == 1 then
			SvargrondArena.rewardPosition:sendMagicEffect(CONST_ME_FIREWORK_BLUE)
			player:setStorageValue(SvargrondArena.Storages.Greenhorn, 1)
			player:say('Welcome back, little hero!', TALKTYPE_MONSTER_SAY)
		elseif arenaId == 2 then
			SvargrondArena.rewardPosition:sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
			player:setStorageValue(SvargrondArena.Storages.Scrapper, 1)
			player:say('Congratulations, brave warrior!', TALKTYPE_MONSTER_SAY)
		elseif arenaId == 3 then
			SvargrondArena.rewardPosition:sendMagicEffect(CONST_ME_FIREWORK_RED)
			player:setStorageValue(SvargrondArena.Storages.Warlord, 1)
			player:say('Respect and honour to you, champion!', TALKTYPE_MONSTER_SAY)
		end

		player:setStorageValue(SvargrondArena.Storages.Arena, player:getStorageValue(SvargrondArena.Storages.Arena) + 1)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, 'Congratulations! You completed ' .. ARENA[arenaId].name .. ' arena, you should take your reward now.')
		player:setStorageValue(ARENA[arenaId].questLog, 2)
		player:addAchievement(ARENA[arenaId].achievement)
		SvargrondArena.cancelEvents(playerId)
		return true
	end

	local occupant = SvargrondArena.getPitOccupant(pitId, player)
	if occupant then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, occupant:getName() .. ' is currently in the next arena pit. Please wait until ' .. (occupant:getSex() == PLAYERSEX_FEMALE and 's' or '') .. 'he is done fighting.')
		player:teleportTo(fromPosition, true)
		return true
	end

	SvargrondArena.cancelEvents(playerId)
	SvargrondArena.resetPit(pitId)
	SvargrondArena.scheduleKickPlayer(playerId, pitId)
	Game.createMonster(ARENA[arenaId].creatures[pitId], PITS[pitId].summon, false, true)

	player:teleportTo(PITS[pitId].center)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:say('Fight!', TALKTYPE_MONSTER_SAY)
	return true
end