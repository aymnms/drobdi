# USER.md — Ton humain

_Apprends à connaître la personne que tu aides. Mets à jour ce fichier au fil du temps._

- **Prénom :** Aymerick
- **Comment l'appeler :** Aymerick
- **Pronoms :** (non renseigné)
- **Fuseau horaire :** Europe/Paris
- **Langue :** Français — toujours répondre en français (les réponses en anglais sont une erreur à ne pas répéter)
- **Style :** Communication directe et décontractée. Pas de blabla inutile.

## Contexte

**Projet principal :** Recherche d'emploi active dans la tech — automatiser et optimiser le processus de candidature dans des entreprises françaises tech, avec une préférence pour les PME produit (50-150 employés, backend Python, hors ESN/consulting), mais ces critères ne sont pas bloquants si l'entreprise présente d'autres atouts.

**Outils & workflows :**
- **drobsidian** — vault Obsidian géré comme projet git, situé dans ce workspace : `./drobsidian/`. Contient les sprints Scrum hebdomadaires, le suivi des tâches (TD-XXXX), les entreprises prospectées et les projets personnels.
- **Référence profil personnel/pro** : si présent, consulter aussi `./drobsidian/projets/Profil-professionnel.md` comme synthèse portable de qui est Aymerick pour le contexte recherche d’emploi, candidatures et collaboration avec d’autres IA.
- **Habitude git** : toujours `git pull` avant toute action sur drobsidian, puis modifier, puis `git commit && git push`.
- **Messages de commit** : en anglais, format Conventional Commits (`type(scope): description` — ex: `feat(sprints): add W18 sprint file`, `fix(tasks): correct TD-0031 status`, `chore(recurring): add W17 recurring tasks`).
- **Google Calendar** : intégré via `gog` pour le compte `drobdilamenace@gmail.com`.

## Règles Sprint/Scrum (drobsidian)

- 1 tâche = 1 sprint (jamais plusieurs sprints par tâche)
- Si une tâche est reportée au sprint suivant : créer une **nouvelle tâche** (nouveau TD-XXXX) avec champ `Reprend: [[TD-ancienne]]`
- À la clôture d'un sprint : inclure une section `## Références des tâches du sprint` listant toutes les références (terminées ou non)
- Les champs qui pointent vers d'autres notes utilisent des **wikilinks Obsidian** : `[[NomDuFichier]]`
- **Projet libre vs fichier projet :**
  - Projet libre (valeur simple, sans wikilink) → tâche ponctuelle ou domaine informel (ex: "Perso", "Admin")
  - Fichier projet (wikilink `[[NomDuFichier]]`) → projet suivi avec objectif, priorité, état d'avancement
- Drobdi ne doit **jamais** refuser de créer une tâche parce que le projet n'a pas de fichier `.md` — il crée la tâche avec la valeur telle quelle

## Règles frontmatter tâche

- `Début` est optionnel. `Fin` ne peut être renseignée que si `Début` est défini.
- Si `Début` contient une heure (ex: `2026-04-14T19:00`) → événement Google Calendar avec plage horaire précise
- Si `Début` contient uniquement une date (ex: `2026-04-14`) → événement Google Calendar en journée entière
- Si `Google Calendar: true` → créer l'événement dans le calendrier d'Aymerick (`drobdilamenace@gmail.com`)
- Valeurs possibles pour `Récurrence` : `non` / `hebdomadaire` / `mensuel`

## Template frontmatter projet

```yaml
Titre:
Statut: En cours
Priorité: [Vital / À traiter / …]
Domaine: [Carrière / Santé / Perso / …]
```

## Suivi entreprises

- Les entreprises prospectées sont trackées dans `drobsidian/entreprises/*.md`
- Critères préférentiels (non bloquants) : idéalement entreprises produit, 50-150 employés, backend Python, hors ESN/consulting — une entreprise hors critères peut rester pertinente si elle présente d'autres atouts
- Champs de relance : `Date relance J+3` et `Date relance J+7` (avec dates effectives correspondantes)
- Notifications via Telegram (ID : 8655385911)

---

Plus tu en sais, mieux tu peux aider. Mais rappelle-toi — tu apprends à connaître une personne, pas à constituer un dossier sur elle. Respecte la différence.
