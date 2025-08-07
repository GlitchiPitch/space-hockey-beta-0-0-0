local Settings = {
    minPlayers = 2, -- для старта игры
    maxPlayers = 5, -- для команды

    UI = {
        gameResultDelay = 15, -- задержка перед показом личного результата
        closeFinalDelay = 15, -- задержка перед закрытием финального окна
    },

    -- штраф за выход из игры, (такое слово реально есть)
    mulct = {
        pucks = 100,
        rating = 100,
    },

    roundTimer = 120,
    roundCount = 2,
    intermissionTimer = 3,
    timeOutTimer = 5,
    dropGameTimer = 5,
}

return Settings