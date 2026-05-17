# Étude Comparative des Modèles de Langage (LLM) pour le Chatbot SAHTECH : Justification du Choix de Qwen 2.5 vs Llama 3.1

**Cadre de la recherche :** Validation du système IA - Chatbot Médical Multilingue
**Application :** Assistant virtuel pour le suivi patient et l'orientation médicale (Projet SAHTECH)

---

## 1. Problématique

L'intégration d'un chatbot au sein de l'écosystème SAHTECH nécessite un modèle capable de traiter des requêtes médicales complexes, principalement en **Arabe (Littéral et Dialectal)** et en Français. Les premiers tests effectués avec les modèles standards via Ollama (notamment Llama 3/3.1) ont révélé des lacunes significatives dans la génération de texte en arabe (syntaxe incorrecte, hallucinations, confusion sémantique). Cette étude compare la technologie actuelle avec l'alternative **Qwen 2.5 (Alibaba Cloud)** pour justifier un changement de moteur d'IA.

## 2. Modèles en Compétition

1.  **Llama 3.1 (Meta) via Ollama :** Le modèle open-source de référence. Excellentes performances en anglais et en raisonnement logique, mais historiquement moins performant sur les langues à script non-latin sans fine-tuning spécifique.
2.  **Qwen 2.5 (Alibaba Cloud) :** Modèle conçu nativement pour être multilingue. Il surpasse actuellement la majorité des modèles open-source sur les benchmarks non-anglais, particulièrement pour l'Arabe et le codage.
3.  **Gemma 2 (Google) :** Alternative intéressante pour sa légèreté (développée par Google), mais avec un support arabe souvent inférieur à Qwen dans les contextes conversationnels.

## 3. Analyse Comparative des Performances (Benchmarks Arabe)

Selon les données de l'**Open Arabic LLM Leaderboard (OALL)** et les rapports techniques de 2024-2025 :

| Métrique / Modèle | Llama 3.1 (8B) | **Qwen 2.5 (7B/14B)** | Gemma 2 (9B) |
| :--- | :--- | :--- | :--- |
| **Score Global Arabe (OALL)** | ~55-60% | **~72-78%** | ~58% |
| **Qualité de la Tokenisation** | Moyenne (Suboptimal pour l'Arabe) | **Excellente (Vocabulaire optimisé)** | Moyenne |
| **Raisonnement Médical (Ar)** | Risque d'hallucinations élevé | **Plus stable et précis** | Moyen |
| **Support du Dialecte (Tunisien/Maghrébin)** | Faible (Réponses en Arabe formel rigide) | **Meilleure compréhension des nuances** | Faible |
| **Latence (Local via Ollama)** | ~15-20 tokens/sec | **~18-25 tokens/sec (Plus léger)** | ~12 tokens/sec |

### Pourquoi Llama 3 "échoue" sur l'Arabe ?
- **Espace de Tokenisation :** Llama a été entraîné majoritairement sur des données anglaises. Pour l'arabe, il utilise plus de "tokens" par mot, ce qui fragmente le sens et augmente le risque d'erreurs grammaticales.
- **Biais Culturel :** Les données de RLHF (Reinforcement Learning from Human Feedback) sont très occidentalisées, ce qui rend le modèle moins pertinent pour des conseils de santé adaptés au contexte local (ex: expressions idiomatiques sur la douleur).

## 4. Justification Scientifique du Choix de Qwen 2.5

Le choix de **Qwen 2.5** pour SAHTECH se base sur trois piliers :

1.  **Architecture Multilingue Native :** Qwen utilise un vocabulaire de 151 000 tokens (contre 128 000 pour Llama), incluant une couverture massive du script arabe. Cela réduit la perte d'information lors du traitement des requêtes.
2.  **Performance sur le Raisonnement Complexe :** Sur les benchmarks MMLU (Massive Multitasking Language Understanding) adaptés à l'arabe, Qwen 2.5 dépasse Llama 3.1 de plus de 15 points en moyenne.
3.  **Optimisation "Edge AI" :** Tout comme MediaPipe pour le tracking biomécanique, Qwen 2.5 est optimisé pour tourner localement. La version 7B offre un rapport [Précision / Consommation RAM] idéal pour un serveur local ou un smartphone puissant.

## 5. Méthodologie de Validation Proposée

Pour valider ce choix de manière irréfutable (pour un mémoire ou un jury), nous recommandons une approche "Bimodale" :

### A. Validation par la Littérature (Articles)
- Citer les résultats du **Open Arabic LLM Leaderboard** (Hugging Face / OALL).
- Référencer le papier technique *"Qwen2.5 Technical Report"* montrant la supériorité en compréhension multilingue.

### B. Validation Empirique (Test Clinique "Gold Standard")
Créer un set de 10 questions critiques en Arabe (littéral et dialectal) et comparer les sorties :
1.  *Question :* "عندي وجيعة في ركبتي كي نطلع الدروج، شنوا نعمل؟"
2.  *Observation :* Noter si Llama répond à côté ou si la grammaire est brisée, versus la fluidité de Qwen.

## 6. Conclusion

L'utilisation de **Qwen 2.5 via Ollama** constitue la solution la plus robuste pour SAHTECH. Elle garantit une communication fluide avec les patients arabophones tout en maintenant une exécution locale sécurisée. Cette transition permet de passer d'un chatbot "expérimental" (Llama) à un système "cliniquement crédible" (Qwen).
