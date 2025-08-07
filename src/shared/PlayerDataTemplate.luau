local PlayerDataTemplate = {
	Currency = {
		Pucks = 0,
	},
	Stats = {
		Health = {
			level = 1,
			exp = 0,
			boostTimer = 0,
			boostMultiplier = 1,
		},
		ShootingCooldown = {
			level = 1,
			exp = 0,
			boostTimer = 0,
			boostMultiplier = 1,
		},
		StickCharge = {
			level = 1,
			exp = 0,
			boostTimer = 0,
			boostMultiplier = 1,
		},
	},
	
    Inventory = {
        skins = {
            unlocked = {},
            equipped = "",
        },
        sticks = {
            unlocked = {},
            equipped = "",
        },
        animations = {
            unlocked = {},
            equipped = "",
        },
        trails = {
            unlocked = {},
            equipped = "",
        }
    },

	Tutorial = false,
	Club = "",

	DailyReward = {
		day = 1,
		lastClaimed = 0,
	},

	Badges = {} :: { string },
}

export type PlayerDataTemplateType = typeof(PlayerDataTemplate)

return PlayerDataTemplate