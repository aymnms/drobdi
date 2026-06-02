# AUDIT OUTSIGHT — Étape 3

## RÉSUMÉ EXÉCUTIF
**Outsight** est une startup deep-tech française (Paris/Sophia-Antipolis) spécialisée dans la **Spatial Intelligence via LiDAR**. Positionnement: **B2B Infrastructure**, pas une simple app SaaS. Clients: aéroports majeurs (CDG Paris, Dallas DFW, Rome), gares (SNCF), venues sportives.

---

## 1. PROFIL ENTREPRISE

| Item | Détail |
|------|--------|
| **Fondation** | 2019 |
| **Localisation** | Paris (HQ), Sophia-Antipolis (R&D), San Francisco (business) |
| **Taille** | 114-119 employés (scale-up confirmée) |
| **Financement** | €40-41M levés (Series A + Series B 2022) |
| **Statut** | Rentable, clients majeurs, en expansion |

---

## 2. PRODUIT & STACK TECHNIQUE

### Core Product
- **Shift Perception**: Détection/classification/tracking d'objets en 3D temps réel
- **Shift Analytics**: Monitoring comportement, alertes custom, analytics historiques
- Utilise: **LiDAR sensors** (multi-vendor: Ouster, Sick, etc.) + software propriétaire

### Stack Confirmé
- **Backend**: Python 100% (Flask, APIs REST)
- **Frontend**: Vue.js 3 + Vuetify + Pinia
- **DevOps**: AWS, Docker, Terraform, Pulumi, CircleCI
- **Données**: Traitement 3D temps réel, géométrie, computer vision
- **Infra**: Déploiements décentralisés (capteurs sur site) + cloud hybride

### Problèmes Techniques Identifiés

**Signal #1 — Real-Time Processing Under Load:**
- Use cases: aéroports à 100k+ passagers/jour
- Besoin: traiter N streams LiDAR en temps réel (1000s d'objets tracked simultanément)
- Défi: latence < 200ms pour queue detection, scalabilité horizontale

**Signal #2 — Multi-Vendor Sensor Integration:**
- Clients demandent: fonctionner avec *tous* les LiDAR vendors (Ouster, Sick, Sick, etc.)
- Problème: chaque vendor a format différent, calibration différente
- Impact: code backend complexe pour normalisation + transformation

**Signal #3 — Distributed System Resilience:**
- Clients: infrastructures critiques (aéroports, gares)
- Besoin: Zero downtime, auto-healing, failover automatique
- Défis: 100s de capteurs décentralisés, sync en temps réel, logging centralisé

---

## 3. SIGNAUX D'OPPORTUNITÉ

### Expansion Confirmée
- ✅ **US Expansion 2026**: Dallas, Houston, Atlanta (annoncés)
- ✅ **New Verticals**: Retail (partenariat E23), Rail (SNCF), Smart Cities
- ✅ **Product Growth**: Shift Analytics (nouveau produit 2025)

### Levée de Fonds
- **Series B (2022)**: €22M levée
- Investisseurs: BpiFrance, Energy Innovation Capital, Groupe ADP, SPDG, Safran, Demeter
- Signal: confiance institutionnelle forte, capital pour scaling

### Clients Prestigieux
- **Aéroports**: CDG Paris (partenaire stratégique), Dallas DFW, Rome Fiumicino
- **Infrastructure**: SNCF Gares & Connexions, Embotech, Macq Mobility
- **Corporates**: Groupe ADP (actionnaire + client)

---

## 4. ORGANISATION ENGINEERING

### Leadership Technique
- **Bertrand Muquet** — VP Engineering (Nice/Sophia-Antipolis)
  - Responsable: toute l'architecture technique, scaling, hiring
  - Profil: long track record infra/devops (ex: Sequans)
  
- **Sébastien Boutet** — Software Director (Nice)
  - Responsable: real-time processing, computer vision, algos
  - Spécialité: systèmes temps réel complexes

### Team Size
- ~13 engineers dans la squad Data & Integrations
- **Hiring actif**: CDI Fullstack Engineer ouvert (confirmé récent)

---

## 5. PROBLÈMES BACKEND DIAGNOSTIQUÉS

### Défi #1: Real-Time Guarantees
**Symptôme observé**: Use cases exigent latence < 200ms end-to-end (capteur → décision → client)
- Piloter N streams LiDAR en parallèle
- Synchroniser multi-capteurs
- Garantir ordering + déduplication d'objets tracés

**Techniquement**: Demande architectures async robustes (queues, event streaming, possibly Kafka/Redis)

### Défi #2: Scalability Horizontale
**Symptôme observé**: Expansion US = 10x plus de déploiements, 100s de capteurs, variations réseau
- Load balancing complexe pour capteurs distribués
- Gestion dynamique de ressources
- Monitoring centralisé (surtout pour debugging distant)

**Techniquement**: DevOps sophistiqué (Terraform Pulumi, monitoring observability)

### Défi #3: Multi-Vendor Integration
**Symptôme observé**: Clients exigent "marche avec tous les LiDAR"
- Abstraction vendor-agnostic pour capteur API
- Normalisation données hétérogènes
- Testing cross-vendor complexe

**Techniquement**: Design patterns robustes (adapters, contracts), test e2e automation

---

## 6. SIGNAUX DE CROISSANCE POUR TA CANDIDATURE

### Timely Signals
1. **US Expansion** → Besoin architectural pour déploiements décentralisés ✅
2. **Hiring actif Data & Integrations** → Ils recrutent NOW, pas "peut-être"
3. **Product scaling** → De "ça marche en France" à "ça marche partout"
4. **Infra as bottleneck** → Bertrand (VP Eng) cherche probablement renfort backend

### Why They Need Someone Like You
- **Ton profil**: Backend Python + async (SQS/AWS) + QA automation
- **Leur besoin**: Fiabiliser pipelines temps réel à travers 100s de déploiements
- **Match**: QA mindset ("qu'est-ce qui peut casser en prod?") sur systèmes distribués critiques

---

## 7. SCORING FINAL

| Critère | Score | Justif |
|---------|-------|--------|
| **Probabilité de réponse** | 3/3 | PME française, VP Eng visible, recrutement ouvert |
| **Alignement profil** | 3/3 | Python ✅, async ✅, scalability thinking ✅, QA mindset ✅ |
| **Accessibilité** | 3/3 | Bertrand/Sébastien identifiés, actifs publiquement, équipe "approachable" |
| **Moment** | 3/3 | Expansion US + hiring = besoin backend NOW |
| **Impact potentiel** | 3/3 | Travail technique impactant (millions d'objets tracked, aéroports majeurs) |

**TOTAL: 15/15** ✅ **SUPER QUALIFIÉE**

---

## 8. STRATÉGIE D'APPROCHE

### Angle #1: Real-Time Reliability (Pour Bertrand - VP Eng)
Focus: "votre expansion US nécessite fiabilité sous charge en multi-deployment"
- Problème identifié: pipelines temps réel avec 100s de capteurs décentralisés
- Angle tech: "comment garantir latence < 200ms quand les capteurs sont partout?"

### Angle #2: Scaling Pains (Pour Sébastien - Software Director)
Focus: "vous avez 13 engineers, 100s de capteurs, vos systèmes doivent être bulletproof"
- Problème identifié: intégration multi-vendor LiDAR complexe
- Angle tech: "comment simplifier integration et testing quand chaque client a setup unique?"

### Message Clé
Tu arrives avec:
1. **Experience async systems** (SQS/AWS) → applicable à streaming LiDAR
2. **QA automation mindset** → crucial pour systèmes critiques (aéroports)
3. **No bullshit approach** → idéal pour scale-up technique

---

## PROCHAINES ÉTAPES
**Étape 4**: Rédaction messages personnalisés
- Message connexion LinkedIn (200 char)
- Message long (si acceptation) — adapté au niveau (Bertrand vs Sébastien)

