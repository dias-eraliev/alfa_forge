# Раздача Flutter Web билда через Backend

Этот бэкенд (NestJS) настроен на раздачу статического Flutter Web билда из папки `build/web` в корне репозитория.

## Как собрать и раздать веб

1. Соберите web-билд Flutter в корне проекта:

```powershell
flutter build web
```

После сборки файлы появятся в `./build/web`.

2. Запустите backend из папки `backend`:

```powershell
pnpm install
pnpm run start:dev
```

3. Откройте в браузере:
- Приложение SPA: http://localhost:3000/
- Swagger Docs: http://localhost:3000/api/docs

Бэкенд отдаёт index.html для всех путей, кроме начинающихся с `/api`.

> Подсказка: при деплое убедитесь, что процесс имеет доступ к `./build/web`.
