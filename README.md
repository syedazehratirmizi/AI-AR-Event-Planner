# 🎉 AI + AR Event Decoration App  

An innovative **Flutter-based mobile application** that combines **Artificial Intelligence (AI)** and **Augmented Reality (AR)** to revolutionize event planning. With this app, users can **describe decorations in natural language, generate realistic 3D models, preview them in AR**, and even **connect with vendors nearby**.  

---

## 🚀 Overview  

Planning events like **weddings, birthdays, and corporate parties** is exciting — but visualizing the decoration before the actual setup is always a challenge.  

This project solves that problem by:  
- Allowing users to **imagine and describe** their decoration ideas.  
- Using **AI (Shape-E fine-tuned)** to generate **realistic 3D event decor models**.  
- Offering **AR visualization** to preview decorations in real venues.  
- Providing a **vendor discovery system** to connect with decorators near the user’s location.  

The result is a **seamless all-in-one platform** for inspiration, visualization, and execution of dream events.  

---

## ✨ Features  

✅ **User Login & Home Screen**  
- Secure login system.  
- Home screen with **predefined templates** of decorations.  
- Add/remove favorites for quick access.  

✅ **AI Chatbot for Decorations**  
- Chatbot where users type natural language descriptions.  
- Example: *“Royal wedding stage with golden drapes and flowers.”*  
- AI backend generates a **3D model** matching the description.  

✅ **AR Visualization**  
- View the generated 3D model in **real-world surroundings** using AR.  
- Fit decorations onto walls, floors, or stages.  

✅ **Vendor Discovery**  
- Ask for **location permission**.  
- Filter vendors by category (*Wedding*, *Birthday*, *Corporate*).  
- Show nearby vendors with details on a map.  

✅ **Favorites System**  
- Save predefined templates for later inspiration.  
- Add/remove anytime.  

---

## 🛠️ Tech Stack  

### **Frontend (Flutter App)**  
- Flutter & Dart  
- Firebase Authentication (for login)  
- AR support via `ar_flutter_plugin`  
- REST API integration for AI models  

### **Backend (AI & Vendors)**  
- **AI Model**: Shape-E (fine-tuned on event decoration dataset: images + text)  
- **Dataset**: Custom event decoration dataset (weddings, birthdays, corporate events)  
- **Framework**: Gradio API  
- **Hosting**: Hugging Face Spaces  
- **Vendor Data**: Firebase Firestore + Location API  

---

## 🏗️ System Architecture  

```mermaid
flowchart TD
    A[User] -->|Login + Request| B[Flutter App]
    B -->|Fetch Templates + Vendors| C[Firebase Backend]
    B -->|Decoration Prompt| D[Gradio API - Hugging Face]



    D -->|3D Model Generation| E[Shape-E Model]
    B -->|AR Preview| F[AR Engine]
