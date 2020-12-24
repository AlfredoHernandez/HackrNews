![HackrNews](./assets/hackr-news-inline.png)

![macOS](https://github.com/AlfredoHernandez/HackrNews/workflows/macOS/badge.svg)
![iOS](https://github.com/AlfredoHernandez/HackrNews/workflows/iOS/badge.svg)

---

![GitHub last commit](https://img.shields.io/github/last-commit/AlfredoHernandez/HackrNews?style=for-the-badge)
![issues](https://img.shields.io/github/issues/AlfredoHernandez/HackrNews?color=blue&style=for-the-badge)
[![GitHub license](https://img.shields.io/github/license/AlfredoHernandez/HackrNews?color=brigthgreen&style=for-the-badge)](https://github.com/AlfredoHernandez/HackrNews)
![GitHub forks](https://img.shields.io/github/forks/AlfredoHernandez/HackrNews?style=for-the-badge&color=blueviolet)

## About Hackr/News

A simple iOS client for Y Combinator's Hacker News.

![iPhone 12 Mini Launch Screen](./assets/HackrNewsiPhone12MiniMain.png.jpg)

![iPhone 12 Mini Main Screen](./assets/HackrNewsiPhone12MiniMain.png.jpg)

## App Architecture

### Core modules

The core `Hackr News Feature` and API's modules are platform agnostic, so they can be reused.

##### MVC 

We started with a simple MVC approach, delegating responsabilities for refreshing, displaying cell information and managing cell controllers to its own components.

![App Architecture MVC Diagram](./assets/hackr-news-diagram-mvc.png)

You can check the diff [here](https://github.com/AlfredoHernandez/HackrNews/pull/6)

##### MVVM 

In this approach we create a new platform agnostic `Stories Presentation` module, so they now can be reused by any platform. 

![App Architecture MVVM Diagram](./assets/hackr-news-diagram-mvvm.png)

You can check the diff [here](https://github.com/AlfredoHernandez/HackrNews/pull/8)

## UX goals for the `New Stories` UI experience

- [X] Load stories automatically when view is presented
- [X] Allow customer to manually reload stories (pull to refresh)
- [X] Show a loading indicator while loading stories

### Stories loading experience

- [X] Render all loaded stories items (Title, Author, score, created at, total comments, url)
- [X] Load story when is near to be visible (on screen)
- [X] Cancel load story when is out of screen
- [X] Show a loading indicator while loading story (shimmer)
- [X] Option to retry load story in download error
- [X] Preload when story view is near visible