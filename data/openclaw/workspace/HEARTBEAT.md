# HEARTBEAT.md — Vérifications quotidiennes

## Automatisation recherche d'emploi — Standup quotidien (9h en semaine)

**Avant tout :**
1. Récupérer les dernières modifications du dépôt drobsidian : `cd /home/node/.openclaw/workspace/drobsidian && git pull origin main`
2. Vérifier les éventuelles modifications locales effectuées

**Vérification 1 : Entreprises nécessitant une relance**
- Scanner /home/node/.openclaw/workspace/drobsidian/entreprises/*.md pour les entreprises où :
  - `Date relance J+3` est renseignée mais `Date relance 1 effective` est vide ET la date est aujourd'hui ou passée
  - `Date relance J+7` est renseignée mais `Date relance 2 effective` est vide ET la date est aujourd'hui ou passée
- Alerter l'utilisateur : "Relance due pour [Entreprise]"

**Vérification 2 : Trouver une nouvelle entreprise à auditer**
- Sauf si Aymerick est en vacances : dans ce cas, ne pas proposer ni auditer de nouvelle entreprise pendant toute la période indiquée.
- Hors vacances uniquement : identifier 1+ nouvelle entreprise tech française — préférence pour les entreprises produit (50-150 employés, backend Python, hors ESN/consulting), mais considérer les autres si elles présentent des atouts significatifs
- Réaliser un audit factuel complet
- Créer /home/node/.openclaw/workspace/drobsidian/entreprises/NouvelleEntreprise.md avec la structure complète
- Enregistrer les dates de relance théoriques dans le frontmatter :
  - `Date relance J+3: [aujourd'hui + 3 jours]`
  - `Date relance J+7: [aujourd'hui + 7 jours]`
- Pousser sur GitHub

**À transmettre à l'utilisateur :**
- Résumé du ou des audits réalisés
- Liste des entreprises dues pour une relance
- Envoyer via Telegram au 8655385911

**Important :**
- Pas de spéculation, faits uniquement
- Pull avant de travailler, push après
- Vérifier les modifications locales sur les entreprises

## Suivi Summer body

**Chaque lundi :** Inclure dans le message de kickoff un rappel du planning running de la semaine (lundi-vendredi 7h, progression naturelle depuis 2km).

**Toutes les 3 semaines :** Rappeler de faire le point sur la balance (objectif : 80kg → 70kg, ou 75kg si masse musculaire).
