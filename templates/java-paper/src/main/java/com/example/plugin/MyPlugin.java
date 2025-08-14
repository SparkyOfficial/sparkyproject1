package __BASE_PACKAGE__;

import org.bukkit.plugin.java.JavaPlugin;

	public final class __PLUGIN_NAME__ extends JavaPlugin {
	@Override
	public void onEnable() {
			getLogger().info("__PLUGIN_NAME__ enabled!");
			if (getCommand("__PLUGIN_NAME__") != null) {
				getCommand("__PLUGIN_NAME__").setExecutor((sender, command, label, args) -> {
			sender.sendMessage("Hello from __PLUGIN_NAME__!");
			return true;
				});
			}
	}

	@Override
	public void onDisable() {
		getLogger().info("__PLUGIN_NAME__ disabled!");
	}
}


