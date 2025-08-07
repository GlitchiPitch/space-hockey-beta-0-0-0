local Config = {
	shootingCooldownLevels = { 3, 2.5, 1.4, 1.2, 1, 2.1, 2 },
    stickChargeLevels = { 100, 120, 140, 160, 180, 200, 220 },
    roundRewards = {
        winner = {
            [1] = { pucks = 100, rating = 80 },
            [2] = { pucks = 80, rating = 64 },
            [3] = { pucks = 50, rating = 48 },
            ["overrated"] = { pucks = 30, rating = 32 },
        },
        loosers = {
            [1] = { pucks = 60, rating = -33 },
            [2] = { pucks = 40, rating = -49 },
            [3] = { pucks = 20, rating = -65 },
            ["overrated"] = { pucks = 10, rating = -81 },
        },
    }
}

return Config
