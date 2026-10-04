# Software house — instalacja i obsługa

Oct 4, 2026 · @Maciej Kulesza

## Instalacja

Instalacja to pięć kroków; kroki 1, 2 i 5 robisz raz, kroki 3 i 4 w każdym nowym projekcie.

1. **Repozytorium skilli.** Załóż na GitHubie repozytorium `cieyhomelab/sh-skills` i wrzuć do niego zawartość archiwum `sh-skills.zip`: katalogi `skills/` i `workflows/`. Układ jest taki sam jak w `open-mercato/skills`.
2. **Skille Open Mercato dla Claude Code na VPS.** Skille `sh-*` odwołują się do skilli `om-*`, więc agent musi je mieć. Uruchom na VPS polecenie poniżej i przy pytaniu o miejsce wybierz instalację globalną dla Claude Code.

```bash
npx skills add open-mercato/skills --skill '*'
```

3. **Skille sh-* globalnie na VPS.*\* Cezar widzi skille z `~/.claude/skills` w każdym projekcie, także w świeżo zarejestrowanym, który nie ma jeszcze żadnej konfiguracji. Wykonaj na VPS jako użytkownik, na którym działa Cezar, i kliknij Refresh w zakładce Skills. Plik `.ai/cezar/config.json` nie jest potrzebny.

```bash
gh repo clone cieyhomelab/sh-skills ~/sh-skills
mkdir -p ~/.claude/skills
for d in ~/sh-skills/skills/*/; do ln -sfn "$d" ~/.claude/skills/$(basename "$d"); done
```

Aktualizacja po zmianach w skillach: `git -C ~/sh-skills pull`. Gdy dojdzie nowy skill, uruchom ponownie pętlę `for`.

4. **Workflow.** Skopiuj `workflows/sh-delivery.yml` do `.ai/cezar/workflows/` w repozytorium projektu albo zaimportuj go w zakładce Workflows w Cezarze.
5. **Zasoby.** W Cezarze: Settings → Resources, 3 równoległe zadania i limit pamięci 5000 MB na zadanie. Na VPS: zainstaluj Dockera i dodaj 8 GB swapu.

## Obsługa z automatyzacją

Po konfiguracji twoja rola to pomysł, odpowiedzi w Q&A i merge'e; resztę uruchamiają automatyzacje Cezara i godzinny przegląd.

**Jednorazowo:** załóż repozytorium `sh-control` z README, zarejestruj je w Cezarze i uruchom w nim zadanie ze skillem `sh-start` (Autonomous włączone). Powstanie godzinny przegląd wszystkich projektów.

**W każdym projekcie:** załóż repozytorium z README, zarejestruj je w Cezarze i uruchom w nim zadanie ze skillem `sh-start` (Autonomous włączone). Skill dodaje konfigurację, workflow, etykiety i trzy automatyzacje.

| Zdarzenie | Kto uruchamia | Co się dzieje |
| --- | --- | --- |
| Wpisujesz pomysł | Ty: zadanie `sh-analityk`, Autonomous wyłączone | Wywiad i PR ze specyfikacją |
| Merge specyfikacji (bramka A) | Przegląd, do godziny | Opiekun tworzy issue `sh-architekt`, automatyzacja uruchamia architekta |
| Merge architektury (bramka D) | Przegląd, do godziny | Kierownik tnie specyfikację na issues i nadaje `ready` |
| Issue dostaje `ready` | Automatyzacja, do 2 minut | Workflow `sh-delivery`: inżynier, tester, reviewer |
| Merge PR z kodem (bramka D) | Przegląd, do godziny | Opiekun zamyka issue, kierownik wypuszcza kolejne |
| Dodajesz `do-poprawki` do issue | Automatyzacja, do 2 minut | Inżynier wprowadza twoje uwagi z PR |
| Zakładasz issue z błędem | Przegląd, do godziny | Kierownik nadaje priorytet i kolejkuje |

Cezar nie ma zdarzenia „PR zmergowany”, dlatego merge'e wykrywa godzinny przegląd. Gdy przez ostatnią godzinę nic się nie zmieniło, przegląd tylko sprząta VPS; co 6 godzin robi pełny przegląd, żeby wyłapać utkniętą pracę.

## Obsługa ręczna (gdy automatyzacje nie działają)

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
