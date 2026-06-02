# MEMORY.md

## Drobsidian
- Règle sprint: une tâche appartient à un seul sprint.
- Si une tâche doit continuer au sprint suivant, on crée une nouvelle tâche avec un nouveau `TD-XXXX` et `Reprend: [[TD-ancienne]]`.
- À la clôture d’un sprint, la section `## Références des tâches du sprint` doit lister toutes les tâches du sprint, terminées ou non.
- Toute tâche non finie d’un sprint clos doit être passée en `Archivé`.
- Une tâche archivée d’un sprint clos n’est jamais déplacée vers le sprint suivant, elle est reprise via une nouvelle tâche.
- Cas particulier des tâches récurrentes non faites: elles doivent rester traitées comme des tâches récurrentes au sprint suivant pour continuer à être reconduites automatiquement, mais sans être dupliquées deux fois dans le même nouveau sprint.
- Sync calendrier: dès qu’une tâche drobsidian est créée, modifiée ou supprimée, il faut répercuter le changement dans Google Calendar si la tâche est concernée par le calendrier.
- Au démarrage d’un nouveau sprint, `Taches.base` doit être mis à jour: créer une vue figée nommée avec le sprint qui vient de se terminer en copiant le filtre actuel de `Sprint active`, puis faire pointer `Sprint active` vers le nouveau sprint en cours.
- Pour la recherche d’emploi dans drobsidian, la structure cible est désormais: `entreprises/` comme CRM entreprise, `offres/` comme snapshots d’annonces, et `candidatures/<Entreprise>/<YYYY-MM-DD - Poste>/` comme historique canonique des candidatures envoyées avec leurs livrables (CV personnalisé, lettre, message, etc.).
