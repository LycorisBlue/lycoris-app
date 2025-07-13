# MyLife Dashboard

Application mobile Flutter de productivité personnelle avec interface monochrome (noir/blanc).

## 📱 Fonctionnalités

- **Gestion des objectifs** : Création et suivi d'objectifs SMART
- **Gestion des projets et tâches** : Organisation avec suivi temporel
- **Suivi d'habitudes** : Bonnes et mauvaises habitudes
- **Journal quotidien** : Bilan quotidien et résumé hebdomadaire
- **Prise de notes** : Notes organisées avec recherche
- **Rappels** : Système de notifications personnalisées
- **Outils** : Flip Clock et minuteur/Pomodoro

## 🏗️ Architecture du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── core/                     # Éléments transversaux
│   ├── constants/           # Constantes de l'application
│   │   ├── app_colors.dart  # Palette de couleurs monochrome
│   │   └── app_sizes.dart   # Tailles responsives
│   └── theme/               # Thème de l'application
│       └── app_theme.dart   # Configuration du thème sombre
├── data/                    # Accès aux données
├── domain/                  # Logique métier pure
└── presentation/            # Interface utilisateur
    ├── screens/            # Écrans de l'application
    └── widgets/            # Composants réutilisables
```

## 📂 Rôle des dossiers

### **core/** - Éléments fondamentaux
- **Constantes** : Valeurs fixes utilisées dans toute l'app
- **Thème** : Configuration visuelle globale
- **Utils** : Fonctions utilitaires (à venir)

### **data/** - Gestion des données
- **Models** : Représentation des données (JSON ↔ Objets)
- **Repositories** : Implémentation concrète de l'accès aux données
- **Services** : Services externes (API, base de données)

### **domain/** - Logique métier
- **Entities** : Définition des objets métier (Goal, Project, Task...)
- **Repositories** : Contrats d'accès aux données (interfaces)
- **Use Cases** : Règles métier et cas d'utilisation

### **presentation/** - Interface utilisateur
- **Screens** : Écrans complets de l'application
- **Widgets** : Composants UI réutilisables

## 🎨 Configuration visuelle

### **app_colors.dart** - Palette monochrome
```dart
// Fonds
AppColors.background        // #000000 - Fond principal
AppColors.cardBackground    // #111111 - Fond des cartes
AppColors.dialogBackground  // #1A1A1A - Fond des modales

// Textes
AppColors.textPrimary      // #FFFFFF - Texte principal
AppColors.textSecondary    // #CCCCCC - Sous-titres
AppColors.textTertiary     // #999999 - Métadonnées

// Éléments
AppColors.border           // #333333 - Bordures et séparateurs
AppColors.hover            // #1AFFFFFF - État survol (10% blanc)
AppColors.shadow           // #80000000 - Ombres
```

### **app_sizes.dart** - Tailles responsives
```dart
// Espacement
AppSizes.padding          // 16.w - Espacement standard
AppSizes.margin           // 16.w - Marges standard

// Composants
AppSizes.buttonHeight     // 48.h - Hauteur des boutons
AppSizes.borderRadius     // 8.r - Rayon des bordures

// Typographie
AppSizes.textSmall        // 14.sp - Texte petit
AppSizes.textMedium       // 16.sp - Texte normal
AppSizes.textLarge        // 18.sp - Texte important
AppSizes.textTitle        // 24.sp - Titres
```

### **app_theme.dart** - Thème global
Configuration complète du thème sombre :
- **AppBar** : Transparent avec texte blanc
- **Cards** : Fond noir charbon avec bordures arrondies
- **Boutons** : Style uniforme avec hauteur standard
- **Texte** : Hiérarchie typographique en niveaux de gris
- **Dividers** : Séparateurs subtils

## 📱 Navigation

L'application utilise un **Drawer** (menu latéral) au lieu d'une bottom navigation pour accéder aux différentes sections :

- Dashboard (Accueil)
- Objectifs
- Projets
- Tâches
- Habitudes
- Journal
- Notes
- Rappels
- Outils (Flip Clock, Minuteur)
- Paramètres

## 🛠️ Technologies

- **Flutter** 3.x
- **flutter_riverpod** : Gestion d'état et injection de dépendances
- **google_fonts** : Police Inter pour une typographie moderne
- **Thème sombre** : Interface monochrome
- **Architecture Clean** : Séparation des responsabilités

## 🏗️ Gestion d'état avec Riverpod

### ⚠️ **Règle d'or : NE PAS utiliser Riverpod partout !**

Riverpod n'est **PAS** nécessaire dans toutes les couches. Voici quand l'utiliser :

### **Domain** ❌ : JAMAIS de Riverpod
```dart
// ✅ CORRECT - Logique métier pure
abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();
}

class Goal {
  final String title;
  final DateTime deadline;
  // Entités pures sans dépendances
}

// ❌ INCORRECT - Ne pas polluer le domain
// class Goal extends ConsumerWidget // NON !
```

**Pourquoi ?** Le domain doit rester testable et réutilisable sans Flutter.

### **Data** ✅ : Riverpod minimal (injection uniquement)
```dart
// ✅ CORRECT - Juste pour fournir les implémentations
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl();
});

// ❌ INCORRECT - Pas de logique métier complexe ici
```

**Usage :** Uniquement pour l'injection de dépendances, pas pour la logique.

### **Presentation** ✅ : Riverpod complet
```dart
// ✅ CORRECT - Gestion complète de l'état UI
final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier(ref.read(goalRepositoryProvider));
});

class GoalsScreen extends ConsumerWidget {
  // Toute la logique UI et état ici
}
```

**Usage :** État des widgets, navigation, interactions utilisateur.

### 📋 **Quand utiliser Riverpod :**

✅ **État partagé** entre plusieurs widgets
✅ **Données asynchrones** (API calls, base de données)
✅ **Injection de dépendances** (repositories, services)
✅ **État complexe** qui nécessite une logique métier
✅ **Cache et performance** (éviter les rebuilds inutiles)

### ❌ **Quand NE PAS utiliser Riverpod :**

❌ **État local simple** (TextField, Switch isolé)
❌ **Widgets statiques** sans logique
❌ **Entités pures** (models, DTOs)
❌ **Utils et helpers** (fonctions pures)
❌ **Sur-architecture** pour des fonctionnalités simples

### 💡 **Exemples concrets :**

```dart
// ❌ Overkill - Pas besoin de Riverpod
class SimpleCounter extends StatefulWidget {
  // Un simple counter local = setState suffit
}

// ✅ Justified - Riverpod approprié
class TimerScreen extends ConsumerWidget {
  // Timer partagé entre plusieurs écrans
  // État complexe avec logique métier
  // Sauvegarde en base de données
}
```

### 🎯 **Architecture recommandée :**

```
lib/
├── domain/              # ❌ PAS de Riverpod
│   ├── entities/        # Objets métier purs
│   └── repositories/    # Interfaces abstraites
├── data/               # ✅ Riverpod MINIMAL
│   └── providers/      # Injection de dépendances uniquement
└── presentation/       # ✅ Riverpod COMPLET
    ├── providers/      # État UI et logique applicative
    ├── screens/        # ConsumerWidget
    └── widgets/        # Consumer quand nécessaire
```

## 🚀 Installation

1. Cloner le projet
```bash
git clone [URL_DU_REPO]
cd mylife_dashboard
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Lancer l'application
```bash
flutter run
```

## 📋 Développement

### Ajouter un Provider Riverpod
**⚠️ Réfléchir d'abord : Est-ce vraiment nécessaire ?**

1. **État local simple** → Utilisez `StatefulWidget`
2. **État partagé/complexe** → Créez un provider dans `presentation/providers/`
3. **Injection de service** → Créez un provider dans `data/providers/`

```dart
// Exemple provider approprié
final goalsProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier(ref.read(goalRepositoryProvider));
});
```

### Ajouter une nouvelle couleur
1. Ajouter la constante dans `app_colors.dart`
2. Documenter son usage en commentaire
3. L'utiliser via `AppColors.nouvelleCouleur`

### Ajouter une nouvelle taille
1. Ajouter la constante dans `app_sizes.dart`
2. Utiliser l'unité appropriée (.w, .h, .sp, .r)
3. L'utiliser via `AppSizes.nouvelleTaille`

### Créer un nouvel écran
1. Créer le fichier dans `presentation/screens/`
2. Utiliser le thème via `Theme.of(context)`
3. Appliquer les tailles via `AppSizes`
4. Ajouter la navigation dans le drawer

## 🔄 Logique de commit

### Convention des messages de commit
```
<type>(<scope>): <description>

[corps optionnel]

[footer optionnel]
```

### Types de commit
- **feat** : Nouvelle fonctionnalité
- **fix** : Correction de bug
- **docs** : Documentation
- **style** : Formatage, point-virgules manquants, etc.
- **refactor** : Refactoring de code
- **test** : Ajout ou modification de tests
- **chore** : Tâches de maintenance

### Scopes principaux
- **core** : Éléments transversaux (theme, constants)
- **ui** : Interface utilisateur (screens, widgets)
- **data** : Gestion des données
- **domain** : Logique métier
- **config** : Configuration du projet

### Exemples de commits
```bash
# Nouvelle fonctionnalité
feat(ui): add goals screen with list and creation form

# Correction de bug
fix(core): resolve theme colors not applying correctly

# Documentation
docs: update README with installation instructions

# Style/formatage
style(ui): format code and fix indentation in dashboard

# Refactoring
refactor(domain): extract goal validation logic to use case

# Configuration
chore(config): update dependencies and add new packages

# Architecture
feat(core): implement responsive design with screenutil
```

### Workflow de développement
```bash
# 1. Créer une nouvelle branche pour chaque fonctionnalité
git checkout -b feat/goals-management

# 2. Faire des commits atomiques et descriptifs
git add .
git commit -m "feat(domain): add goal entity and repository interface"
git commit -m "feat(ui): create goals screen with basic layout"
git commit -m "feat(ui): implement goal creation form"

# 3. Pousser la branche
git push origin feat/goals-management

# 4. Fusionner dans main après validation
git checkout main
git merge feat/goals-management
git branch -d feat/goals-management
```

### Règles de commit
- **Messages en anglais** pour la cohérence
- **Description claire** de ce qui a été fait
- **Un commit = une modification logique**
- **Tester avant de commit**

## 🎯 Philosophie du design

- **Monochrome** : Uniquement noir, blanc et nuances de gris
- **Minimalisme** : Interface épurée sans distraction
- **Lisibilité** : Contraste maximal pour une lecture optimale
- **Cohérence** : Design system uniforme dans toute l'app
- **Focus** : L'attention sur le contenu, pas sur l'interface