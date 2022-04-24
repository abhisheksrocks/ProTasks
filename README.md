<b><h2> ProTasks </h2> </b> 

This is the public repository for <b>ProTasks</b>, a collaborative task management app that I created. You can get the app from [here](https://play.google.com/store/apps/details?id=com.application.protasks.beta)

![Shot1](https://play-lh.googleusercontent.com/Tb7JLrhizqpCK7gEkLuQ20Y9PcnxeVmksMTOmHxySksSmCdLoQZqEq7CLsJoVB3F2UXB=w256)
![Shot2](https://play-lh.googleusercontent.com/td0bvoGfJxPfXMcVqrR7qI6jvHxHLLK4GvAvbGKusR4Q5EUdPanSyoMT4ofuVaWB6WI=w256)
![Shot2](https://play-lh.googleusercontent.com/xDqHrHCdQ2lTDFOpadmPSK7Tur_VDNcIFSI4qX4fDSngG19DL6bZxnTh160vWt9KBo0=w256)
![Shot2](https://play-lh.googleusercontent.com/lF9bf7gB4yHJL8_j8aD73aFNrqeupOjkYLJFvODx_ZqZdiBHz_m1pqhjEHzHsURuyw=w256)
![Shot2](https://play-lh.googleusercontent.com/EhJT-OfvkZkEFwufIoECTprtfK-mO_s6a8yMP4xCwhd323goVYYeQudgou-FSluE0P8=w256)

<b><h2> Highlighted Tools/Packages Used (And why?)</h2></b> 

<b><h3> Online Tools</h3></b>

- <b> Firebase Firestore:</b> I decided to make a hybrid database system which works both offline and online. For the online database, I decided to use Firestore, mostly because I had prior experience with it. Plus, [pub.dev](https://pub.dev) has all the necessary packages for this (which are also kept up to date). I know firestore data can also be persistent, but I wanted my app to work even if it never gets connected to internet. Also it saves database costs.
- <b> Firestore Rules:</b> This one goes without saying, I didn't want a user to have database admin-like privileges nor I would I like a user with no privilege. Plus, I wanted a database that has atleast has some form of protection against hackers. So I wrote a few rules to do just that.
- <b> Firebase Authentication:</b> Since I was using Firestore, it seemed most logical to use Firebase Authentication.
- <b> Firebase Remote Config:</b> Initially I just thought to experiment with this, not knowing how impactful it could be. But after working with it, I was able to grasp the idea behind it. So much so, that now a lot of app's core features are dependent on it.
- <b> Firebase Cloud Functions:</b> For some aspects of the database, it wasn't possible for a user to able to a make a database change directly. So, I used cloud functions to help the user do exactly that.
- <b> Dynamic Links:</b> Another one of those adventurous things I wanted to try out. If you have used the app, then in there - logging with email, which sends a mail to you which allows you to login without password. Yeah, that feature is completely based on Dynamic Links.
- For other tools, you can read through <b>pubspec.yaml</b> file.

<b><h3> Offline Tools</h3></b>

- <b> BLOC state management: </b> Well honestly speaking, I should have written "Cubits" here. I am a lot comfortable with Cubits than I am with Blocs. As time progresses, I will most probably move to Blocs. Also I have used Hydrated Blocs, as I needed a few state information to persist between app restarts (like sync information, login information, etc). 
- <b> Sembast:</b> Sembast is a offline NOSQL database. I wanted my app to work with/without internet, so I couldn't completely be dependent on Firestore(plus it saves my server costs). I had no prior experience with Sembast, but after going through the documentation, I came to an understanding that it is somewhat similar to Firestore. And obviously, if I plan on using 2 databases(online and offline), I must be able to convert data between those. So this became a more logical choice.
- <b> Awesome Notifications:</b> Local notifications is the area that I had no idea how to implement before starting this project. I have seen and infact used Cloud Messaging before for notifications. But I knew that it was not going to be of help here as the app is also supposed to be able to work completely offline. I initially used flutter_local_notifications as that package is the most popular one. But then I decided to show action buttons as well on the notification, which I couldn't find a way to do in that. So I started to look around and found Awesome Notifications package, which checked all my requirement checkboxes.
- For other tools, you can read through <b>pubspec.yaml</b> file.

<b><h2> Salient Features </h2></b> 

- <b> Works Online/Offline:</b> This app works with or without internet. You can create/edit/delete tasks or groups in any case. You will get identical(almost) experience in both cases.
- <b> Collaborate(or not):</b> This app is mostly driven towards colloboration within a team, allowing team members to create collective tasks, assign users to that tasks, etc. BUT this doesn't mean that users which don't plan on collaborating has no use of this app. I have made a tailored experience for both the use cases.
- <b> Login(or not):</b> I don't want to force a user to login to use the app. If the user doesn't want to login, that decision is also repected. Registered users get additional features like collaboration, cloud backup, etc. I have implemented a logic so that a user which initially decided not to log in doesn't risk losing data, if they decide to register later. All local data, is directly stored on the server in that case.
- <b> Pro without pay:</b> Everybody hates Ads, and I absolutely respect that. I have tried to keep ads shown to the user at minimum. Even if that's not enough and a user wants a complete Ad-Free experience, they can have that without paying a single dime(From "Upgrade to Pro" section in the sidebar). Just watch 5 ads, and enjoy all premium features for a whole day.
Other "Pro" features include realtime(every 15 minute otherwise) task, chat & group updates.


<b>Thanks for making it so far.</b> Hope you liked the result. For any app related queries or suggestion, you can send me an email at [developer@protasks.in](mailto:developer@protasks.in) (Helps me to keep app related information at one place). For any other queries or suggestions, you can contact me via [LinkedIn](https://www.linkedin.com/in/abhishek-97099b125/).
