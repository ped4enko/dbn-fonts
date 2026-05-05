# fonts.dbn.co.ua — структура проекту для Cloudflare Pages

Статичний сайт, який роздає українські шрифти через Cloudflare CDN.

## Структура

```
fonts-cdn/
├── _headers              ← CORS + cache-control (обов'язково)
├── index.html            ← каталог-вітрина для відвідувачів
├── fonts.json            ← метадані всіх шрифтів (редагуй тут)
├── fonts/                ← .woff2 / .woff файли по підпапках
│   └── example-font/
│       ├── ExampleFont-Regular.woff2
│       └── ExampleFont-Regular.woff
├── css/                  ← готові @font-face файли (по одному на шрифт)
│   └── example-font.css
└── tools/
    └── convert-fonts.sh  ← TTF/OTF → WOFF2 + WOFF
```

## Як додати новий шрифт

1. **Підготуй файли.** Якщо в тебе тільки TTF/OTF, прожени через `tools/convert-fonts.sh`:

   ```bash
   pip install fonttools brotli zopfli
   mkdir -p fonts/назва-шрифту
   cp ~/завантаження/MyFont-*.ttf fonts/назва-шрифту/
   ./tools/convert-fonts.sh fonts/назва-шрифту/
   rm fonts/назва-шрифту/*.ttf  # WOFF2 і WOFF тепер поруч; TTF більше не потрібен
   ```

2. **Створи CSS-файл** `css/назва-шрифту.css` за зразком `css/example-font.css`. Шляхи мають вказувати на `https://fonts.dbn.co.ua/fonts/...` — це абсолютні URL, щоб працювало при підключенні з будь-якого сайту.

3. **Додай запис у `fonts.json`** — повтори структуру `example-font` для нового шрифту.

4. Закомить і запушь — Cloudflare Pages задеплоїть автоматично за 30 секунд.

## Деплой

### Варіант 1 — через GitHub (рекомендований)

1. Створи репо, запушь цю папку.
2. Cloudflare → Workers & Pages → Create → Pages → Connect to Git → вибери репо.
3. Build command: `(none)`, Build output: `/` — це чистий статичний сайт.
4. Custom domains → `fonts.dbn.co.ua`.

### Варіант 2 — Direct Upload

1. Cloudflare → Pages → Create → Direct upload.
2. Перетягни папку `fonts-cdn/` (або zip).
3. Назви проект, наприклад `dbn-fonts`.
4. Custom domains → `fonts.dbn.co.ua`.

### DNS

- **Якщо `dbn.co.ua` вже на Cloudflare nameservers** — додаси custom domain і запис створиться автоматично.
- **Якщо DNS лишився на hostiq** — у hostiq додай CNAME `fonts` → `dbn-fonts.pages.dev` і TXT-запис, який попросить Cloudflare для верифікації.

## Перевірка після деплою

```bash
# Файл доступний:
curl -I https://fonts.dbn.co.ua/fonts/example-font/ExampleFont-Regular.woff2

# CORS працює (має бути Access-Control-Allow-Origin: *):
curl -I -H "Origin: https://example.com" https://fonts.dbn.co.ua/fonts/example-font/ExampleFont-Regular.woff2

# CSS-обгортка працює:
curl https://fonts.dbn.co.ua/css/example-font.css
```

## Як користувачі підключають шрифт

**Найпростіше — один рядок у `<head>`:**

```html
<link rel="stylesheet" href="https://fonts.dbn.co.ua/css/example-font.css">
```

Потім у CSS:

```css
body { font-family: 'Example Font', sans-serif; }
```

**Для критичних шрифтів — preload:**

```html
<link rel="preload" href="https://fonts.dbn.co.ua/fonts/example-font/ExampleFont-Regular.woff2"
      as="font" type="font/woff2" crossorigin>
<link rel="stylesheet" href="https://fonts.dbn.co.ua/css/example-font.css">
```

## Юридичне

Перед хостингом стороннього шрифту переконайся, що його ліцензія дозволяє публічний веб-хостинг (free webfont / SIL OFL / public domain). Для шрифтів з обмеженням «только для личного использования» — не виставляй на CDN, дай лише архів для скачування.
