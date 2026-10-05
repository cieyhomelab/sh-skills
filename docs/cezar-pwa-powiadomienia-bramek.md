# Powiadomienia o bramkach software house'u

Issue do repozytorium `cezar-pwa`. Rozszerza sidecar `cezar-push` i service worker PWA o trzeci rodzaj powiadomienia, niezwiązany z zadaniem Cezara: bramkę, na którą czeka właściciel.

## Cel

Autonomiczny software house (skille `sh-*`) zatrzymuje się w trzech miejscach, w których decyduje właściciel. Agenci i właściciel używają tego samego konta GitHub, więc GitHub nie powiadamia o tych PR-ach (autor nie dostaje powiadomień o własnych PR). Powiadomienie push z Cezar Mobile ma być jedynym sygnałem, że coś czeka.

| `gate` | Kiedy | Tekst na telefonie (propozycja) |
|---|---|---|
| `spec` | Analityk otworzył PR ze specyfikacją | „Specyfikacja czeka na zatwierdzenie” |
| `merge` | Reviewer zaakceptował PR albo architekt otworzył PR architektury | „PR czeka na merge” |
| `blocked` | Agent dodał etykietę `blocked` | „Potrzebna twoja decyzja” |

Treść powiadomienia: `{repo}#{numer}` i tytuł issue lub PR (najwyżej 100 znaków). Zgodnie z FR-043 nic więcej: bez kodu, bez opisu, bez komentarzy. Dotknięcie otwiera `url` (strona issue lub PR na GitHubie).

To drugi, po limitach (#94), wyjątek od zasady „tylko zadania”. Decyzję podjął właściciel; należy ją dopisać do Non-Goals w `docs/REQUIREMENTS.md`, jak przy #94.

## Endpoint sidecara

`POST /m/push/gate`, tylko z loopbacka:

- Nagłówek `X-Cezar-Push-Token` musi być równy zawartości `STATE_DIR/gate-token`. Token generuje `init` (albo pierwsze uruchomienie, jeśli pliku brak): 32 losowe bajty w hex, plik 0600. Porównanie w czasie stałym.
- Żądanie z nagłówkiem `Origin` albo `X-Forwarded-For` jest odrzucane (403). To endpoint dla procesów na VPS, nie dla przeglądarki.
- nginx nie przekazuje tej ścieżki z zewnątrz: w `deploy/nginx/cezar-mobile.conf` dodać `location = /m/push/gate { return 404; }` przed blokiem `^~ /m/push/`.
- Ciało (zod, odrzucenie nadmiarowych kluczy): `gate` z `spec | merge | blocked`, `repo` w formacie `owner/name`, `number` dodatnia liczba całkowita, `title` 0–100 znaków, `url` zaczynający się od `https://github.com/`.
- Odpowiedzi: 202 `{ sent, deduplicated }`, 400 przy złym ciele, 401 przy złym tokenie, 403 przy żądaniu z przeglądarki lub proxy.
- Wysyłka do wszystkich subskrypcji, ta sama obsługa 404/410/timeoutów co przy powiadomieniach o zadaniach.

**Deduplikacja:** ten sam `gate` dla tego samego `repo#number` w ciągu 10 minut wysyłany jest raz (agent może wywołać skrypt dwa razy w jednym przebiegu). Pamięć w `STATE_DIR/gate-alerts.json` (0600), zapisywana przed wysyłką, jak przy limitach. Po 10 minutach ten sam sygnał może zadzwonić znowu, bo `blocked` dodane ponownie po kilku godzinach to nowa sprawa.

**Topic i tag:** `Topic` push i `tag` powiadomienia z hasha `gate/repo/number`, żeby kolejne powiadomienie o tej samej sprawie zastępowało poprzednie.

## Payload i service worker

- `PushPayload.kind` dostaje wartość `gate` oraz pola `gate`, `repo`, `number`, `url` (tytuł w istniejącym `title`).
- `readPushPayload` przyjmuje nowy kind; nieznana wartość `gate` dostaje ogólny tekst zastępczy.
- Teksty w `i18n/en.ts` (i polskim odpowiedniku, jeśli istnieje).
- `notificationclick`: dla `gate` otwiera `url` przez `clients.openWindow(url)` bezpośrednio. Nie używa `postMessage` do okna aplikacji, bo adres jest poza PWA.

## Testy

- Sidecar: brak tokenu 401, zły token 401, `Origin` 403, `X-Forwarded-For` 403, złe ciało 400, poprawne 202 z wysyłką do wszystkich subskrypcji, deduplikacja w oknie 10 minut i ponowna wysyłka po nim, token tworzony z uprawnieniami 0600.
- Service worker: tekst dla każdego `gate`, ogólny tekst dla nieznanej wartości, kliknięcie otwiera `url`.
- nginx: `/m/push/gate` z zewnątrz zwraca 404.

## Wywołujący

Skrypt `bin/sh-notify` z repozytorium `sh-skills`, zainstalowany w `~/.local/bin` na VPS:

```
sh-notify <spec|merge|blocked> <owner/repo> <numer> [tytuł]
```

Do czasu wdrożenia endpointu skrypt dostaje 404 i kończy się bez błędu, więc obie strony można wdrażać niezależnie.
