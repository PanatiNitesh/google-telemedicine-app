# Telemedicine App for Underserved Communities

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/PanatiNitesh/google-telemedicine-app/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10.0-blue)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange)](https://firebase.google.com/)
[![Google Cloud](https://img.shields.io/badge/Google%20Cloud-AI%20Services-green)](https://cloud.google.com/)

## Table of Contents
- [Project Overview](#project-overview)
- [Problem Statement](#problem-statement)
- [Solution](#solution)
- [Key Features](#key-features)
- [Unique Selling Proposition](#unique-selling-proposition)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [User Flow](#user-flow)
- [Implementation](#implementation)
- [Screenshots](#screenshots)
- [Future Development](#future-development)
- [Cost Analysis](#cost-analysis)
- [Project Links](#project-links)
- [Team](#team)
- [Contributors](#contributors)
- [License](#license)

## Project Overview
Telemedicine App is a comprehensive mobile-based healthcare solution designed by Team Dockerize to address the critical challenge of healthcare accessibility in underserved communities. This application bridges the gap between medical professionals and patients in remote areas through virtual consultations enhanced with AI capabilities.

## Problem Statement
**Lack of Access to Healthcare in Underserved Communities**

Many communities worldwide face significant barriers to healthcare access due to:
- Geographic isolation from medical facilities
- Financial constraints limiting affordability
- Language barriers between patients and healthcare providers
- Limited awareness about preventive healthcare measures

## Solution
Our telemedicine application delivers a multi-faceted approach to healthcare accessibility through:

1. **Virtual Consultations**: Connecting patients with doctors remotely, eliminating geographical barriers
2. **AI-Assisted Healthcare**: Providing preliminary health guidance through an intelligent chatbot
3. **Real-Time Language Translation**: Breaking communication barriers during consultations
4. **Cost-Effective Options**: Helping users find affordable medication and diagnostic services

## Key Features

### 1. AI-Powered Virtual Consultation
- Real-time AI voice translation for doctor-patient interaction in any language
- Secure video consultations with qualified medical professionals
- Appointment scheduling and follow-up management

### 2. AI Level-1 Health Assistant
- Preliminary symptom assessment and basic health guidance
- Personalized health recommendations based on user history
- Powered by Google Vertex AI (Gemini) for intelligent interactions

### 3. Daily Healthcare Notifications
- Two health alerts daily delivered in local languages and dialects
- Educational content covering disease prevention, hygiene practices, and wellness tips
- Customizable notification preferences based on user health profile

### 4. Lab & Medicine Price Comparison
- Aggregated pricing from multiple pharmaceutical platforms (Tata 1mg, Apollo, Netmeds)
- Side-by-side comparison for cost-effective healthcare decisions
- Direct ordering capabilities through integrated partners

## Unique Selling Proposition

- **AI-Driven Real-Time Voice Translation**: Eliminating language barriers during consultations
- **Intelligent Health Assistant**: Providing immediate preliminary guidance before doctor consultation
- **Localized Health Communications**: Delivering preventive healthcare information in native languages
- **Price Transparency**: Enabling informed financial decisions for medication and diagnostics

## Technology Stack

### User Platform (Mobile Application)
- **Framework**: Flutter + Dart for cross-platform development
- **Authentication & Storage**: Firebase Authentication, Cloud Storage
- **Video Consultation**: Google WebRTC
- **AI Translation**: Google Cloud AI (Gemini API, Natural Language Processing)
- **Data Integration**: REST APIs for pharmaceutical and diagnostic services

### Doctor Platform (Web Application)
- **Frontend**: React.js with TailwindCSS
- **Backend**: Node.js with Express.js
- **Database**: MongoDB for patient records and consultation history
- **Video Interface**: Google WebRTC integration

## Architecture

Our telemedicine application follows a microservices architecture designed for scalability, reliability, and maintainability.

<div align="center">
  <img src="https://github.com/user-attachments/assets/67cef206-e4aa-4a1c-9fcc-3d87752552e0" alt="Architecture Diagram" width="600px">
  <p><i>System Architecture Diagram showing the interaction between various services</i></p>
</div>


The architecture consists of several key components:

1. **Client Applications**
   - Mobile application (Flutter) for patients
   - Web interface (React.js) for healthcare providers

2. **API Gateway**
   - Routes requests to appropriate microservices
   - Handles authentication and authorization

3. **Core Microservices**
   - User Management: Patient and doctor profiles
   - Appointment Service: Scheduling and management
   - Consultation Service: Video interactions and session management
   - Notification Service: Health alerts and reminders

4. **AI Services**
   - Translation Engine: Real-time language processing
   - Health Assistant: Preliminary assessment and guidance

5. **Data Services**
   - Medical Records: Patient history and documentation
   - Analytics: Usage patterns and health insights

6. **External Integrations**
   - Pharmacy APIs: Medication pricing and availability
   - Laboratory APIs: Diagnostic test information and booking

## User Flow

The application is designed with intuitive user flows for both patients and healthcare providers.

<div align="center">
  <img src="https://github.com/user-attachments/assets/5ec195a3-b1bf-49df-85fb-35185b38e28b" alt="User Flow Diagram"  width="250px">
  <p><i>User Flow Diagram depicting the patient journey through the application</i></p>
</div>

### Patient Journey

1. **Registration & Onboarding**
   - Create account with basic details
   - Complete health profile
   - Set language preferences

2. **Seeking Healthcare**
   - Use AI health assistant for preliminary guidance
   - Schedule appointment with appropriate specialist
   - Receive confirmation and reminders

3. **Consultation Experience**
   - Join video consultation with real-time translation
   - Receive digital prescription and follow-up plan
   - Rate and review the consultation

4. **Post-Consultation**
   - Compare medication prices across platforms
   - Schedule follow-up appointments
   - Access health records and recommendations

### Doctor Journey

1. **Registration & Verification**
   - Create professional profile
   - Submit credentials for verification
   - Set availability schedule

2. **Patient Management**
   - Review upcoming appointments
   - Access patient history and records
   - Conduct video consultations

3. **Treatment & Follow-up**
   - Issue digital prescriptions
   - Schedule follow-up consultations
   - Monitor patient progress

## Implementation

The implementation follows these key steps:

1. User registration and profile creation
2. Health history documentation
3. Appointment scheduling with appropriate specialists
4. Video consultation with real-time translation
5. Post-consultation prescription and follow-up planning
6. Medication procurement through price comparison

## Screenshots

<div align="center">
  <img src="https://github.com/user-attachments/assets/02de9e78-9d19-43f9-9bd2-77d94f6918d0" alt="App Screenshot 1" width="250px">
  <img src="https://github.com/user-attachments/assets/562f7f52-d9ce-4c77-922e-9aaa98bb201b" alt="App Screenshot 2" width="250px">
  <img src="https://github.com/user-attachments/assets/35686c1b-89c1-413d-ae24-5ed77f5e51cb" alt="App Screenshot 3" width="250px">
</div>

## Future Development

Our roadmap includes several enhancements to further improve healthcare accessibility:

1. **Advanced AI Health Diagnostics**: Expanding the AI assistant to provide more comprehensive preliminary health assessments
2. **Offline Functionality**: Enabling limited functionality without internet connectivity for extremely remote areas
3. **Blockchain Medical Records**: Implementing secure, tamper-proof patient records management
4. **Government & NGO Partnerships**: Collaborating with public health initiatives to expand reach and secure funding

## Cost Analysis

| Component | Estimated Monthly Cost |
|-----------|------------------------|
| Cloud Hosting (Google Cloud) | ₹3,000 – ₹5,000 |
| Database (MongoDB Atlas / Firebase Firestore) | ₹1,500 – ₹3,000 |
| Live Video Translation API | ₹5,000 – ₹10,000 |
| SMS & Notification API | ₹1,000 – ₹2,000 |
| Payment Gateway | Transaction-based |
| App Maintenance & Security | ₹2,000 – ₹4,000 |
| **Total Estimated Cost** | **₹12,500 – ₹24,000 per month** |

## Project Links

- **GitHub Repository**: [https://github.com/PanatiNitesh/google-telemedicine-app](https://github.com/PanatiNitesh/google-telemedicine-app)
- **Demo Video**: [Link to Demo Video]()
- **MVP Demo**: [https://drive.google.com/drive/folders/1tXWnGCqZgLyW3zSc8mcb70zA7Ocxgf2Q](https://drive.google.com/drive/folders/1tXWnGCqZgLyW3zSc8mcb70zA7Ocxgf2Q)
- **UI Design (Figma)**: [https://www.figma.com/design/pa4CDuDENlb8GTf3U6GYay/Telemedicine-app?node-id=513-230&t=Aib5dXJiTgEPadRf-1](https://www.figma.com/design/pa4CDuDENlb8GTf3U6GYay/Telemedicine-app?node-id=513-230&t=Aib5dXJiTgEPadRf-1)
- **User Flow & Architecture**: [https://app.eraser.io/workspace/OSQ73C09McBXQQCUY7WV?origin=share](https://app.eraser.io/workspace/OSQ73C09McBXQQCUY7WV?origin=share)

## Contributors

<table>
  <tr>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/u/149950829?v=4" width="100px" height="100px" style="border-radius:50%;"/>
      <br />
      <b>Ravindra S</b>
      <br />
      <sub>Team Lead</sub>
    </td>
    <td>
      <ul>
        <li>Lead Developer</li>
        <li>Backend Developer</li>
        <li>UI/UX Developer</li>
      </ul>
    </td>
    <td>
      Ravindra S is an expert in Flutter and backend development, leading the technical implementation of our telemedicine app.
    </td>
  </tr>
  <tr>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/u/134051960?v=4" width="100px" height="100px" style="border-radius:50%;"/>
      <br />
      <b>P Nitesh</b>
      <br />
      <sub>UI/UX Lead</sub>
    </td>
    <td>
      <ul>
        <li>UI/UX Designer</li>
        <li>Frontend Developer</li>
        <li>Backend Developer</li>
      </ul>
    </td>
    <td>
      P Nitesh crafts intuitive and beautiful user interfaces, ensuring a seamless experience for our users.
    </td>
  </tr>
  <tr>
    <td align="center" width="200px">
      <img src="https://github.com/user-attachments/assets/73788e24-9cb5-4ddb-9b92-e68b9c4eeb30" width="100px" height="100px" style="border-radius:50%;"/>
      <br />
      <b>Pooja CG</b>
      <br />
      <sub>Project Manager</sub>
    </td>
    <td>
      <ul>
        <li>Content Creator</li>
        <li>Backend Developer</li>
        <li>Project Manager</li>
      </ul>
    </td>
    <td>
      Pooja coordinates the team, manages timelines, and ensures our project aligns with the hackathon goals.
    </td>
  </tr>
</table>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
