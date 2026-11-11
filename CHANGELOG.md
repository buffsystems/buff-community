# Buff Community Edition — выпуски

## v0.24.2 — 2026-11-11

## Что нового

Исправления и улучшения v0.24.1:

- Запрос, по которому решение уже принято, сразу уходит из списка «Требует внимания» — в кабинете и на телефоне.
- Страница публичной ссылки на сессию Buff Code показывает план чек-листом, субагентов и переданные файлы — карточками; сессию субагента можно открыть и прочитать.
- Админка: отказ при сохранении называет поля так, как они подписаны в форме.
- Мобильное приложение: сборки для Android и iPhone и инструкции по установке теперь в отдельном репозитории [buff-mobile](https://github.com/buffsystems/buff-mobile).

## What's new

Fixes and improvements to v0.24.1:

- A request that already has its decision leaves the "Needs attention" list at once — in the cabinet and on the phone.
- The public page of a shared Buff Code session shows the plan as a checklist, subagents and handed files as cards; a subagent's session can be opened and read.
- Admin panel: a refused save names the fields by their labels in the form.
- Mobile app: the Android and iPhone builds and the installation guides now live in a repository of their own, [buff-mobile](https://github.com/buffsystems/buff-mobile).

## v0.24.1 — 2026-11-10

## Что нового

Исправления v0.24.0:

- Глубокие исследования, задачи и аудиты больше не останавливаются на первом шаге с внутренней ошибкой. Исследование, которое успело упасть, можно продолжить кнопкой «Продолжить».
- Админка: если сохранение в окне не прошло, причина видна в самом окне, а не за ним.
- Телефон: в подробностях сессии Buff Code видны MCP-серверы машины; сессия, начатая в терминале, так и помечена; ссылка «ссылка и код», открытая извне, открывает ввод кода с этой ссылкой.

## What's new

Fixes to v0.24.0:

- Deep research, tasks and audits no longer stop at their first step with an internal error. A research that already failed can be resumed with "Continue".
- Admin panel: when a save in a dialog is refused, the reason shows in the dialog itself, not behind it.
- Phone: Buff Code session details list the machine's MCP servers; a session started in the terminal is marked as such; a "link and code" link opened from outside opens code entry with that link.

## v0.24.0 — 2026-11-10

## Что нового

### Публичные ссылки на диалоги
Ответ из «Спросить» или исследование можно отдать по ссылке человеку без доступа к Buff — коллеге, заказчику, подрядчику. Ссылку можно закрыть паролем и в любой момент отозвать ссылку. Пока Buff ещё отвечает, страница по ссылке обновляется вживую. Все ссылки собраны в «Настройки → Публичные диалоги».

### Вопрос в очередь, пока Buff отвечает
Следующий вопрос в «Спросить» можно задать, не дожидаясь ответа: он встанет в очередь с отметкой «В очереди» и уйдёт, как только Buff закончит.

### Исследование, которое не удалось, объясняет причину
Если исследование не завершилось, вы увидите, что пошло не так, и сможете возобновить его кнопкой «Продолжить».

### Видно, что вышла новая версия
Владельцы организации узнают о новом выпуске прямо в кабинете, а на экране лицензии видно, какая версия работает сейчас.

### Модели и цены
Каталог моделей и их цены берутся из шлюза моделей вашей установки, а расход считается по фактической стоимости каждого вызова.

### Мобильное приложение
- **Режим «Настройка».** С телефона можно попросить Buff Code подключить новый сервис. Агент задаёт вопросы формой, секреты вводятся скрыто, а вход в сервис возвращается прямо в приложение.
- **Очередь сообщений.** Пока агент работает, можно писать дальше: сообщения ждут над полем ввода, любое можно убрать или отправить сразу.
- **Публичные ссылки.** Поделиться можно сессией Buff Code, ответом «Спросить» или исследованием. Все ссылки — в «Настройки → Публичные ссылки».
- **Видно, что делает агент:** план и список дел, работающие субагенты, режим разрешений, итог сжатия контекста, строка «Работает…» с таймером. Подряд идущие вызовы инструментов сворачиваются в одну строку.
- **Управление моделью:** режим размышлений и размер контекстного окна для сессии Buff Code.
- **«Параметры ИИ»** (с buff.systems и Enterprise): уровень размышлений и окно контекста при создании вопроса, исследования или задачи. Значение видно на чипе в сессии и меняется прямо там.
- **Файлы:** HTML открывается как страница, с переключателем на исходный код; при загрузке виден прогресс.
- **История:** ранние сообщения сессии догружаются при прокрутке вверх.
- **Если модель не приняла файл,** приложение предлагает, как продолжить: разобрать файл через код или идти дальше без него.
- **Первый запуск:** на пустом экране — карточки Buff Code, Buff Community и демо.
- О выходе новой версии приложения сообщает раздел «О приложении».

## What's new

### Public links to conversations
An Ask answer or a research can be shared by link with someone who has no Buff access, such as a colleague, a client or a contractor. Protect a link with a password, and revoke it at any time. While Buff is still answering, the shared page updates live. All links are listed in Settings → Public conversations.

### Queue a question while Buff answers
You can ask your next question in Ask without waiting for the answer. It is marked "Queued" and goes out as soon as Buff finishes.

### A failed research tells you why
If a research did not finish, you see what went wrong, and "Continue" resumes it.

### You can see that a new version is out
Organisation owners learn about a new release right in the cabinet, and the licence screen shows which version is running.

### Models and prices
The model catalogue and its prices come from your installation's model gateway, and spending follows the real cost of each call.

### Mobile app
- **Setup mode.** From the phone, ask Buff Code to connect a new service. The agent asks with a form, secrets are typed hidden, and the service sign-in comes back straight into the app.
- **Message queue.** Keep writing while the agent works. Messages wait above the composer, and you can drop any of them or send it right away.
- **Public links.** Share a Buff Code session, an Ask answer or a research. All links are in Settings → Public links.
- **See what the agent is doing:** the plan and to-do list, working subagents, the permission mode, the compaction summary, and a "Working…" line with a timer. Tool calls in a row fold into one line.
- **Model control:** the thinking mode and the context window size of a Buff Code session.
- **"AI parameters"** (with buff.systems and Enterprise): the thinking level and context window when you create a question, a research or a task. The value shows on a chip in the session and can be changed right there.
- **Files:** HTML opens as a page with a switch to the source, and downloads show their progress.
- **History:** earlier messages of a session load as you scroll up.
- **When the model refuses a file,** the app offers ways to go on: read the file with code, or continue without it.
- **First start:** the empty screen shows Buff Code, Buff Community and demo cards.
- "About" tells you when a newer app version is out.

## v0.23.5 — 2026-11-04

Образ: `v0.23.5`. Снимок:
- cloud-front `b8bb5c0ce1ec`
- cloud-middle `be86edfaeb5b`
- auth-worker `18fa8a87b59c`
- backend-api `21b9548b2d7a`
- admin `6bbe0635610b`
- ask-worker `88b46c81d072`
- bot-worker `dee091a33d75`
- wm-flows `fc3ed3c7d694`
- common-lib `2dae2db99979`
- mcp `a04224e68299`
- deploy `c6257f4196f5`

## v0.23.4 — 2026-11-03

Образ: `v0.23.4`. Снимок:
- cloud-front `b8bb5c0ce1ec`
- cloud-middle `be86edfaeb5b`
- auth-worker `18fa8a87b59c`
- backend-api `21b9548b2d7a`
- admin `6bbe0635610b`
- ask-worker `a4524663bd74`
- bot-worker `ca20e1e70da8`
- wm-flows `02cc79be6b31`
- common-lib `f791cbbceca5`
- mcp `a04224e68299`
- deploy `3bee5f5b363b`

## v0.23.1 — 2026-11-01

Образ: `v0.23.1`. Снимок:
- cloud-front `b8bb5c0ce1ec`
- cloud-middle `be86edfaeb5b`
- auth-worker `18fa8a87b59c`
- backend-api `21b9548b2d7a`
- admin `6bbe0635610b`
- ask-worker `a4524663bd74`
- bot-worker `ca20e1e70da8`
- wm-flows `02cc79be6b31`
- common-lib `f791cbbceca5`
- mcp `a04224e68299`
- deploy `360339ef42b6`

## v0.23.0 — 2026-11-01

Образ: `v0.23.0`. Снимок:
- cloud-front `b8bb5c0ce1ec`
- cloud-middle `be86edfaeb5b`
- auth-worker `18fa8a87b59c`
- backend-api `21b9548b2d7a`
- admin `6bbe0635610b`
- ask-worker `90625e149e26`
- bot-worker `7c1788b3fc30`
- wm-flows `02cc79be6b31`
- common-lib `f791cbbceca5`
- mcp `a04224e68299`
- deploy `5777d536715f`

## v0.22.11 — 2026-11-01

Образ: `v0.22.11`. Снимок:
- cloud-front `aa66ef293f36`
- cloud-middle `be86edfaeb5b`
- auth-worker `f5a999a8c3ac`
- backend-api `99e7b3d1a6fb`
- admin `87e18f8bf7f8`
- ask-worker `90625e149e26`
- bot-worker `7c1788b3fc30`
- wm-flows `ed34461cad8b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `1b32d91de851`

## v0.22.10 — 2026-11-01

Образ: `v0.22.10`. Снимок:
- cloud-front `aa66ef293f36`
- cloud-middle `be86edfaeb5b`
- auth-worker `f5a999a8c3ac`
- backend-api `99e7b3d1a6fb`
- admin `87e18f8bf7f8`
- ask-worker `da4e7b44f0e5`
- bot-worker `d5a047512361`
- wm-flows `ed34461cad8b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `7dbed849b292`

## v0.22.5 — 2026-10-30

Образ: `v0.22.5`. Снимок:
- cloud-front `3847c067207f`
- cloud-middle `be86edfaeb5b`
- auth-worker `972ff991409f`
- backend-api `0db004b570d6`
- admin `87e18f8bf7f8`
- ask-worker `5df5887d37e0`
- bot-worker `259d80ed5d4c`
- wm-flows `ed34461cad8b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `3378376e6494`

## v0.22.4 — 2026-10-30

Образ: `v0.22.4`. Снимок:
- cloud-front `c3985efe2bcb`
- cloud-middle `be86edfaeb5b`
- auth-worker `f8ba4413ebd5`
- backend-api `0db004b570d6`
- admin `87e18f8bf7f8`
- ask-worker `5df5887d37e0`
- bot-worker `259d80ed5d4c`
- wm-flows `ed34461cad8b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `4317798e03cd`

## v0.22.3 — 2026-10-30

Образ: `v0.22.3`. Снимок:
- cloud-front `c3985efe2bcb`
- cloud-middle `be86edfaeb5b`
- auth-worker `f8ba4413ebd5`
- backend-api `0db004b570d6`
- admin `63f3eae25444`
- ask-worker `718178616f02`
- bot-worker `55c0e324d29f`
- wm-flows `f0f6388898cb`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `128ebe4c5149`

## v0.22.2 — 2026-10-29

Образ: `v0.22.2`. Снимок:
- cloud-front `cf9a66a4d289`
- cloud-middle `be86edfaeb5b`
- auth-worker `1e5524b54bd5`
- backend-api `aa6e6afe2853`
- admin `63f3eae25444`
- ask-worker `0fa6715c8f51`
- bot-worker `d0720ae74255`
- wm-flows `816328ac003b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `dcb26a0b8451`

## v0.22.1 — 2026-10-29

Образ: `v0.22.1`. Снимок:
- cloud-front `04c41a370fe3`
- cloud-middle `be86edfaeb5b`
- auth-worker `1e5524b54bd5`
- backend-api `aa6e6afe2853`
- admin `ef2d6bd32947`
- ask-worker `0fa6715c8f51`
- bot-worker `d0720ae74255`
- wm-flows `816328ac003b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `532f109f1513`

## v0.22.0 — 2026-10-29

Образ: `v0.22.0`. Снимок:
- cloud-front `04c41a370fe3`
- cloud-middle `be86edfaeb5b`
- auth-worker `528448739f4c`
- backend-api `d49ba61e750d`
- admin `ef2d6bd32947`
- ask-worker `96b8af53ad5d`
- bot-worker `4030a653e752`
- wm-flows `816328ac003b`
- common-lib `f791cbbceca5`
- mcp `766b06e96dee`
- deploy `185dc7f3f840`

## v0.21.7 — 2026-10-22

Образ: `v0.21.7`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `7e99f3eecb33`
- bot-worker `6c0dfad79c5d`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `8c56f56aa356`

## v0.21.6 — 2026-10-22

Образ: `v0.21.6`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `6a5d2d913463`
- bot-worker `77f5750de32c`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `6ef41be190d8`

## v0.21.5 — 2026-10-22

Образ: `v0.21.5`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `6534ffff807d`
- bot-worker `5dac123145be`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `ff48bd8eda45`

## v0.21.4 — 2026-10-22

Образ: `v0.21.4`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `96f7d2b0e588`
- bot-worker `a148b7b76dcf`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `02f7b7a4df00`

## v0.21.3 — 2026-10-21

Образ: `v0.21.3`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `cbed4b9efeca`
- bot-worker `d485cba588a0`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `404f0d219f1e`

## v0.21.2 — 2026-10-21

Образ: `v0.21.2`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `0f0db322319f`
- ask-worker `cbed4b9efeca`
- bot-worker `d485cba588a0`
- wm-flows `0976123e339d`
- common-lib `571327fcbee5`
- mcp `14040efd0b7a`
- deploy `404f0d219f1e`

## v0.21.1 — 2026-10-21

Образ: `v0.21.1`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `a56de97c3ed1`
- ask-worker `cbed4b9efeca`
- bot-worker `d485cba588a0`
- wm-flows `0976123e339d`
- common-lib `38c188d754da`
- mcp `14040efd0b7a`
- deploy `c7be483ba97e`

## v0.21.0 — 2026-10-21

Образ: `v0.21.0`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `a56de97c3ed1`
- ask-worker `cbed4b9efeca`
- bot-worker `d485cba588a0`
- wm-flows `0976123e339d`
- common-lib `38c188d754da`
- mcp `14040efd0b7a`
- deploy `0925460e3310`

## v0.20.0 — 2026-10-21

Образ: `v0.20.0`. Снимок:
- cloud-front `7f1956a36121`
- cloud-middle `2df905c86575`
- auth-worker `1b91691dca72`
- backend-api `9f854779b175`
- admin `a56de97c3ed1`
- ask-worker `cbed4b9efeca`
- bot-worker `d485cba588a0`
- wm-flows `9b746d081175`
- common-lib `9d89470e7205`
- mcp `14040efd0b7a`
- deploy `0e0e39910967`

