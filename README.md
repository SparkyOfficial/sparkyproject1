## Minecraft Plugin Starter (Paper/Spigot)

Этот репозиторий содержит генератор шаблонов для Minecraft-плагинов (Paper/Spigot) на Java и Kotlin. Сборка через Maven.

### Что внутри
- `tools/New-PaperPlugin.ps1` — PowerShell-скрипт, который создаёт проект из шаблона.
- `templates/java-paper` — шаблон Maven-проекта для Java.
- `templates/kotlin-paper` — шаблон Maven-проекта для Kotlin.

### Требования
- Windows с PowerShell 7+ (у вас уже есть).
- JDK 17+ (для Paper 1.20+).
- Maven 3.8+.

### Как использовать
1. Откройте PowerShell в корне папки.
2. Запустите скрипт, указав параметры:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\New-PaperPlugin.ps1 -Name MyPlugin -Package com.example.myplugin -Template java -ApiVersion 1.20 -PaperApi 1.20.6-R0.1-SNAPSHOT
```

Параметры:
- `-Name` — имя проекта/плагина (обязательный).
- `-Package` — базовый пакет, например `com.example.myplugin` (по умолчанию `com.example.plugin`).
- `-Template` — `java` или `kotlin` (по умолчанию `java`).
- `-ApiVersion` — `plugin.yml` api-version (по умолчанию `1.20`).
- `-PaperApi` — версия зависимости `paper-api` (по умолчанию `1.20.6-R0.1-SNAPSHOT`).
- `-TargetDir` — куда создать проект (по умолчанию текущая папка).

Скрипт:
- копирует шаблон,
- подставляет значения в файлах (`plugin.yml`, `pom.xml`, исходники),
- переносит исходники в правильный пакет,
- печатает следующие шаги.

### Следующие шаги после генерации
Перейдите в созданную папку проекта и соберите:

```powershell
cd .\MyPlugin
mvn -q -DskipTests package
```

Готовый JAR лежит в `target/`. Для Kotlin-шаблона собирается теневой JAR со встроенной Kotlin stdlib.

### Обновление версий
- `ApiVersion` в `plugin.yml` меняйте под целевую версию сервера.
- `PaperApi` обновляйте при переходе на новую версию Paper.


