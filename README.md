# Software house — instalacja i obsługa

Oct 4, 2026 · @Maciej Kulesza

## Instalacja

Instalacja to pięć kroków; kroki 1, 2 i 5 robisz raz, kroki 3 i 4 w każdym nowym projekcie.

1. **Repozytorium skilli.** Załóż na GitHubie repozytorium `cieyhomelab/sh-skills` i wrzuć do niego zawartość archiwum `sh-skills.zip`: katalogi `skills/` i `workflows/`. Układ jest taki sam jak w `open-mercato/skills`.
2. **Skille Open Mercato dla Claude Code na VPS.** Skille `sh-*` odwołują się do skilli `om-*`, więc agent musi je mieć. Uruchom na VPS polecenie poniżej i przy pytaniu o miejsce wybierz instalację globalną dla Claude Code.

```bash
npx skills add open-mercato/skills --skill '*'
```

3. **Podpięcie skilli w projekcie.** Dodaj do repozytorium projektu plik `.ai/cezar/config.json` z treścią poniżej. Oba repozytoria muszą być na liście, bo własna lista zastępuje domyślną. Potem kliknij Refresh w zakładce Skills w Cezarze i sprawdź, czy pojawiły się skille `sh-*`. Prywatne `sh-skills` Cezar pobierze przez zalogowane `gh`.

```json
{
  "skillsRepos": [
    { "repo": "open-mercato/skills", "ref": "main" },
    { "repo": "cieyhomelab/sh-skills", "ref": "main" }
  ],
  "defaultRunner": "claude"
}
```

4. **Workflow.** Skopiuj `workflows/sh-delivery.yml` do `.ai/cezar/workflows/` w repozytorium projektu albo zaimportuj go w zakładce Workflows w Cezarze.
5. **Zasoby.** W Cezarze: Settings → Resources, 3 równoległe zadania i limit pamięci 5000 MB na zadanie. Na VPS: zainstaluj Dockera i dodaj 8 GB swapu.

## Obsługa w trybie ręcznym

Dopóki nie ma automatyzacji (element 6), każdy krok to nowe zadanie w Cezarze uruchamiane z telefonu; po elemencie 6 zostaną tylko kroki 0 i 1 oraz merge'e.

| Krok | Co robisz w Cezarze | Autonomous | Wynik |
| --- | --- | --- | --- |
| 0 | Zakładasz repozytorium z README, rejestrujesz je w Cezarze, dodajesz `.ai/cezar/config.json` i workflow | — | Projekt gotowy do pracy |
| 1 | Zadanie ze skillem `sh-analityk`, w treści pomysł; odpowiadasz na pytania w wątku zadania | wyłączone | PR ze specyfikacją; twój merge = bramka A |
| 2 | Zadanie ze skillem `sh-architekt`, w treści „Specyfikacja zmergowana” i link do PR | włączone | PR architektury; dodajesz wymienione sekrety i mergujesz (bramka D) |
| 3 | Zadanie ze skillem `sh-kierownik`, w treści „Tryb P” | włączone | Issues z etykietami `planned` i `ready` |
| 4 | Zakładka GitHub → issue z `ready` → uruchom z workflow `sh-delivery` | włączone | PR z etykietą `merge-queue`; mergujesz (bramka D) |
| 5 | Po merge'ach zadanie ze skillem `sh-kierownik`, w treści „Tryb R” | włączone | Kolejne issues dostają `ready`; wracasz do kroku 4 |

**Poprawki do PR:** dodaj do PR etykietę `do-poprawki` i opisz uwagi w komentarzach (zwykłym albo przy liniach kodu), potem uruchom `sh-delivery` na tym samym issue. Agenci używają twojego konta GitHub, więc ich komentarze zaczynają się od „🤖”; twój komentarz nie może zaczynać się od tego znaku, bo zostanie pominięty. Etykieta `changes-requested` należy do reviewera, nie używaj jej.

## Błędy, stan projektu i rzeczy do sprawdzenia

- **Błąd w gotowej aplikacji:** zakładasz issue na GitHubie, uruchamiasz `sh-kierownik` z „Tryb R”, potem `sh-delivery` na tym issue.
- **Etykieta `blocked`:** agent czeka na twoją decyzję; opcje i rekomendacja są w komentarzu. Po decyzji zdejmij etykietę.
- **Etykieta `spec-gap`:** uruchom `sh-analityk` (Autonomous wyłączone) z linkiem do issue; po merge'u poprawki specyfikacji zdejmij `blocked`.
- **Stan projektu w dowolnym momencie:** zadanie ze skillem `om-dev-status`.

Do sprawdzenia przy pierwszym uruchomieniu na VPS:

- [ ] Czy Cezar przyjmuje `skillsRepos` w konfiguracji globalnej `~/.cezar/config.json`; jeśli tak, krok 3 instalacji robisz raz.
- [ ] Czy skille `sh-*` pojawiają się w zakładce Skills po Refresh.
- [ ] Czy `om-setup-agent-pipeline --defaults` działa bez pytań.
- [ ] Jak automatyzacje GitHub w Cezarze filtrują issues (podstawa elementu 6).
