# Smart Study Advisor

A cross-platform application designed to assist Alexandria University CSE students in navigating their academic curriculum. The system provides real-time course eligibility tracking and features an intelligent, context-aware AI academic assistant.

## 🚀 Features

* **Dynamic Course Tracking:** A real-time checklist and filtering system. Students can track their overall progress (e.g., 18/45 courses completed) and filter available courses by category or difficulty.
* **Context-Aware AI Guidance:** A conversational interface powered by Llama 3. The AI gives personalized study advice and next-course recommendations based on the student's actual completed courses, ensuring it never suggests a course the student has already passed.
* **Strict Prerequisite Validation:** Hard-coded academic rules ensure 100% accuracy for course eligibility without relying on AI guesswork.

## 🧠 System Architecture & Paradigms

This project uses a decoupled client-server architecture, deliberately integrating different programming paradigms where they naturally fit best:

* **Logic Programming (Prolog):** Acts as the strict "judge." It evaluates the university's hard-coded rules and prerequisite logic to guarantee accurate course eligibility.
* **Functional Programming (Python):** Handles data transformation safely. We use functions like `map` and `filter` to clean and format the raw output from Prolog into structured data for the frontend without causing side effects.
* **Object-Oriented & Imperative (Django/Python):** Structures the backend. Modeling components as objects (like "Course" or "Student") keeps the code organized, while imperative flows manage the RESTful API execution between the database and the logic engine.
* **Generative AI (Llama 3 via Groq):** Acts as the "translator" for the user experience. It takes the rigid data processed by the backend and explains it to the student in a natural, friendly chat.

## ⚙️ How It Works (The AI Context Bundle)

When a student asks the AI for advice, the system does not just send a raw prompt. 
1. The Django backend retrieves the student's list of completed courses.
2. It injects this data into the system instructions as a **Context Bundle**.
3. This strict data is sent to the Llama 3 model.
4. The AI uses this context to provide highly accurate, personalized advice (e.g., recognizing a strong math foundation and suggesting a specific programming course next).

## 🛠️ Tech Stack

* **Frontend:** Flutter
* **Backend:** Django (Python)
* **Logic Engine:** SWI-Prolog
* **AI Integration:** Groq API (Llama 3)
