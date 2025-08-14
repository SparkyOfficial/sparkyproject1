package __BASE_PACKAGE__

import org.bukkit.plugin.java.JavaPlugin

class __PLUGIN_NAME__ : JavaPlugin() {
	override fun onEnable() {
		logger.info("__PLUGIN_NAME__ enabled!")
		getCommand("__PLUGIN_NAME__")?.setExecutor { sender, _, _, _ ->
			sender.sendMessage("Hello from __PLUGIN_NAME__!")
			true
		}
	}

	override fun onDisable() {
		logger.info("__PLUGIN_NAME__ disabled!")
	}
}


