# Лицензия Buff Community Edition

**Версия 1.0, черновик от 20 октября 2026 года.** Русский текст является основным; английский перевод приведён для удобства. Окончательная редакция согласовывается с юристом до первого публичного выпуска.

## 1. Определения

- **Программа** — сборка Buff Community Edition: образы, файлы установки, сценарии и документация, распространяемые buff.systems под этой лицензией.
- **Лицензиар** — buff.systems.
- **Организация** — юридическое лицо, индивидуальный предприниматель или физическое лицо, установившее Программу.
- **Внутреннее использование** — применение Программы сотрудниками и подрядчиками Организации для нужд самой Организации.
- **Лицензия** — выданное Лицензиаром при регистрации Программы подписанное разрешение с пределами использования.

## 2. Что разрешено

Лицензиар бесплатно предоставляет Организации неисключительное, непередаваемое, отзываемое право:

1. установить Программу на инфраструктуре Организации;
2. использовать её для Внутреннего использования одной Организации;
3. пользоваться ею в пределах, записанных в Лицензии (число пользователей, одновременных раннеров и организаций).

Код, который Программа создаёт для Организации (изменения в репозиториях Организации, документы, отчёты), принадлежит Организации.

## 3. Что запрещено

Организация не вправе:

1. продавать, сдавать в аренду, сублицензировать или иным образом передавать Программу или доступ к ней третьим лицам;
2. оказывать с помощью Программы услуги третьим лицам, в том числе как управляемый сервис (managed service), хостинг или аутсорсинг разработки, если иное не согласовано с Лицензиаром письменно;
3. обходить, отключать или изменять проверку Лицензии, её пределы или механизм регистрации;
4. удалять или скрывать обозначения авторства и уведомления о правах;
5. изучать внутреннее устройство Программы способом, нарушающим применимое право, декомпилировать или дизассемблировать её, кроме случаев, прямо разрешённых законом;
6. использовать Программу для создания конкурирующего продукта.

Коммерческая Организация вправе использовать Программу для собственных нужд: запрет касается оказания услуг и передачи Программы другим, а не характера деятельности Организации.

## 4. Регистрация и проверка Лицензии

1. При первом запуске Программа регистрируется у Лицензиара: передаются название Организации, почта администратора, идентификатор установки и версия Программы.
2. Не реже раза в сутки Программа проверяет Лицензию у Лицензиара. При проверке передаются только: идентификатор установки, версия Программы, число пользователей и число раннеров. Иные данные, включая содержимое репозиториев, задач и документов, Лицензиаром не запрашиваются и не передаются.
3. Лицензия Community Edition бессрочна. Лицензиар вправе отозвать её при нарушении настоящей лицензии; после отзыва Программа перестаёт запускать новые работы, сохраняя доступ к уже созданным данным.
4. Отсутствие связи с Лицензиаром не прекращает действие Лицензии.

## 5. Сторонние компоненты

Программа использует сторонние компоненты, каждый под своей лицензией; их перечень и тексты лицензий — в файле THIRD-PARTY.md. Компоненты, которые Программа не включает в себя, а загружает из источников их авторов (например, Windmill), используются на условиях их авторов.

## 6. Отсутствие гарантий и ограничение ответственности

Программа предоставляется «как есть». Лицензиар не даёт гарантий пригодности для конкретной цели, бесперебойной работы или отсутствия ошибок и не несёт ответственности за убытки, возникшие из использования или невозможности использования Программы, в максимально допустимой законом степени. Техническая поддержка Community Edition не предоставляется; вопросы принимаются в публичном репозитории.

## 7. Прекращение

Нарушение настоящей лицензии прекращает её действие автоматически. Организация обязана прекратить использование Программы; данные Организации остаются у неё.

## 8. Применимое право

К настоящей лицензии применяется право Российской Федерации. Споры рассматриваются по месту нахождения Лицензиара.

---

# Buff Community Edition License (English translation)

**Version 1.0, draft of 20 October 2026.** The Russian text prevails; this translation is provided for convenience.

**1. Definitions.** *Software* — the Buff Community Edition build: images, installation files, scripts and documentation distributed by buff.systems under this licence. *Licensor* — buff.systems. *Organisation* — the legal entity, sole proprietor or natural person that installed the Software. *Internal Use* — use of the Software by the Organisation's employees and contractors for the Organisation's own needs. *Licence* — the signed permission with usage limits issued by the Licensor at registration.

**2. Grant.** The Licensor grants the Organisation, free of charge, a non-exclusive, non-transferable, revocable right to install the Software on the Organisation's infrastructure, use it for Internal Use of one Organisation, and use it within the limits recorded in the Licence (users, concurrent runners, organisations). Code and documents the Software produces for the Organisation belong to the Organisation.

**3. Restrictions.** The Organisation shall not: (1) sell, rent, sublicense or otherwise transfer the Software or access to it to third parties; (2) provide services to third parties with the Software, including as a managed service, hosting or outsourced development, unless agreed with the Licensor in writing; (3) circumvent, disable or alter the Licence check, its limits or the registration mechanism; (4) remove or hide authorship and rights notices; (5) reverse engineer, decompile or disassemble the Software except as expressly permitted by law; (6) use the Software to build a competing product. A commercial Organisation may use the Software for its own needs: the restriction concerns providing services and transferring the Software to others, not the nature of the Organisation's business.

**4. Registration and Licence check.** At first start the Software registers with the Licensor (organisation name, administrator e-mail, installation identifier, Software version). At least daily the Software checks the Licence with the Licensor, sending only the installation identifier, the Software version, the number of users and the number of runners; no other data, including repositories, tasks or documents, is requested or sent. The Community Edition Licence is perpetual; the Licensor may revoke it upon a breach of this licence, after which the Software stops starting new work while keeping access to existing data. Loss of connectivity to the Licensor does not terminate the Licence.

**5. Third-party components** are listed with their licences in THIRD-PARTY.md. Components the Software does not include but downloads from their authors' sources (for example, Windmill) are used on their authors' terms.

**6. No warranty; limitation of liability.** The Software is provided "as is", without warranties of any kind, and the Licensor is not liable for any damages arising from its use or inability to use it, to the maximum extent permitted by law. No technical support is provided for the Community Edition; questions are accepted in the public repository.

**7. Termination.** A breach terminates this licence automatically; the Organisation must stop using the Software and keeps its data.

**8. Governing law.** The law of the Russian Federation applies; disputes are resolved at the Licensor's seat.
