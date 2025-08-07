local Logger = {}
Logger.__index = Logger

-- Уровни логирования
Logger.Levels = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	FATAL = 5,
	NONE = 6,
}

-- Стили для разных уровней (используем message templates)
local MessageTemplates = {
	[Logger.Levels.DEBUG] = {
		Prefix = "[DEBUG]",
		Color = Color3.fromRGB(100, 149, 237), -- CornflowerBlue
		Icon = "ℹ️",
	},
	[Logger.Levels.INFO] = {
		Prefix = "[INFO]",
		Color = Color3.fromRGB(50, 205, 50), -- LimeGreen
		Icon = "✅",
	},
	[Logger.Levels.WARN] = {
		Prefix = "[WARN]",
		Color = Color3.fromRGB(255, 215, 0), -- Gold
		Icon = "⚠️",
	},
	[Logger.Levels.ERROR] = {
		Prefix = "[ERROR]",
		Color = Color3.fromRGB(255, 69, 0), -- OrangeRed
		Icon = "❌",
	},
	[Logger.Levels.FATAL] = {
		Prefix = "[FATAL]",
		Color = Color3.fromRGB(255, 0, 0), -- Red
		Icon = "💀",
	},
}

-- Создание нового логгера
function Logger.new(name)
	local self = setmetatable({}, Logger)

	self.name = name or "Logger"
	self.logHistory = {}
	self.maxHistory = 100
	self.minLevel = 0

	return self
end

-- Базовый метод логирования
function Logger:log(level: number, message: string, ...)

	if level < self.minLevel then
		return
	end

	-- Форматирование сообщения
	local formattedMsg = string.format(message, ...)
	local time = os.date("%H:%M:%S", os.time())
	local template = MessageTemplates[level] or MessageTemplates[Logger.Levels.INFO]

	-- Формирование полной записи лога
	local logEntry = string.format("%s [%s] [%s] %s: %s", template.Icon, time, self.name, template.Prefix, formattedMsg)

	-- Вывод в консоль
	if game:GetService("RunService"):IsStudio() then
		-- Специальный вывод для Roblox Studio
		local studioMessage =
			string.format("%s [%s] [%s] %s: %s", template.Icon, time, self.name, template.Prefix, formattedMsg)

		-- Используем разные методы вывода для Studio
		if level >= Logger.Levels.ERROR then
			warn(studioMessage) -- Ошибки выводятся через warn (желтый)
		else
			print(studioMessage)
		end

		-- Для Studio можно добавить выделение цветом через свойства (не всегда работает)
		if level == Logger.Levels.DEBUG then
			print("\\[[DEBUG]\\] " .. formattedMsg)
		end
	else
		-- Простой вывод для клиента
		print(logEntry)
	end

	-- Сохранение в историю
	table.insert(self.logHistory, {
		message = logEntry,
		level = level,
		time = os.time(),
	})

	-- Ограничение размера истории
	if #self.logHistory > self.maxHistory then
		table.remove(self.logHistory, 1)
	end

	return logEntry
end

-- Методы для каждого уровня логирования
function Logger:debug(message, ...)
	return self:log(Logger.Levels.DEBUG, message, ...)
end
function Logger:info(message, ...)
	return self:log(Logger.Levels.INFO, message, ...)
end
function Logger:warn(message, ...)
	return self:log(Logger.Levels.WARN, message, ...)
end
function Logger:error(message, ...)
	return self:log(Logger.Levels.ERROR, message, ...)
end
function Logger:fatal(message, ...)
	return self:log(Logger.Levels.FATAL, message, ...)
end

-- Дополнительные методы
function Logger:getHistory()
	return self.logHistory
end

function Logger:clearHistory()
	self.logHistory = {}
end

export type LoggerType = typeof(Logger)

return Logger
