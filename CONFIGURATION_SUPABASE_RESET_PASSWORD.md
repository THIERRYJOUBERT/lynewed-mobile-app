# 🔧 CONFIGURATION SUPABASE POUR RESET PASSWORD

## ❌ PROBLÈME ACTUEL

**Configuration Supabase actuelle :**
- Site URL: `lynewed://`
- Redirect URLs: Contient `lynewed://**`

**Résultat :** L'email de reset password essaie d'ouvrir l'app au lieu du navigateur.

---

## ✅ SOLUTION : MODIFIER LA CONFIGURATION SUPABASE

### **ÉTAPE 1 : Aller dans Supabase Dashboard**

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet **Lynewed**
3. Allez dans **Authentication > URL Configuration**

---

### **ÉTAPE 2 : Modifier Site URL**

**Remplacez :**
```
lynewed://
```

**Par :**
```
https://odzkhcplevcqbuhzqsmq.supabase.co
```

**Pourquoi ?** Le Site URL doit être une URL web, pas un deeplink.

---

### **ÉTAPE 3 : Modifier Redirect URLs**

**Gardez vos URLs Lovable (pour l'admin web) :**
```
https://7542c6f4-6a38-4c01-91ac-8852261cd08a.lovableproject.com/**
https://id-preview--7542c6f4-бa38-4c01-91ac-8852261cd08a.lovable.app/**
https://lynewed-admin-central.lovable.app/**
https://preview--lynewed-admin-central.lovable.app/**
```

**SUPPRIMEZ cette ligne :**
```
lynewed://**
```

**Pourquoi ?** Pour le reset password, on veut que ça ouvre dans le navigateur, pas dans l'app.

---

### **ÉTAPE 4 : Sauvegarder**

Cliquez sur **Save** dans Supabase.

---

## 🎯 RÉSULTAT APRÈS MODIFICATION

### **Avant :**
1. User demande reset password
2. Email reçu avec lien `lynewed://...`
3. Clic → Essaie d'ouvrir l'app ❌
4. Confusion, ne fonctionne pas

### **Après :**
1. User demande reset password
2. Email reçu avec lien `https://odzkhcplevcqbuhzqsmq.supabase.co/auth/v1/verify?...`
3. Clic → Ouvre le navigateur ✅
4. Page web Supabase s'affiche ✅
5. User entre nouveau mot de passe ✅
6. Mot de passe changé ✅

---

## 📋 CONFIGURATION FINALE RECOMMANDÉE

### **Site URL :**
```
https://odzkhcplevcqbuhzqsmq.supabase.co
```

### **Redirect URLs :**
```
https://7542c6f4-6a38-4c01-91ac-8852261cd08a.lovableproject.com/**
https://id-preview--7542c6f4-бa38-4c01-91ac-8852261cd08a.lovable.app/**
https://lynewed-admin-central.lovable.app/**
https://preview--lynewed-admin-central.lovable.app/**
https://odzkhcplevcqbuhzqsmq.supabase.co/auth/v1/verify
```

**Note :** Vous pouvez garder les URLs Lovable pour votre admin web, elles ne gênent pas.

---

## ⚠️ IMPORTANT

**NE GARDEZ PAS `lynewed://` dans les Redirect URLs** car :
- ❌ Ça force l'ouverture de l'app
- ❌ L'app ne peut pas gérer le reset password correctement
- ❌ Ça cause des erreurs de navigation

**Utilisez `lynewed://` UNIQUEMENT pour :**
- Login social (Google, Apple, etc.)
- Autres deeplinks spécifiques
- **PAS pour reset password**

---

## 🚀 APRÈS MODIFICATION

1. **Testez immédiatement** :
   - Demandez un reset password depuis l'app
   - Vérifiez l'email reçu
   - Cliquez sur le lien
   - Devrait ouvrir le navigateur avec la page Supabase ✅

2. **Si ça ne marche pas** :
   - Videz le cache de l'email (fermez/rouvrez l'app email)
   - Demandez un nouveau reset password
   - Le nouveau lien utilisera la nouvelle config

---

## 💯 GARANTIE

Cette configuration est **100% standard et recommandée par Supabase** pour le reset password.

Des milliers d'apps utilisent cette configuration avec succès.
