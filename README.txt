CELL QR — приложение для iPhone (PWA)

СОДЕРЖИМОЕ: index.html, qr-engine.js, manifest.webmanifest, sw.js, значки.

ПУБЛИКАЦИЯ С IPHONE (через GitHub):
1. Создайте репозиторий на github.com, например cellqr.
2. В интерфейсе репозитория используйте Add file → Upload files. Загрузите ВСЕ файлы из этой папки В КОРЕНЬ репозитория (не сам ZIP).
3. Settings → Pages → Deploy from a branch → main / (root) → Save.
4. Откройте появившийся адрес https://USERNAME.github.io/cellqr/ в Safari.
5. Поделиться → На экран «Домой» → Добавить.

ВАЖНО: без публикации на HTTPS iOS не сможет установить PWA и кешировать офлайн. На сервере нужно отдавать файлы по HTTPS.

QR содержит точно набранную строку, например ANO-CON199, K09-12B5, K10-11A5.
