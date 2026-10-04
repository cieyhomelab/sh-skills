# Autonomiczny software house — karty ról

Oct 4, 2026 · @Maciej Kulesza

## Założenia

System przyjmuje dowolny pomysł i oddaje przetestowany, zrecenzowany PR na GitHubie. Merge zawsze robi właściciel.

| Obszar | Ustalenie |
| --- | --- |
| Zakres | Dowolne aplikacje i dowolny stos, dla właściciela lub klientów zewnętrznych |
| Wejście | Pomysł wpisany z telefonu w przeglądarce, potem sesja Q&A z analitykiem |
| Autonomia | Poza dwiema bramkami praca bez udziału człowieka; raporty push; wejście w dowolnym momencie |
| Bramka A | Właściciel zatwierdza specyfikację po Q&A |
| Bramka D | Właściciel merguje każdy PR |
| Definicja gotowe | Otwarty PR z zielonym pełnym zestawem testów (jednostkowe, integracyjne, E2E, build) i zaakceptowaną recenzją |
| Repozytoria | Zakłada właściciel ręcznie i rejestruje w Cezarze |
| Infrastruktura | VPS z Cezarem (orkiestrator, kolejka, worktree), skille open-mercato/skills, aplikacja mobilna z powiadomieniami push |
| Koszty | Bez limitu; zewnętrzne API dozwolone, gdy test tego wymaga |

## Przepływ pracy

&#91;embedded content: przepływ pracy · 2 bramki, pętla poprawek\]

Kierownik wypuszcza kolejne issues po każdym merge'u. Poprawki z testów, z recenzji i z twojego „Request changes” wracają do inżyniera.

## Karty ról

Osiem ról: właściciel i siedmiu agentów. Pięć ról opiera się na gotowych skillach Open Mercato; kierownik i architekt potrzebują własnych skilli.

### Właściciel (ty)

- **Cel:** nadaje kierunek i podejmuje dwie decyzje.
- **Robi:** zakłada repozytorium i rejestruje je w Cezarze; wpisuje pomysł; odpowiada w sesji Q\&A; zatwierdza specyfikację (bramka A); merguje PR albo odsyła go etykietą do-poprawki z komentarzem (bramka D); zgłasza błędy jako issues; dostarcza klucze do zewnętrznych API.
- **Dostaje push:** przy każdej bramce i każdej eskalacji.

### Kierownik (jeden dla wszystkich projektów)

- **Cel:** każdy zatwierdzony pomysł dochodzi do PR, we właściwej kolejności i bez blokad.
- **Uruchamia się:** po bramce A; po każdym merge'u; po nowym issue z błędem; cyklicznie na przegląd stanu.
- **Wejście:** zatwierdzona specyfikacja, stan issues i PR we wszystkich projektach.
- **Wyjście:** issues na GitHubie pocięte na niezależne pionowe wycinki, z priorytetem, ryzykiem i zależnościami; oznaczenie issue jako gotowego do podjęcia przez Cezara; priorytety błędów; zlecenie dla architekta przy nowym repozytorium.
- **Zasady:** tnie pracę tak, by zależności było jak najmniej; issue zależne wypuszcza dopiero po merge'u poprzednika.
- **Może:** tworzyć i etykietować issues, ustawiać priorytety, wstrzymywać i wypuszczać zadania, wybierać workflow.
- **Nie może:** pisać kodu, mergować, zmieniać zatwierdzonej specyfikacji.
- **Skille:** `om-prepare-issue`, `om-merge-buddy` (tylko odczyt), `om-dev-status` (stan prac) oraz własny skill kierownika do napisania.
- **Gotowe, gdy:** każdy wycinek specyfikacji ma issue, a każde issue ma PR albo jest jawnie wstrzymane.
- **Eskaluje, gdy:** issue jest zablokowane i nie da się go odblokować.

### Analityk

- **Cel:** specyfikacja tak kompletna, że inżynier niczego nie zgaduje.
- **Uruchamia się:** gdy wpiszesz pomysł (zadanie nieautonomiczne w Cezarze); gdy inżynier zgłosi lukę w specyfikacji.
- **Wejście:** pomysł i twoje odpowiedzi.
- **Wyjście:** specyfikacja funkcjonalna w `.ai/specs`: cel, użytkownicy, funkcje, kryteria akceptacji, scenariusze testowe, pusta sekcja otwartych pytań.
- **Może:** zadawać pytania, pisać i commitować specyfikację.
- **Nie może:** wybierać stosu, tworzyć issues, pisać kodu aplikacji.
- **Skille:** `om-spec-writing`.
- **Gotowe, gdy:** nie ma otwartych pytań i zatwierdzisz specyfikację (bramka A).
- **Eskaluje:** zawsze do ciebie; jest twoim jedynym rozmówcą w sprawie wymagań.

### Architekt

- **Cel:** repozytorium gotowe do autonomicznej pracy.
- **Uruchamia się:** po bramce A w nowym repozytorium; przy dużej zmianie architektury w istniejącym.
- **Wejście:** zatwierdzona specyfikacja, puste repozytorium.
- **Wyjście:** decyzja o stosie z uzasadnieniem zapisana w repozytorium; techniczna część specyfikacji; szkielet aplikacji; `AGENTS.md`; `.ai/agentic.config.json` i `SDLC.md`; komendy walidacji dla pełnego zestawu testów; CI; przepis na tymczasowe środowisko testowe.
- **Forma:** wszystko trafia jako pierwszy PR, który przechodzi bramkę D, zanim kierownik wypuści issues.
- **Może:** wybrać dowolny stos i dowolne narzędzia.
- **Nie może:** implementować funkcji ze specyfikacji, mergować.
- **Skille:** `om-setup-agent-pipeline` oraz własny skill architekta do napisania.
- **Gotowe, gdy:** szkieletowy PR ma zielone CI i działający pusty test E2E.
- **Eskaluje, gdy:** nie da się dobrać stosu do specyfikacji albo potrzebne są klucze do zewnętrznych usług.

### Inżynier

- **Cel:** z issue powstaje PR spełniający kryteria akceptacji.
- **Uruchamia się:** gdy issue jest oznaczone jako gotowe; po recenzji „Request changes” od reviewera albo od ciebie; po nadaniu priorytetu issue z błędem.
- **Wejście:** issue, specyfikacja, `AGENTS.md`.
- **Wyjście:** PR z osobnego worktree, testy do nowego kodu, zielona walidacja, opis zmian.
- **Model:** inny niż reviewer.
- **Może:** zmieniać kod i testy w swoim worktree, otwierać i aktualizować PR.
- **Nie może:** mergować, robić force-push, używać `--no-verify`, wyłączać testów, zmieniać specyfikacji.
- **Skille:** `om-auto-create-pr`, `om-auto-create-pr-loop` (duże specyfikacje), `om-auto-fix-issue`, `om-auto-continue-pr`.
- **Gotowe, gdy:** PR jest otwarty, walidacja zielona, a praca przekazana testerowi.
- **Eskaluje:** lukę w specyfikacji do analityka; testy, których nie da się naprawić, do ciebie.

### Tester

- **Cel:** dowód, że PR działa na uruchomionej aplikacji.
- **Uruchamia się:** przy nowym PR i przy każdych nowych commitach w PR.
- **Wyjście:** wynik pełnego zestawu testów; nowe testy E2E dla kryteriów akceptacji; raport w PR.
- **Może:** stawiać i usuwać tymczasowe instancje na VPS dowolnym narzędziem; używać prawdziwych zewnętrznych API, gdy test tego wymaga; naprawiać testy i CI.
- **Nie może:** zmieniać logiki aplikacji tylko po to, żeby test przeszedł; ogłaszać sukcesu bez dowodu; zostawiać instancji po testach.
- **Skille:** `om-integration-tests`, `om-stabilize-ci`.
- **Gotowe, gdy:** wszystkie testy są zielone, a środowisko posprzątane.
- **Eskaluje:** błąd w kodzie do inżyniera; problem nie do naprawienia do ciebie.

### Reviewer

- **Cel:** niezależna ocena jakości PR.
- **Uruchamia się:** po zielonych testach.
- **Model:** inny niż inżynier, w ramach Claude lub Codex.
- **Wyjście:** akceptacja albo „Request changes” z konkretną listą poprawek.
- **Limit:** 3 cykle poprawek; kolejny cykl trafia do ciebie.
- **Nie może:** mergować ani poprawiać kodu samodzielnie; poprawki robi inżynier.
- **Skille:** `om-auto-review-pr`, `om-code-review`, reguły z `CODE_REVIEW.md`.
- **Gotowe, gdy:** PR jest zaakceptowany i dostajesz push, że czeka na merge.

### Opiekun

- **Cel:** porządek po merge'u.
- **Uruchamia się:** po merge'u i po zamknięciu PR bez merge'a.
- **Wyjście:** zamknięte issues rozwiązane przez PR; informacja dla kierownika o odblokowanych zależnościach; posprzątane worktree.
- **Skille:** `om-sync-merged-pr-issues`.

## Reguły globalne i eskalacja

Siedem reguł obowiązuje każdego agenta, bez wyjątków.

1. Żaden agent nie merguje do głównej gałęzi.
2. Zakazane są force-push, `--no-verify` oraz wyłączanie lub pomijanie testów.
3. Każde zadanie działa w osobnym worktree i zajmuje issue etykietą `in-progress`.
4. Specyfikację zmienia tylko analityk; każda zmiana zakresu wraca na bramkę A.
5. Sekrety dostarcza właściciel; agenci nigdy nie zapisują ich w repozytorium.
6. Koszty nie są limitowane.
7. Tymczasowe środowiska testowe są usuwane po każdym przebiegu testów.

Push do ciebie wychodzi w dwóch przypadkach: gdy czeka bramka i gdy praca stanęła.

| Sytuacja | Kto wykrywa | Co się dzieje |
| --- | --- | --- |
| Specyfikacja gotowa | Analityk | Bramka A: czeka na twoje zatwierdzenie |
| PR zaakceptowany | Reviewer | Bramka D: czeka na twój merge |
| 3 cykle review bez akceptacji | Reviewer | PR dostaje etykietę `blocked`, praca stoi |
| Testy nie przechodzą mimo prób naprawy | Tester lub inżynier | PR dostaje etykietę `blocked`, praca stoi |
| Luka w specyfikacji | Inżynier | Zadanie wraca do analityka, który dopytuje ciebie |
| Nie da się dobrać stosu | Architekt | Projekt stoi do twojej decyzji |
| Zmiana dotyka bezpieczeństwa lub danych | Reviewer | PR dostaje etykiety `risk-high` i `needs-qa`, ty wykonujesz QA przed merge'em |

## Narzędzia (wersja robocza)

Całość działa na jednym VPS z Cezarem; GitHub (konto cieyhomelab) jest jedynym miejscem przekazywania pracy, a obie bramki to merge PR.

### Role, modele i skille

| Rola | Agent i model | Uruchomienie w Cezarze | Skille |
| --- | --- | --- | --- |
| Analityk | Claude, najmocniejszy model | Zadanie nieautonomiczne z telefonu | `om-spec-writing`, kończy PR ze specyfikacją |
| Architekt | Claude, najmocniejszy model | Po merge'u PR ze specyfikacją w nowym repozytorium | `om-setup-agent-pipeline` + własny skill architekta |
| Kierownik | Claude, najmocniejszy model | Po merge'u, po nowym issue z błędem, cyklicznie | `om-prepare-issue`, `om-dev-status` + własny skill kierownika |
| Inżynier | Claude, szybszy model | Issue z etykietą gotowości, recenzja „Request changes” | `om-auto-create-pr`, `om-auto-fix-issue`, `om-auto-continue-pr` |
| Tester | Claude, szybszy model | Krok workflow po implementacji | `om-integration-tests`, `om-stabilize-ci` |
| Reviewer | Claude, najmocniejszy model (inny niż inżynier) | Krok workflow po zielonych testach | `om-auto-review-pr` z nadpisaniem: bez samodzielnych poprawek |
| Opiekun | Claude, lżejszy model | Po merge'u lub zamknięciu PR | `om-sync-merged-pr-issues` |

### Mechanizmy

| Potrzeba | Rozwiązanie |
| --- | --- |
| Bramka A | Analityk otwiera PR ze specyfikacją; twój merge = zatwierdzenie |
| Bramka D | Twój merge PR z kodem |
| Wyzwalacze zdarzeń | Automatyzacje GitHub w Cezarze (`CEZ_AUTOMATIONS=1`); do sprawdzenia, które zdarzenia obsługują, w razie braków cykliczny przegląd kierownika |
| Łańcuch inżynier, tester, reviewer | Jeden workflow YAML w Cezarze: kroki z różnymi runnerami, powrót do inżyniera z limitem 3 cykli review |
| Skille własne i nadpisania | Repozytorium skilli zespołu na koncie cieyhomelab, podpięte w Cezarze obok open-mercato/skills |
| CI | GitHub Actions: testy jednostkowe, integracyjne, build |
| E2E | Tester na VPS: Docker Compose z unikalną nazwą projektu na zadanie, usuwany po testach, plus okresowe sprzątanie porzuconych instancji |
| Sekrety | Pliki `.env` na VPS poza repozytoriami, uprawnienia 600; przekazywane agentom przez `CEZ_ENV_PASSTHROUGH` lub wczytywane przez Compose |
| Powiadomienia push | Aplikacja na telefonie: obie bramki (specyfikacja i kod czekają na merge) oraz etykieta `blocked` |

### Zasoby VPS

VPS ma 8 vCPU, 22 GB RAM, 200 GB dysku i brak swapu. Proponowane ustawienia:

- Równolegle 3 zadania (`maxParallel: 3`); każde z instancją E2E zajmuje kilka GB RAM.
- Limit pamięci na zadanie (`memoryLimitMb`) około 5 GB, żeby jedno zadanie nie zabiło pozostałych.
- Dodać 8 GB swapu jako zabezpieczenie przed zabiciem procesów przy braku pamięci.
- Zostawić domyślne trzymanie 10 ostatnich worktree; dysku wystarczy z zapasem.

Dostęp z telefonu idzie przez nginx z logowaniem opartym o cookie. Dockera instaluje właściciel.

## Decyzje do potwierdzenia i otwarte kwestie

Poniższe decyzje podjąłem sam tam, gdzie wywiad zostawił lukę. Odhacz te, które akceptujesz.

- [x] Inżynier reaguje tylko na etykietę do-poprawki ustawioną przez właściciela, nie na pojedyncze komentarze (wspólne konto GitHub, więc formalna recenzja jest niemożliwa).
- [x] Lukę w specyfikacji inżynier zgłasza analitykowi, a analityk dopytuje ciebie.
- [x] Tester sprawdza PR przed reviewerem, więc reviewer ocenia tylko zielone PR-y.
- [x] Szkieletowy PR architekta też przechodzi bramkę D.
- [x] Analityk pisze specyfikację funkcjonalną; architekt dopisuje część techniczną po bramce A.
- [x] Reviewer nie poprawia kodu sam; poprawki zawsze robi inżynier.
- [x] Opiekun pozostaje osobną rolą, zamiast wejść w zakres kierownika.
- [x] Powrót PR od testera do inżyniera nie wlicza się do limitu 3 cykli review.

Na etapie narzędzi trzeba rozstrzygnąć:

- Jak uruchamiać kierownika: automatyzacje GitHub w Cezarze, zadanie cykliczne czy GitHub Actions.
- Jak issue trafia do kolejki Cezara: etykieta i odpytywanie GitHuba (`CEZ_AUTOMATIONS`).
- Które modele obsługują które role, z rozdziałem inżynier i reviewer.
- Gdzie i jak przechowywać sekrety na VPS.
- Czym stawiać tymczasowe środowiska testowe.
- Które zdarzenia wysyłają push do aplikacji i skąd.
- Gdzie trzymać własne skille kierownika i architekta, np. w repozytorium skilli zespołu podpiętym do Cezara.
