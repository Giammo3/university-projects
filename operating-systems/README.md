# Sistemi operativi (2024/2025)

## Project Overview

The goal of the project is to implement a **multi-process client-server system in C** using **Inter-Process Communication (IPC)** mechanisms available in Linux.

The system simulates a service architecture where multiple clients communicate with a central server process, coordinated through synchronization and communication primitives.

## Implementation Choice

The project allowed choosing between different IPC technologies.  
For this implementation, the following Linux IPC mechanisms were used:

- **Shared Memory**
- **Message Queues**
- **Semaphores**

These tools are used to enable communication and synchronization between processes while ensuring correct access to shared resources.

## System Architecture

The system is composed of three main components:

- **Server**
  - manages requests from clients
  - coordinates access to shared resources
  - processes operations

- **Client**
  - sends requests to the server
  - receives responses

- **Admin**
  - controls and monitors system execution

## Project Structure

- `src/` → source code
- `docs/` → assignment and report
- `CMakeLists.txt` → build configuration
- `README.md` → project overview

## Notes

This project was developed for the **Operating Systems** course during the second year of my Computer Science degree at the **University of Verona**.
